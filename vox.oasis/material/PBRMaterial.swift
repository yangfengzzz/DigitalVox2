//
//  PBRMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import Metal

/// PBR (Metallic-Roughness Workflow) Material.
class PBRMaterial: PBRBaseMaterial {
    private static var _metallicProp = Shader.getPropertyByName("u_metal")
    private static var _roughnessProp = Shader.getPropertyByName("u_roughness")
    
    private static var _metallicTextureProp = Shader.getPropertyByName("u_metallicTexture")
    private static var _roughnessTextureProp = Shader.getPropertyByName("u_roughnessTexture")

    /// Metallic.
    var metallic: Float {
        get {
            shaderData.getBytes(PBRMaterial._metallicProp) as! Float
        }
        set {
            shaderData.setBytes(PBRMaterial._metallicProp, newValue)
        }
    }

    /// Roughness.
    var roughness: Float {
        get {
            shaderData.getBytes(PBRMaterial._roughnessProp) as! Float
        }
        set {
            shaderData.setBytes(PBRMaterial._roughnessProp, newValue)
        }
    }

    /// Roughness metallic texture.
    var roughnessTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRMaterial._roughnessTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRMaterial._roughnessTextureProp, newValue!)
                shaderData.enableMacro(HAS_ROUGHNESSMAP)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESSMAP)
            }
        }
    }
    
    /// Roughness metallic texture.
    var metallicTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRMaterial._roughnessTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRMaterial._roughnessTextureProp, newValue!)
                shaderData.enableMacro(HAS_METALMAP)
            } else {
                shaderData.disableMacro(HAS_METALMAP)
            }
        }
    }

    /// Create a pbr metallic-roughness workflow material instance.
    /// - Parameter engine: Engine to which the material belongs
    override init(_ engine: Engine) {
        super.init(engine)
        shaderData.enableMacro(IS_METALLIC_WORKFLOW)
        shaderData.setBytes(PBRMaterial._metallicProp, Float(1.0))
        shaderData.setBytes(PBRMaterial._roughnessProp, Float(1.0))
    }
}
