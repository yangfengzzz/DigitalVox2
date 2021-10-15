//
//  BlendState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Blend state.
class BlendState {
    /// The blend state of the render target.
    var targetBlendState: RenderTargetBlendState = RenderTargetBlendState()
    /// Constant blend color.
    var blendColor: Color = Color(0, 0, 0, 0)
    /// Whether to use (Alpha-to-Coverage) technology.
    var alphaToCoverage: Bool = false

    internal func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                         _ hardwareRenderer: MetalRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
    }

    internal func _platformApply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                                 _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                                 _ hardwareRenderer: MetalRenderer) {
        let enabled = targetBlendState.enabled
        let colorBlendOperation = targetBlendState.colorBlendOperation
        let alphaBlendOperation = targetBlendState.alphaBlendOperation
        let sourceColorBlendFactor = targetBlendState.sourceColorBlendFactor
        let destinationColorBlendFactor = targetBlendState.destinationColorBlendFactor
        let sourceAlphaBlendFactor = targetBlendState.sourceAlphaBlendFactor
        let destinationAlphaBlendFactor = targetBlendState.destinationAlphaBlendFactor
        let colorWriteMask = targetBlendState.colorWriteMask

        if (enabled) {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        } else {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        }

        if (enabled) {
            // apply blend factor.
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = sourceColorBlendFactor
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = destinationColorBlendFactor
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = sourceAlphaBlendFactor
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = destinationAlphaBlendFactor


            // apply blend operation.
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = colorBlendOperation
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = alphaBlendOperation


            // apply blend color.
            hardwareRenderer.setBlendColor(blendColor.r, blendColor.g, blendColor.b, blendColor.a)
        }

        // apply color mask.
        pipelineDescriptor.colorAttachments[0].writeMask = colorWriteMask

        // apply alpha to coverage.
        if (alphaToCoverage) {
            pipelineDescriptor.isAlphaToCoverageEnabled = true
        } else {
            pipelineDescriptor.isAlphaToCoverageEnabled = false
        }
    }
}
