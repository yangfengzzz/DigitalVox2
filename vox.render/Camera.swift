//
//  Camera.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/9.
//

import Foundation

class MathTemp {
    static var tempMat4 = Matrix()
    static var tempVec4 = Vector4()
    static var tempVec3 = Vector3()
    static var tempVec2 = Vector2()
}

class Camera: Component {
    private static var _viewMatrixProperty = Shader.getPropertyByName("u_viewMat")
    private static var _projectionMatrixProperty = Shader.getPropertyByName("u_projMat")
    private static var _vpMatrixProperty = Shader.getPropertyByName("u_VPMat")
    private static var _inverseViewMatrixProperty = Shader.getPropertyByName("u_viewInvMat")
    private static var _inverseProjectionMatrixProperty = Shader.getPropertyByName("u_projInvMat")
    private static var _cameraPositionProperty = Shader.getPropertyByName("u_cameraPos")

    /// Shader data.
    var shaderData: ShaderData = ShaderData(ShaderDataGroup.Camera)

    /// Rendering priority - A Camera with higher priority will be rendered on top of a camera with lower priority.
    var priority: Int = 0

    /// Whether to enable frustum culling, it is enabled by default.
    var enableFrustumCulling: Bool = true

    /// Determining what to clear when rendering by a Camera.
    /// defaultValue `CameraClearFlags.DepthColor`
    var clearFlags: CameraClearFlags = CameraClearFlags.DepthColor

    /// Culling mask - which layers the camera renders.
    /// - Remark Support bit manipulation, corresponding to Entity's layer.
    var cullingMask: Layer = Layer.Everything

    internal var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection()
    // @deepClone
    internal var _frustum: BoundingFrustum = BoundingFrustum()
    // @ignoreClone
    internal var _renderPipeline: BasicRenderPipeline!

    private var _isOrthographic: Bool = false
    private var _isProjMatSetting = false
    private var _nearClipPlane: Float = 0.1
    private var _farClipPlane: Float = 100
    private var _fieldOfView: Float = 45
    private var _orthographicSize: Float = 10
    private var _isProjectionDirty = true
    private var _isInvProjMatDirty: Bool = true
    private var _isFrustumProjectDirty: Bool = true
    private var _customAspectRatio: Float?
    private var _renderTarget: RenderTarget? = nil

    // @ignoreClone
    private var _frustumViewChangeFlag: UpdateFlag
    // @ignoreClone
    private var _transform: Transform
    // @ignoreClone
    private var _isViewMatrixDirty: UpdateFlag
    // @ignoreClone
    private var _isInvViewProjDirty: UpdateFlag
    // @deepClone
    private var _projectionMatrix: Matrix = Matrix()
    // @deepClone
    private var _viewMatrix: Matrix = Matrix()
    // @deepClone
    private var _viewport: Vector4 = Vector4(0, 0, 1, 1)
    // @deepClone
    private var _inverseProjectionMatrix: Matrix = Matrix()
    // @deepClone
    private var _lastAspectSize: Vector2 = Vector2(0, 0)
    // @deepClone
    private var _invViewProjMat: Matrix = Matrix()

    /// Near clip plane - the closest point to the camera when rendering occurs.
    var nearClipPlane: Float {
        get {
            _nearClipPlane
        }
        set {
            _nearClipPlane = newValue
            _projMatChange()
        }
    }

    /// Far clip plane - the furthest point to the camera when rendering occurs.
    var farClipPlane: Float {
        get {
            _farClipPlane
        }
        set {
            _farClipPlane = newValue
            _projMatChange()
        }
    }

    /// The camera's view angle. activating when camera use perspective projection.
    var fieldOfView: Float {
        get {
            _fieldOfView
        }
        set {
            _fieldOfView = newValue
            _projMatChange()
        }
    }


    /// Aspect ratio. The default is automatically calculated by the viewport's aspect ratio. If it is manually set,
    /// the manual value will be kept. Call resetAspectRatio() to restore it.
    var aspectRatio: Float {
        get {
            let canvas = _entity.engine.canvas
            return _customAspectRatio ?? (Float(canvas.bounds.width) * _viewport.z) / (Float(canvas.bounds.height) * _viewport.w)
        }
        set {
            _customAspectRatio = newValue
            _projMatChange()
        }
    }

    /// Viewport, normalized expression, the upper left corner is (0, 0), and the lower right corner is (1, 1).
    /// - Remark: Re-assignment is required after modification to ensure that the modification takes effect.
    var viewport: Vector4 {
        get {
            _viewport
        }
        set {
            if (newValue !== _viewport) {
                newValue.cloneTo(target: _viewport)
            }
            _projMatChange()
        }
    }


    /// Whether it is orthogonal, the default is false. True will use orthographic projection, false will use perspective projection.
    var isOrthographic: Bool {
        get {
            _isOrthographic
        }
        set {
            _isOrthographic = newValue
            _projMatChange()
        }
    }

    /// Half the size of the camera in orthographic mode.
    var orthographicSize: Float {
        get {
            _orthographicSize
        }
        set {
            _orthographicSize = newValue
            _projMatChange()
        }
    }

    /// View matrix.
    var viewMatrix: Matrix {
        get {
            // Remove scale
            if (_isViewMatrixDirty.flag) {
                _isViewMatrixDirty.flag = false
                Matrix.invert(a: _transform.worldMatrix, out: _viewMatrix)
            }
            return _viewMatrix
        }
    }

    /// The projection matrix is ​​calculated by the relevant parameters of the camera by default.
    /// If it is manually set, the manual value will be maintained. Call resetProjectionMatrix() to restore it.
    var projectionMatrix: Matrix {
        get {
            let canvas = _entity.engine.canvas
            if (
                       (!_isProjectionDirty || _isProjMatSetting) &&
                               _lastAspectSize.x == Float(canvas.bounds.width) &&
                               _lastAspectSize.y == Float(canvas.bounds.height)
               ) {
                return _projectionMatrix
            }
            _isProjectionDirty = false
            _lastAspectSize.x = Float(canvas.bounds.width)
            _lastAspectSize.y = Float(canvas.bounds.height)
            let aspectRatio = aspectRatio
            if (!_isOrthographic) {
                Matrix.perspective(
                        fovy: MathUtil.degreeToRadian(_fieldOfView),
                        aspect: aspectRatio,
                        near: _nearClipPlane,
                        far: _farClipPlane,
                        out: _projectionMatrix
                )
            } else {
                let width = _orthographicSize * aspectRatio
                let height = _orthographicSize
                Matrix.ortho(left: -width, right: width, bottom: -height, top: height,
                        near: _nearClipPlane, far: _farClipPlane, out: _projectionMatrix)
            }
            return _projectionMatrix
        }
        set {
            _projectionMatrix = newValue
            _isProjMatSetting = true
            _projMatChange()
        }
    }

    /// Whether to enable HDR.
    var enableHDR: Bool {
        get {
            fatalError("not implementation")
        }
        set {
            fatalError("not implementation")
        }
    }

    /// RenderTarget. After setting, it will be rendered to the renderTarget. If it is empty, it will be rendered to the main canvas.
    var renderTarget: RenderTarget? {
        get {
            _renderTarget
        }
        set {
            _renderTarget = newValue
        }
    }


    /// Create the Camera component.
    /// - Parameter entity: Entity
    required init(_ entity: Entity) {
        let transform = entity.transform
        _transform = transform!
        _isViewMatrixDirty = transform!.registerWorldChangeFlag()
        _isInvViewProjDirty = transform!.registerWorldChangeFlag()
        _frustumViewChangeFlag = transform!.registerWorldChangeFlag()

        super.init(entity)
        _renderPipeline = BasicRenderPipeline(self)
        shaderData._addRefCount(1)
    }

    override func _onActive() {
        entity.scene._attachRenderCamera(self)
    }

    override func _onInActive() {
        entity.scene._detachRenderCamera(self)
    }

    override func _onDestroy() {
        _renderPipeline.destroy()
        _isInvViewProjDirty.destroy()
        _isViewMatrixDirty.destroy()
    }
}

extension Camera {
    /// Restore the automatic calculation of projection matrix through fieldOfView, nearClipPlane and farClipPlane.
    func resetProjectionMatrix() {
        _isProjMatSetting = false
        _projMatChange()
    }

    /// Restore the automatic calculation of the aspect ratio through the viewport aspect ratio.
    func resetAspectRatio() {
        _customAspectRatio = nil
        _projMatChange()
    }

    /// Transform a point from world space to viewport space.
    /// - Parameters:
    ///   - point: Point in world space
    ///   - out: A point in the viewport space, X and Y are the viewport space coordinates, Z is the viewport depth,
    ///   the near clipping plane is 0, the far clipping plane is 1, and W is the world unit distance from the camera
    /// - Returns: Point in viewport space
    func worldToViewportPoint(_ point: Vector3, _ out: Vector4) -> Vector4 {
        Matrix.multiply(left: projectionMatrix, right: viewMatrix, out: MathTemp.tempMat4)
        _ = MathTemp.tempVec4.setValue(x: point.x, y: point.y, z: point.z, w: 1.0)
        Vector4.transform(v: MathTemp.tempVec4, m: MathTemp.tempMat4, out: MathTemp.tempVec4)

        let w = MathTemp.tempVec4.w
        let nx = MathTemp.tempVec4.x / w
        let ny = MathTemp.tempVec4.y / w
        let nz = MathTemp.tempVec4.z / w

        // Transform of coordinate axis.
        out.x = (nx + 1.0) * 0.5
        out.y = (1.0 - ny) * 0.5
        out.z = nz
        out.w = w
        return out
    }

    /// Transform a point from viewport space to world space.
    /// - Parameters:
    ///   - point: Point in viewport space, X and Y are the viewport space coordinates, Z is the viewport depth.
    ///   The near clipping plane is 0, and the far clipping plane is 1
    ///   - out: Point in world space
    /// - Returns: Point in world space
    func viewportToWorldPoint(_ point: Vector3, _ out: Vector3) -> Vector3 {
        let invViewProjMat = invViewProjMat
        return _innerViewportToWorldPoint(point, invViewProjMat, out)
    }

    /// Generate a ray by a point in viewport.
    /// - Parameters:
    ///   - point: Point in viewport space, which is represented by normalization
    ///   - out: Ray
    /// - Returns: Ray
    func viewportPointToRay(_ point: Vector2, _ out: Ray) -> Ray {
        let clipPoint = MathTemp.tempVec3
        // Use the intersection of the near clipping plane as the origin point.
        _ = clipPoint.setValue(x: point.x, y: point.y, z: 0)
        let origin = viewportToWorldPoint(clipPoint, out.origin)
        // Use the intersection of the far clipping plane as the origin point.
        clipPoint.z = 1.0
        let farPoint: Vector3 = _innerViewportToWorldPoint(clipPoint, _invViewProjMat, clipPoint)
        Vector3.subtract(left: farPoint, right: origin, out: out.direction)
        _ = out.direction.normalize()

        return out
    }

    /// Transform the X and Y coordinates of a point from screen space to viewport space
    /// - Parameters:
    ///   - point: Point in screen space
    ///   - out: Point in viewport space
    /// - Returns: Point in viewport space
    func screenToViewportPoint(_ point: Vector2, _ out: Vector2) -> Vector2 {
        let canvas = engine.canvas
        let viewport = viewport
        out.x = (point.x / Float(canvas.bounds.width) - viewport.x) / viewport.z
        out.y = (point.y / Float(canvas.bounds.height) - viewport.y) / viewport.w
        return out
    }

    func screenToViewportPoint(_ point: Vector3, _ out: Vector3) -> Vector3 {
        let canvas = engine.canvas
        let viewport = viewport
        out.x = (point.x / Float(canvas.bounds.width) - viewport.x) / viewport.z
        out.y = (point.y / Float(canvas.bounds.height) - viewport.y) / viewport.w
        return out
    }

    /// Transform the X and Y coordinates of a point from viewport space to screen space.
    /// - Parameters:
    ///   - point: Point in viewport space
    ///   - out: Point in screen space
    /// - Returns: Point in screen space
    func viewportToScreenPoint(_ point: Vector2, _ out: Vector2) -> Vector2 {
        let canvas = engine.canvas
        let viewport = viewport
        out.x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.width)
        out.y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.height)
        return out
    }

    func viewportToScreenPoint(_ point: Vector3, _ out: Vector3) -> Vector3 {
        let canvas = engine.canvas
        let viewport = viewport
        out.x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.width)
        out.y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.height)
        return out
    }

    func viewportToScreenPoint(_ point: Vector4, _ out: Vector4) -> Vector4 {
        let canvas = engine.canvas
        let viewport = viewport
        out.x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.width)
        out.y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.height)
        return out
    }

    /// Transform a point from world space to screen space.
    /// - Parameters:
    ///   - point: Point in world space
    ///   - out: Point of screen space
    /// - Returns: Point of screen space
    func worldToScreenPoint(_ point: Vector3, _ out: Vector4) -> Vector4 {
        _ = worldToViewportPoint(point, out)
        return viewportToScreenPoint(out, out)
    }

    /// Transform a point from screen space to world space.
    /// - Parameters:
    ///   - point: Screen space point
    ///   - out: Point in world space
    /// - Returns: Point in world space
    func screenToWorldPoint(_ point: Vector3, _ out: Vector3) -> Vector3 {
        _ = screenToViewportPoint(point, out)
        return viewportToWorldPoint(out, out)
    }

    /// Generate a ray by a point in screen.
    /// - Parameters:
    ///   - point: Point in screen space, the unit is pixel
    ///   - out: Ray
    /// - Returns: Ray
    func screenPointToRay(_ point: Vector2, _ out: Ray) -> Ray {
        let viewportPoint = MathTemp.tempVec2
        _ = screenToViewportPoint(point, viewportPoint)
        return viewportPointToRay(viewportPoint, out)
    }

    /// Manually call the rendering of the camera.
    func render(_ cubeFace: TextureCubeFace? = nil) {
        // compute cull frustum.
        let context = engine._renderContext
        context._setContext(self)
        if (enableFrustumCulling && (_frustumViewChangeFlag.flag || _isFrustumProjectDirty)) {
            _frustum.calculateFromMatrix(matrix: context._viewProjectMatrix)
            _frustumViewChangeFlag.flag = false
            _isFrustumProjectDirty = false
        }

        _updateShaderData(context)

        // union scene and camera macro.
        ShaderMacroCollection.unionCollection(
                scene.shaderData._macroCollection,
                shaderData._macroCollection,
                _globalShaderMacro
        )

        _renderPipeline.render(context, cubeFace)
    }
}

extension Camera {
    private func _projMatChange() {
        _isFrustumProjectDirty = true
        _isProjectionDirty = true
        _isInvProjMatDirty = true
        _isInvViewProjDirty.flag = true
    }

    private func _innerViewportToWorldPoint(_ point: Vector3, _ invViewProjMat: Matrix, _ out: Vector3) -> Vector3 {
        // Depth is a normalized value, 0 is nearPlane, 1 is farClipPlane.
        let depth = point.z * 2 - 1
        // Transform to clipping space matrix
        let clipPoint = MathTemp.tempVec4
        _ = clipPoint.setValue(x: point.x * 2 - 1, y: 1 - point.y * 2, z: depth, w: 1)
        Vector4.transform(v: clipPoint, m: invViewProjMat, out: clipPoint)
        let invW = 1.0 / clipPoint.w
        out.x = clipPoint.x * invW
        out.y = clipPoint.y * invW
        out.z = clipPoint.z * invW
        return out
    }

    private func _updateShaderData(_ context: RenderContext) {
        shaderData.setMatrix(Camera._viewMatrixProperty, viewMatrix)
        shaderData.setMatrix(Camera._projectionMatrixProperty, projectionMatrix)
        shaderData.setMatrix(Camera._vpMatrixProperty, context._viewProjectMatrix)
        shaderData.setMatrix(Camera._inverseViewMatrixProperty, _transform.worldMatrix)
        shaderData.setMatrix(Camera._inverseProjectionMatrixProperty, inverseProjectionMatrix)
        shaderData.setVector3(Camera._cameraPositionProperty, _transform.worldPosition)
    }

    /// The inverse matrix of view projection matrix.
    private var invViewProjMat: Matrix {
        get {
            if (_isInvViewProjDirty.flag) {
                _isInvViewProjDirty.flag = false
                Matrix.multiply(left: _transform.worldMatrix, right: inverseProjectionMatrix, out: _invViewProjMat)
            }
            return _invViewProjMat
        }
    }

    /// The inverse of the projection matrix.
    private var inverseProjectionMatrix: Matrix {
        get {
            if (_isInvProjMatDirty) {
                _isInvProjMatDirty = false
                Matrix.invert(a: projectionMatrix, out: _inverseProjectionMatrix)
            }
            return _inverseProjectionMatrix
        }
    }
}
