//
//  SimpleMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

/// Simple Material.
class MetalMaterial: BaseMaterial {
    private static var _tilingOffsetProp = Shader.getPropertyByName("u_tilingOffset")
    private static var _normalTextureIntensityProp = Shader.getPropertyByName("u_normalIntensity")
    private static var _occlusionTextureIntensityProp = Shader.getPropertyByName("u_occlusionStrength")
    
    private static var _baseColorProp = Shader.getPropertyByName("u_baseColor")
    private static var _emissiveColorProp = Shader.getPropertyByName("u_emissiveColor")

    private static var _baseTextureProp = Shader.getPropertyByName("u_baseColorTexture")
    private static var _normalTextureProp = Shader.getPropertyByName("u_normalTexture")
    private static var _emissiveTextureProp = Shader.getPropertyByName("u_emissiveTexture")
    private static var _occlusionTextureProp = Shader.getPropertyByName("u_occlusionTexture")

    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getColor(MetalMaterial._baseColorProp)!
        }
        set {
            let baseColor = shaderData.getColor(MetalMaterial._baseColorProp)!
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor)
            }
        }
    }

    /// Base texture.
    var baseTexture: MTLTexture? {
        get {
            shaderData.getTexture(MetalMaterial._baseTextureProp)
        }
        set {
            if (newValue != nil) {
                shaderData.setTexture(MetalMaterial._baseTextureProp, newValue!)
                shaderData.enableMacro(HAS_BASE_COLORMAP)
            } else {
                shaderData.disableMacro(HAS_BASE_COLORMAP)
            }
        }
    }

    init(_ engine: Engine) {
        super.init(engine, Shader.find("simple")!)
        shaderData.setColor(MetalMaterial._baseColorProp, Color(0.7, 0.3, 0.3, 1))
    }
}
