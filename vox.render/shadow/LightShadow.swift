//
//  LightShadow.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// Shadow manager.
class LightShadow {
    private static var _viewMatFromLightProperty = Shader.getPropertyByName("u_viewMatFromLight")
    private static var _projMatFromLightProperty = Shader.getPropertyByName("u_projMatFromLight")
    private static var _shadowBiasProperty = Shader.getPropertyByName("u_shadowBias")
    private static var _shadowIntensityProperty = Shader.getPropertyByName("u_shadowIntensity")
    private static var _shadowRadiusProperty = Shader.getPropertyByName("u_shadowRadius")
    private static var _shadowMapSizeProperty = Shader.getPropertyByName("u_shadowMapSize")
    private static var _shadowMapsProperty = Shader.getPropertyByName("u_shadowMaps")

    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = LightShadow._combinedData

        shaderData.setFloatArray(LightShadow._viewMatFromLightProperty, data.viewMatrix)
        shaderData.setFloatArray(LightShadow._projMatFromLightProperty, data.projectionMatrix)
        shaderData.setFloatArray(LightShadow._shadowBiasProperty, data.bias)
        shaderData.setFloatArray(LightShadow._shadowIntensityProperty, data.intensity)
        shaderData.setFloatArray(LightShadow._shadowRadiusProperty, data.radius)
        shaderData.setFloatArray(LightShadow._shadowMapSizeProperty, data.mapSize)
        shaderData.setTextureArray(LightShadow._shadowMapsProperty, data.map)
    }

    /// Clear all shadow maps.
    static func clearMap() {
        LightShadow._combinedData.map = []
    }

    private static var _maxLight = 3

    private static var _combinedData = (
            viewMatrix: [Float].init(repeating: 0, count: 16 * LightShadow._maxLight),
            projectionMatrix: [Float].init(repeating: 0, count: 16 * LightShadow._maxLight),
            bias: [Float].init(repeating: 0, count: LightShadow._maxLight),
            intensity: [Float].init(repeating: 0, count: LightShadow._maxLight),
            radius: [Float].init(repeating: 0, count: LightShadow._maxLight),
            mapSize: [Float].init(repeating: 0, count: 2 * LightShadow._maxLight),
            map: [RenderColorTexture].init()
    )

    private var _mapSize: Vector2
    private var _renderTarget: RenderTarget

    /// Shadow's light.
    var light: Light

    /// Shadow bias.
    var bias: Float = 0.005

    /// Shadow intensity, the larger the value, the clearer and darker the shadow.
    var intensity: Float = 0.2

    /// Pixel range used for shadow PCF interpolation.
    var radius: Float = 1

    /// Generate the projection matrix used by the shadow map.
    var projectionMatrix: Matrix = Matrix()

    init(_ light: Light, _ engine: Engine, _ width: Float = 512, _ height: Float = 512) {
        self.light = light

        _mapSize = Vector2(width, height)
        _renderTarget = RenderTarget(engine, Int(width), Int(height),
                RenderColorTexture(engine, Int(width), Int(height)))
    }

    /// The RenderTarget corresponding to the shadow map.
    var renderTarget: RenderTarget {
        get {
            _renderTarget
        }
    }

    /// Shadow map's color render texture.
    var map: RenderColorTexture {
        get {
            _renderTarget.getColorTexture()!
        }
    }

    /// Shadow map size.
    var mapSize: Vector2 {
        get {
            _mapSize
        }
    }

    /// Initialize the projection matrix for lighting.
    /// - Parameter light: The light to generate shadow
    func initShadowProjectionMatrix(_ light: Light) {
        // Directional light projection matrix,
        // the default coverage area is left: -5, right: 5, bottom: -5, up: 5, near: 0.5, far: 50.
        if (light is DirectLight) {
            Matrix.ortho(left: -5, right: 5, bottom: -5, top: 5,
                    near: 0.1, far: 50, out: projectionMatrix)
        }

        // Point light projection matrix,
        // default configuration: fov: 50, aspect: 1, near: 0.5, far: 50.
        if (light is PointLight) {
            Matrix.perspective(fovy: MathUtil.degreeToRadian(50),
                    aspect: 1, near: 0.5, far: 50, out: projectionMatrix)
        }

        // Spotlight projection matrix,
        // the default configuration: fov: this.angle * 2 * Math.sqrt(2), aspect: 1, near: 0.1, far: this.distance + 5
        if (light is SpotLight) {
            let fov = min(Float.pi / 2, (light as! SpotLight).angle * 2 * sqrt(2))
            Matrix.perspective(fovy: fov, aspect: 1,
                    near: 0.1, far: (light as! SpotLight).distance + 5, out: projectionMatrix)
        }
    }

    func appendData(_ lightIndex: Int) {
        let viewStart = lightIndex * 16
        let projectionStart = lightIndex * 16
        let biasStart = lightIndex
        let intensityStart = lightIndex
        let radiusStart = lightIndex
        let mapSizeStart = lightIndex * 2
        let mapStart = lightIndex

        LightShadow._combinedData.viewMatrix[viewStart + 0] = light.viewMatrix.elements.columns.0[0]
        LightShadow._combinedData.viewMatrix[viewStart + 1] = light.viewMatrix.elements.columns.0[1]
        LightShadow._combinedData.viewMatrix[viewStart + 2] = light.viewMatrix.elements.columns.0[2]
        LightShadow._combinedData.viewMatrix[viewStart + 3] = light.viewMatrix.elements.columns.0[3]

        LightShadow._combinedData.viewMatrix[viewStart + 4] = light.viewMatrix.elements.columns.1[0]
        LightShadow._combinedData.viewMatrix[viewStart + 5] = light.viewMatrix.elements.columns.1[1]
        LightShadow._combinedData.viewMatrix[viewStart + 6] = light.viewMatrix.elements.columns.1[2]
        LightShadow._combinedData.viewMatrix[viewStart + 7] = light.viewMatrix.elements.columns.1[3]

        LightShadow._combinedData.viewMatrix[viewStart + 8] = light.viewMatrix.elements.columns.2[0]
        LightShadow._combinedData.viewMatrix[viewStart + 9] = light.viewMatrix.elements.columns.2[1]
        LightShadow._combinedData.viewMatrix[viewStart + 10] = light.viewMatrix.elements.columns.2[2]
        LightShadow._combinedData.viewMatrix[viewStart + 11] = light.viewMatrix.elements.columns.2[3]

        LightShadow._combinedData.viewMatrix[viewStart + 12] = light.viewMatrix.elements.columns.3[0]
        LightShadow._combinedData.viewMatrix[viewStart + 13] = light.viewMatrix.elements.columns.3[1]
        LightShadow._combinedData.viewMatrix[viewStart + 14] = light.viewMatrix.elements.columns.3[2]
        LightShadow._combinedData.viewMatrix[viewStart + 15] = light.viewMatrix.elements.columns.3[3]

        LightShadow._combinedData.projectionMatrix[projectionStart + 0] = projectionMatrix.elements.columns.0[0]
        LightShadow._combinedData.projectionMatrix[projectionStart + 1] = projectionMatrix.elements.columns.0[1]
        LightShadow._combinedData.projectionMatrix[projectionStart + 2] = projectionMatrix.elements.columns.0[2]
        LightShadow._combinedData.projectionMatrix[projectionStart + 3] = projectionMatrix.elements.columns.0[3]

        LightShadow._combinedData.projectionMatrix[projectionStart + 4] = projectionMatrix.elements.columns.1[0]
        LightShadow._combinedData.projectionMatrix[projectionStart + 5] = projectionMatrix.elements.columns.1[1]
        LightShadow._combinedData.projectionMatrix[projectionStart + 6] = projectionMatrix.elements.columns.1[2]
        LightShadow._combinedData.projectionMatrix[projectionStart + 7] = projectionMatrix.elements.columns.1[3]

        LightShadow._combinedData.projectionMatrix[projectionStart + 8] = projectionMatrix.elements.columns.2[0]
        LightShadow._combinedData.projectionMatrix[projectionStart + 9] = projectionMatrix.elements.columns.2[1]
        LightShadow._combinedData.projectionMatrix[projectionStart + 10] = projectionMatrix.elements.columns.2[2]
        LightShadow._combinedData.projectionMatrix[projectionStart + 11] = projectionMatrix.elements.columns.2[3]

        LightShadow._combinedData.projectionMatrix[projectionStart + 12] = projectionMatrix.elements.columns.3[0]
        LightShadow._combinedData.projectionMatrix[projectionStart + 13] = projectionMatrix.elements.columns.3[1]
        LightShadow._combinedData.projectionMatrix[projectionStart + 14] = projectionMatrix.elements.columns.3[2]
        LightShadow._combinedData.projectionMatrix[projectionStart + 15] = projectionMatrix.elements.columns.3[3]

        LightShadow._combinedData.bias[biasStart] = bias
        LightShadow._combinedData.intensity[intensityStart] = intensity
        LightShadow._combinedData.radius[radiusStart] = radius
        LightShadow._combinedData.mapSize[mapSizeStart] = mapSize.x
        LightShadow._combinedData.mapSize[mapSizeStart + 1] = mapSize.y
        LightShadow._combinedData.map[mapStart] = map
    }
}
