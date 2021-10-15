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
                         _ hardwareRenderer: MetalRenderer,
                         _ lastRenderState: RenderState) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer, lastRenderState.blendState)
    }
    
    internal func _platformApply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                         _ hardwareRenderer: MetalRenderer,
                         _ lastState: BlendState) {
        let lastTargetBlendState = lastState.targetBlendState
        let enabled = targetBlendState.enabled
        let colorBlendOperation = targetBlendState.colorBlendOperation
        let alphaBlendOperation = targetBlendState.alphaBlendOperation
        let sourceColorBlendFactor = targetBlendState.sourceColorBlendFactor
        let destinationColorBlendFactor = targetBlendState.destinationColorBlendFactor
        let sourceAlphaBlendFactor = targetBlendState.sourceAlphaBlendFactor
        let destinationAlphaBlendFactor = targetBlendState.destinationAlphaBlendFactor
        let colorWriteMask = targetBlendState.colorWriteMask

        if (enabled != lastTargetBlendState.enabled) {
            if (enabled) {
                pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            } else {
                pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
            }
            lastTargetBlendState.enabled = enabled
        }

        if (enabled) {
            // apply blend factor.
            if (sourceColorBlendFactor != lastTargetBlendState.sourceColorBlendFactor ||
                    destinationColorBlendFactor != lastTargetBlendState.destinationColorBlendFactor ||
                    sourceAlphaBlendFactor != lastTargetBlendState.sourceAlphaBlendFactor ||
                    destinationAlphaBlendFactor != lastTargetBlendState.destinationAlphaBlendFactor) {
                pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = sourceColorBlendFactor
                pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = destinationColorBlendFactor
                pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = sourceAlphaBlendFactor
                pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = destinationAlphaBlendFactor

                lastTargetBlendState.sourceColorBlendFactor = sourceColorBlendFactor
                lastTargetBlendState.destinationColorBlendFactor = destinationColorBlendFactor
                lastTargetBlendState.sourceAlphaBlendFactor = sourceAlphaBlendFactor
                lastTargetBlendState.destinationAlphaBlendFactor = destinationAlphaBlendFactor
            }

            // apply blend operation.
            if (colorBlendOperation != lastTargetBlendState.colorBlendOperation ||
                    alphaBlendOperation != lastTargetBlendState.alphaBlendOperation) {
                pipelineDescriptor.colorAttachments[0].rgbBlendOperation = colorBlendOperation
                pipelineDescriptor.colorAttachments[0].alphaBlendOperation = alphaBlendOperation

                lastTargetBlendState.colorBlendOperation = colorBlendOperation
                lastTargetBlendState.alphaBlendOperation = alphaBlendOperation
            }
            
            // apply blend color.
            if (!Color.equals(left: lastState.blendColor, right: blendColor)) {
                hardwareRenderer.setBlendColor(blendColor.r, blendColor.g, blendColor.b, blendColor.a)
                blendColor.cloneTo(target: lastState.blendColor)
            }
        }

        // apply color mask.
        if (colorWriteMask != lastTargetBlendState.colorWriteMask) {
            pipelineDescriptor.colorAttachments[0].writeMask = colorWriteMask
            lastTargetBlendState.colorWriteMask = colorWriteMask
        }

        // apply alpha to coverage.
        if (alphaToCoverage != lastState.alphaToCoverage) {
            if (alphaToCoverage) {
                pipelineDescriptor.isAlphaToCoverageEnabled = true
            } else {
                pipelineDescriptor.isAlphaToCoverageEnabled = false
            }
            lastState.alphaToCoverage = alphaToCoverage
        }
    }
}
