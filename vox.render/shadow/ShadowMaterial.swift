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
        targetBlendState.sourceColorBlendFactor = .DestinationColor
        targetBlendState.sourceAlphaBlendFactor = .DestinationColor
        targetBlendState.destinationColorBlendFactor = .Zero
        targetBlendState.destinationAlphaBlendFactor = .Zero
        renderState.depthState.compareFunction = CompareFunction.LessEqual

        renderQueueType = RenderQueueType.Transparent
    }
}
