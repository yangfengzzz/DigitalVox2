//
//  UnlitMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// Unlit Material.
class UnlitMaterial: BaseMaterial {
    private static var _baseColorProp = Shader.getPropertyByName("u_baseColor")
    private static var _baseTextureProp = Shader.getPropertyByName("u_baseTexture")
    private static var _tilingOffsetProp = Shader.getPropertyByName("u_tilingOffset")

    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getBytes(UnlitMaterial._baseColorProp) as! Color
        }
        set {
            let baseColor = shaderData.getBytes(UnlitMaterial._baseColorProp) as! Color
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor)
            }
        }
    }

    /// Base texture.
    var baseTexture: MTLTexture? {
        get {
            shaderData.getTexture(UnlitMaterial._baseTextureProp)
        }
        set {
            shaderData.setTexture(UnlitMaterial._baseTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(HAS_BASE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_BASE_TEXTURE)
            }
        }
    }

    /// Tiling and offset of main textures.
    var tilingOffset: Vector4 {
        get {
            shaderData.getBytes(UnlitMaterial._tilingOffsetProp) as! Vector4
        }
        set {
            let tilingOffset = shaderData.getBytes(UnlitMaterial._tilingOffsetProp) as! Vector4
            if (newValue !== tilingOffset) {
                newValue.cloneTo(target: tilingOffset)
            }
        }
    }

    /// Create a unlit material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("unlit")!)

        shaderData.enableMacro(OMIT_NORMAL)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setBytes(UnlitMaterial._baseColorProp, Color(1, 1, 1, 1))
        shaderData.setBytes(UnlitMaterial._tilingOffsetProp, Vector4(1, 1, 0, 0))
    }
}
