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
    private static var _metallicRoughnessTextureProp = Shader.getPropertyByName("u_metallicRoughnessSampler")

    /// Metallic.
    var metallic: Float {
        get {
            shaderData.getFloat(PBRMaterial._metallicProp)!
        }
        set {
            shaderData.setFloat(PBRMaterial._metallicProp, newValue)
        }
    }

    /// Roughness.
    var roughness: Float {
        get {
            shaderData.getFloat(PBRMaterial._roughnessProp)!
        }
        set {
            shaderData.setFloat(PBRMaterial._roughnessProp, newValue)
        }
    }

    /// Roughness metallic texture.
    /// - Remark: G channel is roughness, B channel is metallic
    var roughnessMetallicTexture: MTLTexture? {
        get {
            shaderData.getTexture(PBRMaterial._metallicRoughnessTextureProp)
        }
        set {
            if newValue != nil {
                shaderData.setTexture(PBRMaterial._metallicRoughnessTextureProp, newValue!)
                shaderData.enableMacro(HAS_METALROUGHNESSMAP)
            } else {
                shaderData.disableMacro(HAS_METALROUGHNESSMAP)
            }
        }
    }

    /// Create a pbr metallic-roughness workflow material instance.
    /// - Parameter engine: Engine to which the material belongs
    override init(_ engine: Engine) {
        super.init(engine)
        shaderData.enableMacro(IS_METALLIC_WORKFLOW)
        shaderData.setFloat(PBRMaterial._metallicProp, 1.0)
        shaderData.setFloat(PBRMaterial._roughnessProp, 1.0)
    }
}
