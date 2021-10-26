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
            shaderData.getColor(PBRSpecularMaterial._specularColorProp)!
        }
        set {
            let specularColor = shaderData.getColor(PBRSpecularMaterial._specularColorProp)
            if (newValue !== specularColor) {
                newValue.cloneTo(target: specularColor!)
            }
        }
    }

    /// Glossiness.
    var glossiness: Float {
        get {
            shaderData.getFloat(PBRSpecularMaterial._glossinessProp)!
        }
        set {
            shaderData.setFloat(PBRSpecularMaterial._glossinessProp, newValue)
        }
    }

    /// Specular glossiness texture.
    var glossinessTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRSpecularMaterial._glossinessTextureProp)
        }
        set {
            shaderData.setTexture(PBRSpecularMaterial._glossinessTextureProp, newValue!)
            if newValue != nil {
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
            shaderData.setTexture(PBRSpecularMaterial._specularTextureProp, newValue!)
            if newValue != nil {
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

        shaderData.setColor(PBRSpecularMaterial._specularColorProp, Color(1, 1, 1, 1))
        shaderData.setFloat(PBRSpecularMaterial._glossinessProp, 1.0)
    }
}
