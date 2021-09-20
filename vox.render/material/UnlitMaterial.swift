//
//  UnlitMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Unlit Material.
class UnlitMaterial: BaseMaterial {
    private static var _baseColorProp = Shader.getPropertyByName("u_baseColor")
    private static var _baseTextureProp = Shader.getPropertyByName("u_baseTexture")
    private static var _tilingOffsetProp = Shader.getPropertyByName("u_tilingOffset")

    /// Base color.
    var baseColor: Color {
        get {
            shaderData.getColor(UnlitMaterial._baseColorProp)!
        }
        set {
            let baseColor = shaderData.getColor(UnlitMaterial._baseColorProp)
            if (newValue !== baseColor) {
                newValue.cloneTo(target: baseColor!)
            }
        }
    }

    /// Base texture.
    var baseTexture: Texture2D? {
        get {
            (shaderData.getTexture(UnlitMaterial._baseTextureProp) as! Texture2D)
        }
        set {
            shaderData.setTexture(UnlitMaterial._baseTextureProp, newValue!)
            if newValue != nil {
                shaderData.enableMacro(BASE_TEXTURE)
            } else {
                shaderData.disableMacro(BASE_TEXTURE)
            }
        }
    }

    /// Tiling and offset of main textures.
    var tilingOffset: Vector4 {
        get {
            shaderData.getVector4(UnlitMaterial._tilingOffsetProp)!
        }
        set {
            let tilingOffset = shaderData.getVector4(UnlitMaterial._tilingOffsetProp)
            if (newValue !== tilingOffset) {
                newValue.cloneTo(target: tilingOffset!)
            }
        }
    }

    /// Create a unlit material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("unlit")!)

        shaderData.enableMacro(OMIT_NORMAL)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setColor(UnlitMaterial._baseColorProp, Color(1, 1, 1, 1))
        shaderData.setVector4(UnlitMaterial._tilingOffsetProp, Vector4(1, 1, 0, 0))
    }
}
