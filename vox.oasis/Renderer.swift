//
//  Renderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import Metal

/// Renderable component.
class Renderer: Component {
    private static var _localMatrixProperty = Shader.getPropertyByName("u_localMat")
    private static var _worldMatrixProperty = Shader.getPropertyByName("u_modelMat")
    private static var _mvMatrixProperty = Shader.getPropertyByName("u_MVMat")
    private static var _mvpMatrixProperty = Shader.getPropertyByName("u_MVPMat")
    private static var _mvInvMatrixProperty = Shader.getPropertyByName("u_MVInvMat")
    private static var _normalMatrixProperty = Shader.getPropertyByName("u_normalMat")

    // @deepClone
    /// ShaderData related to renderer.
    var shaderData: ShaderData = ShaderData(ShaderDataGroup.Renderer)
    // @ignoreClone
    /// Whether it is clipped by the frustum, needs to be turned on camera.enableFrustumCulling.
    var isCulled: Bool = false

    // @ignoreClone
    internal var _distanceForSort: Float = 0
    // @ignoreClone
    internal var _onUpdateIndex: Int = -1
    // @ignoreClone
    internal var _rendererIndex: Int = -1
    // @ignoreClone
    internal var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection();

    // @ignoreClone
    internal var _renderSortId: Int = 0

    // @ignoreClone
    var _overrideUpdate: Bool = false
    // @shallowClone
    var _materials: [Material?] = []

    // @ignoreClone
    private var _transformChangeFlag: UpdateFlag? = nil
    // @deepClone
    private var _bounds: BoundingBox = BoundingBox(Vector3(), Vector3())
    // @ignoreClone
    private var _mvMatrix: Matrix = Matrix()
    // @ignoreClone
    private var _mvpMatrix: Matrix = Matrix()
    // @ignoreClone
    private var _mvInvMatrix: Matrix = Matrix()
    // @ignoreClone
    private var _normalMatrix: Matrix = Matrix()
    // @ignoreClone
    private var _materialsInstanced: [Bool] = []

    /// Set whether the renderer to receive shadows.
    public var receiveShadow: Bool = false
    /// Set whether the renderer to cast shadows.
    public var castShadow: Bool = false

    /// Material count.
    var materialCount: Int {
        get {
            _materials.count
        }
    }

    /// The bounding volume of the renderer.
    var bounds: BoundingBox {
        get {
            let changeFlag = _transformChangeFlag
            if (changeFlag!.flag) {
                _updateBounds(_bounds)
                changeFlag!.flag = false
            }
            return _bounds
        }
    }

    required init(_ entity: Entity) {
        super.init(entity)

        _overrideUpdate = true
        _transformChangeFlag = entity.transform.registerWorldChangeFlag()
        shaderData._addRefCount(1)
    }

    internal override func _onEnable() {
        let componentsManager = engine._componentsManager
        if (_overrideUpdate) {
            componentsManager.addOnUpdateRenderers(self)
        }
        componentsManager.addRenderer(self)
    }

    internal override func _onDisable() {
        let componentsManager = engine._componentsManager
        if (_overrideUpdate) {
            componentsManager.removeOnUpdateRenderers(self)
        }
        componentsManager.removeRenderer(self)
    }

    internal override func _onDestroy() {
        let flag = _transformChangeFlag
        if (flag != nil) {
            flag!.destroy()
            _transformChangeFlag = nil
        }
    }

    func _render(_ camera: Camera) {
    }

    func _updateBounds(_ worldBounds: BoundingBox) {
    }

    func update(_ deltaTime: Float) {
    }

//MARK:- Material Methods
    /// Get the first instance material by index.
    /// - Remark: Calling this function for the first time after the material is set
    /// will create an instance material to ensure that it is unique to the renderer.
    /// - Parameter index: Material index
    /// - Returns: Instance material
    func getInstanceMaterial(_ index: Int = 0) -> Material? {
        let materials = _materials
        if (materials.count > index) {
            let material = materials[index]
            if (material != nil) {
                if (_materialsInstanced[index]) {
                    return material
                } else {
                    return _createInstanceMaterial(material!, index)
                }
            }
        }
        return nil
    }

    /// Get the first material by index.
    /// - Parameter index: Material index
    /// - Returns: Material
    func getMaterial(_ index: Int = 0) -> Material? {
        return _materials[index]
    }

    /// Set the first material.
    /// - Parameter material: The first material
    func setMaterial(_ material: Material) {
        let index = 0

        if (index >= _materials.count) {
            _materials.reserveCapacity(index + 1)
            for _ in _materials.count...index {
                _materials.append(nil)
            }
        }

        let internalMaterial = _materials[index]
        if (internalMaterial !== material) {
            _materials[index] = material
            if index < _materialsInstanced.count {
                _materialsInstanced[index] = false
            }
            if internalMaterial != nil {
                internalMaterial!._addRefCount(-1)
            }
            material._addRefCount(1)
        }
    }

    /// Set material by index.
    /// - Parameters:
    ///   - index: Material index
    ///   - material: The material
    func setMaterial(_ index: Int, _ material: Material) {
        if (index >= _materials.count) {
            _materials.reserveCapacity(index + 1)
            for _ in _materials.count...index {
                _materials.append(nil)
            }
        }

        let internalMaterial = _materials[index]
        if (internalMaterial !== material) {
            _materials[index] = material
            if index < _materialsInstanced.count {
                _materialsInstanced[index] = false
            }
            if internalMaterial != nil {
                internalMaterial!._addRefCount(-1)
            }
            material._addRefCount(1)
        }
    }

    /// Get all instance materials.
    /// - Remark: Calling this function for the first time after the material is set
    ///  will create an instance material to ensure that it is unique to the renderer.
    /// - Returns: All instance materials
    func getInstanceMaterials() -> [Material?] {
        let materials = _materials
        let materialsInstance = _materialsInstanced
        for i in 0..<materials.count {
            if (!materialsInstance[i]) {
                _ = _createInstanceMaterial(_materials[i]!, i)
            }
        }
        return materials
    }

    /// Get all materials.
    /// - Returns: All materials
    func getMaterials() -> [Material?] {
        _materials
    }

    /// Set all materials.
    /// - Parameter materials: All materials
    func setMaterials(_ materials: [Material]) {
        let count = materials.count

        for i in 0..<_materials.count {
            let internalMaterial = _materials[i]
            if internalMaterial != nil {
                internalMaterial!._addRefCount(-1)
            }
        }

        if _materials.count != count {
            _materials.reserveCapacity(count)
            for _ in _materials.count..<count {
                _materials.append(nil)
            }
        }
        if _materialsInstanced.count != 0 {
            _materialsInstanced = []
        }

        for i in 0..<count {
            let internalMaterial = _materials[i]
            let material = materials[i]
            if (internalMaterial !== material) {
                _materials[i] = material
                if internalMaterial != nil {
                    internalMaterial!._addRefCount(-1)
                }
                material._addRefCount(1)
            }
        }
    }
}

//MARK:- Private Methods
extension Renderer {
    internal func _updateShaderData(_ context: RenderContext) {
        let shaderData = shaderData
        let worldMatrix = entity.transform.worldMatrix
        let mvMatrix = _mvMatrix
        let mvpMatrix = _mvpMatrix
        let mvInvMatrix = _mvInvMatrix
        let normalMatrix = _normalMatrix

        Matrix.multiply(left: context._camera.viewMatrix, right: worldMatrix, out: mvMatrix)
        Matrix.multiply(left: context._viewProjectMatrix, right: worldMatrix, out: mvpMatrix)
        Matrix.invert(a: mvMatrix, out: mvInvMatrix)
        Matrix.invert(a: worldMatrix, out: normalMatrix)
        _ = normalMatrix.transpose()

        shaderData.setMatrix(Renderer._localMatrixProperty, entity.transform.localMatrix)
        shaderData.setMatrix(Renderer._worldMatrixProperty, worldMatrix)
        shaderData.setMatrix(Renderer._mvMatrixProperty, mvMatrix)
        shaderData.setMatrix(Renderer._mvpMatrixProperty, mvpMatrix)
        shaderData.setMatrix(Renderer._mvInvMatrixProperty, mvInvMatrix)
        shaderData.setMatrix(Renderer._normalMatrixProperty, normalMatrix)
    }

    private func _createInstanceMaterial(_ material: Material, _ index: Int) -> Material {
        let insMaterial: Material = material.clone()
        insMaterial.name = insMaterial.name + "(Instance)"
        material._addRefCount(-1)
        insMaterial._addRefCount(1)
        _materialsInstanced[index] = true
        _materials[index] = insMaterial
        return insMaterial
    }
}
