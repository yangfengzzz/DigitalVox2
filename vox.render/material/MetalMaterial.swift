//
//  SimpleMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

/// Simple Material.
class MetalMaterial: BaseMaterial {
    private static var _baseColorProp = Shader.getPropertyByName("u_baseColor")
    private static var _baseTextureProp = Shader.getPropertyByName("u_baseTexture")

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
                shaderData.enableMacro(HAS_BASE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_BASE_TEXTURE)
            }
        }
    }

    init(_ engine: Engine) {
        super.init(engine, Shader.find("simple")!)
        shaderData.setColor(MetalMaterial._baseColorProp, Color(0.7, 0.3, 0.3, 1))
    }
}
