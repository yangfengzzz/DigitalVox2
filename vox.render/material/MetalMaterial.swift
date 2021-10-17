//
//  SimpleMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Simple Material.
class MetalMaterial: BaseMaterial {
    private static var _diffuseColorProp = Shader.getPropertyByName("u_diffuseColor")
    private static var _baseTextureProp = Shader.getPropertyByName("u_diffuseTexture")
    
    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getColor(MetalMaterial._diffuseColorProp)!
        }
        set {
            let baseColor = shaderData.getColor(MetalMaterial._diffuseColorProp)!
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor)
            }
        }
    }
    
    /// Base texture.
    var baseTexture: Texture2D? {
        get {
            return (shaderData.getTexture(MetalMaterial._baseTextureProp) as! Texture2D)
        }
        set {
            shaderData.setTexture(MetalMaterial._baseTextureProp, newValue!)
            if (newValue != nil) {
                shaderData.enableMacro(DIFFUSE_TEXTURE)
            } else {
                shaderData.disableMacro(DIFFUSE_TEXTURE)
            }
        }
    }
    
    init(_ engine: Engine) {
        super.init(engine, Shader.find("simple")!)
        shaderData.setColor(MetalMaterial._diffuseColorProp, Color(1, 1, 1, 1))
    }
}
