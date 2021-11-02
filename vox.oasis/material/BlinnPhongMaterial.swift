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
            shaderData.getBytes(BlinnPhongMaterial._diffuseColorProp) as! Color
        }
        set {
            let baseColor = shaderData.getBytes(BlinnPhongMaterial._diffuseColorProp) as! Color
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
            if (newValue != nil) {
                shaderData.setTexture(BlinnPhongMaterial._baseTextureProp, newValue!)
                shaderData.enableMacro(HAS_DIFFUSE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_DIFFUSE_TEXTURE)
            }
        }
    }

    /// Specular color.
    var specularColor: Color {
        get {
            shaderData.getBytes(BlinnPhongMaterial._specularColorProp) as! Color
        }
        set {
            let specularColor = shaderData.getBytes(BlinnPhongMaterial._specularColorProp) as! Color
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
            if newValue != nil {
                shaderData.setTexture(BlinnPhongMaterial._specularTextureProp, newValue!)
                shaderData.enableMacro(HAS_SPECULAR_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_SPECULAR_TEXTURE)
            }
        }
    }

    /// Emissive color.
    var emissiveColor: Color {
        get {
            shaderData.getBytes(BlinnPhongMaterial._emissiveColorProp) as! Color
        }
        set {
            let emissiveColor = shaderData.getBytes(BlinnPhongMaterial._emissiveColorProp) as! Color
            if (newValue !== emissiveColor) {
                newValue.cloneTo(target: emissiveColor)
            }
        }
    }

    /// Emissive texture.
    var emissiveTexture: MTLTexture? {
        get {
            shaderData.getTexture(BlinnPhongMaterial._emissiveTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(BlinnPhongMaterial._emissiveTextureProp, newValue!)
                shaderData.enableMacro(HAS_EMISSIVE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_EMISSIVE_TEXTURE)
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
                shaderData.enableMacro(HAS_NORMAL_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_NORMAL_TEXTURE)
            }
        }
    }

    /// Normal texture intensity.
    var normalIntensity: Float {
        get {
            shaderData.getBytes(BlinnPhongMaterial._normalIntensityProp) as! Float
        }
        set {
            shaderData.setBytes(BlinnPhongMaterial._normalIntensityProp, newValue)
        }
    }

    /// Set the specular reflection coefficient, the larger the value, the more convergent the specular reflection effect.
    var shininess: Float {
        get {
            shaderData.getBytes(BlinnPhongMaterial._shininessProp) as! Float
        }
        set {
            shaderData.setBytes(BlinnPhongMaterial._shininessProp, newValue)
        }
    }

    /// Tiling and offset of main textures.
    var tilingOffset: Vector4 {
        get {
            shaderData.getBytes(BlinnPhongMaterial._tilingOffsetProp) as! Vector4
        }
        set {
            let tilingOffset = shaderData.getBytes(BlinnPhongMaterial._tilingOffsetProp) as! Vector4
            if (newValue !== tilingOffset) {
                newValue.cloneTo(target: tilingOffset)
            }
        }
    }


    init(_ engine: Engine) {
        super.init(engine, Shader.find("blinn-phong")!)

        shaderData.enableMacro(NEED_WORLDPOS)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setBytes(BlinnPhongMaterial._diffuseColorProp, Color(1, 1, 1, 1))
        shaderData.setBytes(BlinnPhongMaterial._specularColorProp, Color(1, 1, 1, 1))
        shaderData.setBytes(BlinnPhongMaterial._emissiveColorProp, Color(0, 0, 0, 1))
        shaderData.setBytes(BlinnPhongMaterial._tilingOffsetProp, Vector4(1, 1, 0, 0))
        shaderData.setBytes(BlinnPhongMaterial._shininessProp, Float(16))
        shaderData.setBytes(BlinnPhongMaterial._normalIntensityProp, Float(1))
    }
}
