//
//  PBRBaseMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// PBR (Physically-Based Rendering) Material.
class PBRBaseMaterial: BaseMaterial {
    private static var _baseColorProp = Shader.getPropertyByName("u_baseColor")
    private static var _emissiveColorProp = Shader.getPropertyByName("u_emissiveColor")
    private static var _tilingOffsetProp = Shader.getPropertyByName("u_tilingOffset")
    private static var _baseTextureProp = Shader.getPropertyByName("u_baseColorSampler")
    private static var _normalTextureProp = Shader.getPropertyByName("u_normalTexture")
    private static var _normalTextureIntensityProp = Shader.getPropertyByName("u_normalIntensity")
    private static var _occlusionTextureIntensityProp = Shader.getPropertyByName("u_occlusionStrength")

    private static var _emissiveTextureProp = Shader.getPropertyByName("u_emissiveSampler")
    private static var _occlusionTextureProp = Shader.getPropertyByName("u_occlusionSampler")


    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getColor(PBRBaseMaterial._baseColorProp)!
        }
        set {
            let baseColor = shaderData.getColor(PBRBaseMaterial._baseColorProp)
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor!)
            }
        }
    }

    /// Base texture.
    var baseTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRBaseMaterial._baseTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRBaseMaterial._baseTextureProp, newValue!)
                shaderData.enableMacro(HAS_BASE_COLORMAP)
            } else {
                shaderData.disableMacro(HAS_BASE_COLORMAP)
            }
        }
    }

    /// Normal texture.
    var normalTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRBaseMaterial._normalTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRBaseMaterial._normalTextureProp, newValue!)
                shaderData.enableMacro(HAS_NORMAL_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_NORMAL_TEXTURE)
            }
        }
    }

    /// Normal texture intensity.
    var normalTextureIntensity: Float {
        get {
            shaderData.getFloat(PBRBaseMaterial._normalTextureIntensityProp)!
        }
        set {
            shaderData.setFloat(PBRBaseMaterial._normalTextureIntensityProp, newValue)
            shaderData.setFloat("u_normalIntensity", newValue)
        }
    }

    /// Emissive color.
    var emissiveColor: Color {
        get {
            shaderData.getColor(PBRBaseMaterial._emissiveColorProp)!
        }
        set {
            let emissiveColor = shaderData.getColor(PBRBaseMaterial._emissiveColorProp)
            if (newValue !== emissiveColor) {
                newValue.cloneTo(target: emissiveColor!)
            }
        }
    }

    /// Emissive texture.
    var emissiveTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRBaseMaterial._emissiveTextureProp)
        }
        set {
            shaderData.setTexture(PBRBaseMaterial._emissiveTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(HAS_EMISSIVEMAP)
            } else {
                shaderData.disableMacro(HAS_EMISSIVEMAP)
            }
        }
    }

    /// Occlusion texture.
    var occlusionTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRBaseMaterial._occlusionTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRBaseMaterial._occlusionTextureProp, newValue!)
                shaderData.enableMacro(HAS_OCCLUSIONMAP)
            } else {
                shaderData.disableMacro(HAS_OCCLUSIONMAP)
            }
        }
    }

    /// Occlusion texture intensity.
    var occlusionTextureIntensity: Float {
        get {
            shaderData.getFloat(PBRBaseMaterial._occlusionTextureIntensityProp)!
        }
        set {
            shaderData.setFloat(PBRBaseMaterial._occlusionTextureIntensityProp, newValue)
        }
    }

    /// Tiling and offset of main textures.
    var tilingOffset: Vector4 {
        get {
            shaderData.getVector4(PBRBaseMaterial._tilingOffsetProp)!
        }
        set {
            let tilingOffset = shaderData.getVector4(PBRBaseMaterial._tilingOffsetProp)
            if (newValue !== tilingOffset) {
                newValue.cloneTo(target: tilingOffset!)
            }
        }
    }


    /// Create a pbr base material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("pbr")!)


        shaderData.enableMacro(NEED_WORLDPOS)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setColor(PBRBaseMaterial._baseColorProp, Color(1, 1, 1, 1))
        shaderData.setColor(PBRBaseMaterial._emissiveColorProp, Color(0, 0, 0, 1))
        shaderData.setVector4(PBRBaseMaterial._tilingOffsetProp, Vector4(1, 1, 0, 0))

        shaderData.setFloat(PBRBaseMaterial._normalTextureIntensityProp, 1)
        shaderData.setFloat(PBRBaseMaterial._occlusionTextureIntensityProp, 1)
        
        shaderData.disableMacro(HAS_BASE_COLORMAP)
    }
}
