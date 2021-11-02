//
//  LightShadow.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Metal

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

        shaderData.setBytes(LightShadow._viewMatFromLightProperty, data.viewMatrix)
        shaderData.setBytes(LightShadow._projMatFromLightProperty, data.projectionMatrix)
        shaderData.setBytes(LightShadow._shadowBiasProperty, data.bias)
        shaderData.setBytes(LightShadow._shadowIntensityProperty, data.intensity)
        shaderData.setBytes(LightShadow._shadowRadiusProperty, data.radius)
        shaderData.setBytes(LightShadow._shadowMapSizeProperty, data.mapSize)
        shaderData.setBytes(LightShadow._shadowMapsProperty, data.map)
    }

    /// Clear all shadow maps.
    static func clearMap() {
        LightShadow._combinedData.map = []
    }

    private static var _maxLight = 3

    private static var _combinedData = (
            viewMatrix: [matrix_float4x4].init(repeating: matrix_float4x4(), count: LightShadow._maxLight),
            projectionMatrix: [matrix_float4x4].init(repeating: matrix_float4x4(), count: LightShadow._maxLight),
            bias: [Float].init(repeating: 0, count: LightShadow._maxLight),
            intensity: [Float].init(repeating: 0, count: LightShadow._maxLight),
            radius: [Float].init(repeating: 0, count: LightShadow._maxLight),
            mapSize: [SIMD2<Float>].init(repeating: SIMD2<Float>(), count: LightShadow._maxLight),
            map: [MTLTexture].init()
    )

    private var _mapSize: Vector2
    private var _renderTarget: MTLRenderPassDescriptor

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

    init(_ light: Light, _ engine: Engine, _ width: Int = 512, _ height: Int = 512) {
        self.light = light

        _mapSize = Vector2(Float(width), Float(height))

        let descriptor = MTLTextureDescriptor()
        descriptor.width = width
        descriptor.height = height
        _renderTarget = MTLRenderPassDescriptor()
        _renderTarget.colorAttachments[0].texture = engine._hardwareRenderer.device.makeTexture(descriptor: descriptor)!
    }

    /// The RenderTarget corresponding to the shadow map.
    var renderTarget: MTLRenderPassDescriptor {
        get {
            _renderTarget
        }
    }

    /// Shadow map's color render texture.
    var map: MTLTexture {
        get {
            _renderTarget.colorAttachments[0].texture!
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
        LightShadow._combinedData.viewMatrix[lightIndex] = light.viewMatrix.elements
        LightShadow._combinedData.projectionMatrix[lightIndex] = projectionMatrix.elements
        LightShadow._combinedData.bias[lightIndex] = bias
        LightShadow._combinedData.intensity[lightIndex] = intensity
        LightShadow._combinedData.radius[lightIndex] = radius
        LightShadow._combinedData.mapSize[lightIndex] = mapSize.elements
        LightShadow._combinedData.map[lightIndex] = map
    }
}
