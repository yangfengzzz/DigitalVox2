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

    private static var _specularGlossinessTextureProp = Shader.getPropertyByName("u_specularGlossinessTexture")

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
    /// - Remark: RGB is specular, A is glossiness
    var specularGlossinessTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRSpecularMaterial._specularGlossinessTextureProp)
        }
        set {
            shaderData.setTexture(PBRSpecularMaterial._specularGlossinessTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(HAS_SPECULARGLOSSINESSMAP)
            } else {
                shaderData.disableMacro(HAS_SPECULARGLOSSINESSMAP)
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
