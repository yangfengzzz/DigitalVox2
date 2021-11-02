//
//  AmbientLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

extension EnvMapLight:ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setVertexBytes(&value,
                                           length: MemoryLayout<EnvMapLight>.stride,
                                           index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setFragmentBytes(&value,
                                           length: MemoryLayout<EnvMapLight>.stride,
                                           index: shaderUniform.location)
    }
}

/// Ambient light.
class AmbientLight {
    private static var _diffuseSHProperty: ShaderProperty = Shader.getPropertyByName("u_env_sh")
    private static var _envMapProperty: ShaderProperty = Shader.getPropertyByName("u_envMapLight")
    private static var _specularTextureProperty: ShaderProperty = Shader.getPropertyByName("u_env_specularTexture")

    private var _scene: Scene
    private var _diffuseMode: DiffuseMode = .SolidColor
    private var _diffuseSphericalHarmonics: SphericalHarmonics3?
    private var _shArray: [SIMD3<Float>] = [SIMD3<Float>](repeating: SIMD3<Float>(), count: 9)
    private var _envMapLight = EnvMapLight()
    private var _specularReflection: MTLTexture?

    /// Diffuse mode of ambient light.
    var diffuseMode: DiffuseMode {
        get {
            _diffuseMode
        }
        set {
            _diffuseMode = newValue
            if (newValue == .SphericalHarmonics) {
                _scene.shaderData.enableMacro(HAS_SH)
            } else {
                _scene.shaderData.disableMacro(HAS_SH)
            }
        }
    }

    /// Diffuse reflection solid color.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SolidColor`.
    var diffuseSolidColor: Vector3 {
        get {
            Vector3(_envMapLight.diffuse.x, _envMapLight.diffuse.y, _envMapLight.diffuse.z)
        }
        set {
            if (newValue.elements != _envMapLight.diffuse) {
                _envMapLight.diffuse = newValue.elements
                _scene.shaderData.setBytes(AmbientLight._envMapProperty, _envMapLight)
            }
        }
    }

    /// Diffuse reflection spherical harmonics 3.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SphericalHarmonics`.
    var diffuseSphericalHarmonics: SphericalHarmonics3? {
        get {
            _diffuseSphericalHarmonics
        }
        set {
            _diffuseSphericalHarmonics = newValue
            let shaderData = _scene.shaderData

            if newValue != nil {
                shaderData.setBytes(AmbientLight._diffuseSHProperty, _preComputeSH(newValue!, &_shArray))
            }
        }
    }

    /// Diffuse reflection intensity.
    var diffuseIntensity: Float {
        get {
            _envMapLight.diffuseIntensity
        }
        set {
            _envMapLight.diffuseIntensity = newValue
            _scene.shaderData.setBytes(AmbientLight._envMapProperty, _envMapLight)
        }
    }

    /// Specular reflection texture.
    var specularTexture: MTLTexture? {
        get {
            _specularReflection
        }
        set {
            _specularReflection = newValue

            let shaderData = _scene.shaderData

            if (newValue != nil) {
                shaderData.setTexture(AmbientLight._specularTextureProperty, newValue!)
                shaderData.enableMacro(HAS_SPECULAR_ENV)

                _envMapLight.mipMapLevel = Int32(_specularReflection!.mipmapLevelCount)
                _scene.shaderData.setBytes(AmbientLight._envMapProperty, _envMapLight)
            } else {
                shaderData.disableMacro(HAS_SPECULAR_ENV)
            }
        }
    }

    /// Specular reflection intensity.
    var specularIntensity: Float {
        get {
            _envMapLight.specularIntensity
        }
        set {
            _envMapLight.specularIntensity = newValue
            _scene.shaderData.setBytes(AmbientLight._envMapProperty, _envMapLight)
        }
    }

    init(_ scene: Scene) {
        _scene = scene

        let shaderData = _scene.shaderData
        _envMapLight.diffuse = [1, 1, 1]
        _envMapLight.diffuseIntensity = 1.0
        _envMapLight.specularIntensity = 1.0
        shaderData.setBytes(AmbientLight._envMapProperty, _envMapLight)
    }

    private func _preComputeSH(_ sh: SphericalHarmonics3, _ out: inout [SIMD3<Float>]) -> [SIMD3<Float>] {
        /**
         * Basis constants
         *
         * 0: 1/2 * Math.sqrt(1 / Math.PI)
         *
         * 1: -1/2 * Math.sqrt(3 / Math.PI)
         * 2: 1/2 * Math.sqrt(3 / Math.PI)
         * 3: -1/2 * Math.sqrt(3 / Math.PI)
         *
         * 4: 1/2 * Math.sqrt(15 / Math.PI)
         * 5: -1/2 * Math.sqrt(15 / Math.PI)
         * 6: 1/4 * Math.sqrt(5 / Math.PI)
         * 7: -1/2 * Math.sqrt(15 / Math.PI)
         * 8: 1/4 * Math.sqrt(15 / Math.PI)
         */

        /**
         * Convolution kernel
         *
         * 0: Math.PI
         * 1: (2 * Math.PI) / 3
         * 2: Math.PI / 4
         */

        let src = sh.coefficients

        // l0
        out[0] = [src[0] * 0.886227, src[1] * 0.886227, src[2] * 0.886227] // kernel0 * basis0 = 0.886227

        // l1
        out[1] = [src[3] * -1.023327, src[4] * -1.023327, src[5] * -1.023327] // kernel1 * basis1 = -1.023327
        out[2] = [src[6] * 1.023327, src[7] * 1.023327, src[8] * 1.023327] // kernel1 * basis2 = 1.023327
        out[3] = [src[9] * -1.023327, src[10] * -1.023327, src[11] * -1.023327] // kernel1 * basis3 = -1.023327

        // l2
        out[4] = [src[12] * 0.858086, src[13] * 0.858086, src[14] * 0.858086] // kernel2 * basis4 = 0.858086
        out[5] = [src[15] * -0.858086, src[16] * -0.858086, src[17] * -0.858086] // kernel2 * basis5 = -0.858086
        out[6] = [src[18] * 0.247708, src[19] * 0.247708, src[20] * 0.247708] // kernel2 * basis6 = 0.247708
        out[7] = [src[21] * -0.858086, src[22] * -0.858086, src[23] * -0.858086] // kernel2 * basis7 = -0.858086
        out[8] = [src[24] * 0.429042, src[25] * 0.429042, src[26] * 0.429042] // kernel2 * basis8 = 0.429042

        return out
    }
}
