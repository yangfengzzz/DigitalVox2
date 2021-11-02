//
//  PBRSpecularMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// PBR (Specular-Glossiness Workflow) Material.
class PBRSpecularMaterial: PBRBaseMaterial {
    private static var _glossinessProp = Shader.getPropertyByName("u_glossinessFactor")

    private static var _specularColorProp = Shader.getPropertyByName("u_specularColor")

    private static var _glossinessTextureProp = Shader.getPropertyByName("u_glossinessTexture")
    private static var _specularTextureProp = Shader.getPropertyByName("u_specularTexture")
    
    /// Specular color.
    var specularColor: Color {
        get {
            shaderData.getBytes(PBRSpecularMaterial._specularColorProp) as! Color
        }
        set {
            let specularColor = shaderData.getBytes(PBRSpecularMaterial._specularColorProp) as! Color
            if (newValue !== specularColor) {
                newValue.cloneTo(target: specularColor)
            }
        }
    }

    /// Glossiness.
    var glossiness: Float {
        get {
            shaderData.getBytes(PBRSpecularMaterial._glossinessProp) as! Float
        }
        set {
            shaderData.setBytes(PBRSpecularMaterial._glossinessProp, newValue)
        }
    }

    /// Specular glossiness texture.
    var glossinessTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRSpecularMaterial._glossinessTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRSpecularMaterial._glossinessTextureProp, newValue!)
                shaderData.enableMacro(HAS_GLOSSINESSMAP)
            } else {
                shaderData.disableMacro(HAS_GLOSSINESSMAP)
            }
        }
    }
    
    /// Specular glossiness texture.
    var specularTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRSpecularMaterial._specularTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRSpecularMaterial._specularTextureProp, newValue!)
                shaderData.enableMacro(HAS_SPECULARMAP)
            } else {
                shaderData.disableMacro(HAS_SPECULARMAP)
            }
        }
    }

    /// Create a pbr specular-glossiness workflow material instance.
    /// - Parameter engine: Engine to which the material belongs
    override init(_ engine: Engine) {
        super.init(engine)

        shaderData.setBytes(PBRSpecularMaterial._specularColorProp, Color(1, 1, 1, 1))
        shaderData.setBytes(PBRSpecularMaterial._glossinessProp, Float(1.0))
    }
}
