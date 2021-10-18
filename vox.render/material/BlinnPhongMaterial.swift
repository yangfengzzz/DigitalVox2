//
//  BlinnPhongMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// Blinn-phong Material.
class BlinnPhongMaterial: BaseMaterial {
    private static var _diffuseColorProp = Shader.getPropertyByName("u_diffuseColor")
    private static var _specularColorProp = Shader.getPropertyByName("u_specularColor")
    private static var _emissiveColorProp = Shader.getPropertyByName("u_emissiveColor")
    private static var _tilingOffsetProp = Shader.getPropertyByName("u_tilingOffset")
    private static var _shininessProp = Shader.getPropertyByName("u_shininess")
    private static var _normalIntensityProp = Shader.getPropertyByName("u_normalIntensity")

    private static var _baseTextureProp = Shader.getPropertyByName("u_diffuseTexture")
    private static var _specularTextureProp = Shader.getPropertyByName("u_specularTexture")
    private static var _emissiveTextureProp = Shader.getPropertyByName("u_emissiveTexture")
    private static var _normalTextureProp = Shader.getPropertyByName("u_normalTexture")

    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getColor(BlinnPhongMaterial._diffuseColorProp)!
        }
        set {
            let baseColor = shaderData.getColor(BlinnPhongMaterial._diffuseColorProp)!
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor)
            }
        }
    }

    /// Base texture.
    var baseTexture: MTLTexture? {
        get {
            shaderData.getTexture(BlinnPhongMaterial._baseTextureProp)
        }
        set {
            shaderData.setTexture(BlinnPhongMaterial._baseTextureProp, newValue!)
            if (newValue != nil) {
                shaderData.enableMacro(DIFFUSE_TEXTURE)
            } else {
                shaderData.disableMacro(DIFFUSE_TEXTURE)
            }
        }
    }

    /// Specular color.
    var specularColor: Color {
        get {
            shaderData.getColor(BlinnPhongMaterial._specularColorProp)!
        }
        set {
            let specularColor = shaderData.getColor(BlinnPhongMaterial._specularColorProp)!
            if (newValue !== specularColor) {
                newValue.cloneTo(target: specularColor)
            }
        }
    }

    /// Specular texture.
    var specularTexture: MTLTexture? {
        get {
            shaderData.getTexture(BlinnPhongMaterial._specularTextureProp)
        }
        set {
            shaderData.setTexture(BlinnPhongMaterial._specularTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(SPECULAR_TEXTURE)
            } else {
                shaderData.disableMacro(SPECULAR_TEXTURE)
            }
        }
    }

    /// Emissive color.
    var emissiveColor: Color {
        get {
            shaderData.getColor(BlinnPhongMaterial._emissiveColorProp)!
        }
        set {
            let emissiveColor = shaderData.getColor(BlinnPhongMaterial._emissiveColorProp)
            if (newValue !== emissiveColor) {
                newValue.cloneTo(target: emissiveColor!)
            }
        }
    }

    /// Emissive texture.
    var emissiveTexture: MTLTexture? {
        get {
            shaderData.getTexture(BlinnPhongMaterial._emissiveTextureProp)
        }
        set {
            shaderData.setTexture(BlinnPhongMaterial._emissiveTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(EMISSIVE_TEXTURE)
            } else {
                shaderData.disableMacro(EMISSIVE_TEXTURE)
            }
        }
    }

    /// Normal texture.
    var normalTexture: MTLTexture? {
        get {
            shaderData.getTexture(BlinnPhongMaterial._normalTextureProp)
        }
        set {
            shaderData.setTexture(BlinnPhongMaterial._normalTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(NORMAL_TEXTURE)
            } else {
                shaderData.disableMacro(NORMAL_TEXTURE)
            }
        }
    }

    /// Normal texture intensity.
    var normalIntensity: Float {
        get {
            shaderData.getFloat(BlinnPhongMaterial._normalIntensityProp)!
        }
        set {
            shaderData.setFloat(BlinnPhongMaterial._normalIntensityProp, newValue)
        }
    }

    /// Set the specular reflection coefficient, the larger the value, the more convergent the specular reflection effect.
    var shininess: Float {
        get {
            shaderData.getFloat(BlinnPhongMaterial._shininessProp)!
        }
        set {
            shaderData.setFloat(BlinnPhongMaterial._shininessProp, newValue)
        }
    }

    /// Tiling and offset of main textures.
    var tilingOffset: Vector4 {
        get {
            shaderData.getVector4(BlinnPhongMaterial._tilingOffsetProp)!
        }
        set {
            let tilingOffset = shaderData.getVector4(BlinnPhongMaterial._tilingOffsetProp)
            if (newValue !== tilingOffset) {
                newValue.cloneTo(target: tilingOffset!)
            }
        }
    }


    init(_ engine: Engine) {
        super.init(engine, Shader.find("blinn-phong")!)

        shaderData.enableMacro(NEED_WORLDPOS)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setColor(BlinnPhongMaterial._diffuseColorProp, Color(1, 1, 1, 1))
        shaderData.setColor(BlinnPhongMaterial._specularColorProp, Color(1, 1, 1, 1))
        shaderData.setColor(BlinnPhongMaterial._emissiveColorProp, Color(0, 0, 0, 1))
        shaderData.setVector4(BlinnPhongMaterial._tilingOffsetProp, Vector4(1, 1, 0, 0))
        shaderData.setFloat(BlinnPhongMaterial._shininessProp, 16)
        shaderData.setFloat(BlinnPhongMaterial._normalIntensityProp, 1)
    }
}
