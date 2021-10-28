//
//  DepthState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Depth state.
class DepthState {
    /// Whether to enable the depth test. 
    var enabled: Bool = true
    /// Whether the depth value can be written.
    var writeEnabled: Bool = true
    /// Depth comparison function.
    var compareFunction: MTLCompareFunction = .less

    internal func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                         _ hardwareRenderer: MetalRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
    }

    internal func _platformApply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                                 _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                                 _ hardwareRenderer: MetalRenderer) {
        if (enabled) {
            // apply compare func.
            depthStencilDescriptor.depthCompareFunction = compareFunction

            // apply write enabled.
            depthStencilDescriptor.isDepthWriteEnabled = writeEnabled
        }
    }
}
