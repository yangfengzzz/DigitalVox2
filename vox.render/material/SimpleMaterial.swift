//
//  SimpleMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Simple Material.
class SimpleMaterial: BaseMaterial {
    private static var _baseTextureProp = Shader.getPropertyByName("u_diffuseTexture")
    
    /// Base texture.
    var baseTexture: Texture2D? {
        get {
            return (shaderData.getTexture(SimpleMaterial._baseTextureProp) as! Texture2D)
        }
        set {
            shaderData.setTexture(SimpleMaterial._baseTextureProp, newValue!)
            if (newValue != nil) {
                shaderData.enableMacro(DIFFUSE_TEXTURE)
            } else {
                shaderData.disableMacro(DIFFUSE_TEXTURE)
            }
        }
    }
    
    init(_ engine: Engine) {
        super.init(engine, Shader.find("simple")!)
    }
}
