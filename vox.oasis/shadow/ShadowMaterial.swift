//
//  ShadowMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// Shadow material.
class ShadowMaterial: Material {
    init(_ engine: Engine) {
        super.init(engine, Shader.find("shadow")!)

        let targetBlendState = renderState.blendState.targetBlendState
        targetBlendState.enabled = true
        targetBlendState.sourceColorBlendFactor = .destinationColor
        targetBlendState.sourceAlphaBlendFactor = .destinationColor
        targetBlendState.destinationColorBlendFactor = .zero
        targetBlendState.destinationAlphaBlendFactor = .zero
        renderState.depthState.compareFunction = .lessEqual

        renderQueueType = RenderQueueType.Transparent
    }
}
