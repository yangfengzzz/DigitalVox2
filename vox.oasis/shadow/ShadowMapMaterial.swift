//
//  ShadowMapMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// Shadow Map material.
class ShadowMapMaterial: Material {
    init(_ engine: Engine) {
        super.init(engine, Shader.find("shadow-map")!)
        shaderData.enableMacro(NEED_GENERATE_SHADOW_MAP)
    }
}
