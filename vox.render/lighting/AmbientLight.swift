//
//  AmbientLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// Ambient light.
class AmbientLight {
    private static var _diffuseSHProperty: ShaderProperty = Shader.getPropertyByName("u_env_sh")
    private static var _envMapProperty: ShaderProperty = Shader.getPropertyByName("u_envMapLight")
    private static var _specularTextureProperty: ShaderProperty = Shader.getPropertyByName("u_env_specularTexture")

    private var _scene: Scene
    private var _diffuseMode: DiffuseMode = .SolidColor
    private var _diffuseSphericalHarmonics: SphericalHarmonics3?
    private var _shArray: [Float] = [Float](repeating: 0, count: 27)
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
                _scene.shaderData.setAny(AmbientLight._envMapProperty, _envMapLight)
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
                shaderData.setFloatArray(AmbientLight._diffuseSHProperty, _preComputeSH(newValue!, &_shArray))
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
            _scene.shaderData.setAny(AmbientLight._envMapProperty, _envMapLight)
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
                _scene.shaderData.setAny(AmbientLight._envMapProperty, _envMapLight)
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
            _scene.shaderData.setAny(AmbientLight._envMapProperty, _envMapLight)
        }
    }

    init(_ scene: Scene) {
        _scene = scene

        let shaderData = _scene.shaderData
        _envMapLight.diffuse = [0.212, 0.227, 0.259]
        _envMapLight.diffuseIntensity = 1.0
        _envMapLight.specularIntensity = 1.0
        shaderData.setAny(AmbientLight._envMapProperty, _envMapLight)
    }

    private func _preComputeSH(_ sh: SphericalHarmonics3, _ out: inout [Float]) -> [Float] {
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
        out[0] = src[0] * 0.886227 // kernel0 * basis0 = 0.886227
        out[1] = src[1] * 0.886227
        out[2] = src[2] * 0.886227

        // l1
        out[3] = src[3] * -1.023327 // kernel1 * basis1 = -1.023327
        out[4] = src[4] * -1.023327
        out[5] = src[5] * -1.023327
        out[6] = src[6] * 1.023327 // kernel1 * basis2 = 1.023327
        out[7] = src[7] * 1.023327
        out[8] = src[8] * 1.023327
        out[9] = src[9] * -1.023327 // kernel1 * basis3 = -1.023327
        out[10] = src[10] * -1.023327
        out[11] = src[11] * -1.023327

        // l2
        out[12] = src[12] * 0.858086 // kernel2 * basis4 = 0.858086
        out[13] = src[13] * 0.858086
        out[14] = src[14] * 0.858086
        out[15] = src[15] * -0.858086 // kernel2 * basis5 = -0.858086
        out[16] = src[16] * -0.858086
        out[17] = src[17] * -0.858086
        out[18] = src[18] * 0.247708 // kernel2 * basis6 = 0.247708
        out[19] = src[19] * 0.247708
        out[20] = src[20] * 0.247708
        out[21] = src[21] * -0.858086 // kernel2 * basis7 = -0.858086
        out[22] = src[22] * -0.858086
        out[23] = src[23] * -0.858086
        out[24] = src[24] * 0.429042 // kernel2 * basis8 = 0.429042
        out[25] = src[25] * 0.429042
        out[26] = src[26] * 0.429042

        return out
    }
}
