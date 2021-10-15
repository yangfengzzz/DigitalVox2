//
//  RenderState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Render state.
class RenderState {
    /// Blend state.
    var blendState: BlendState = BlendState()
    /// Depth state.
    var depthState: DepthState = DepthState()
    /// Stencil state.
    var stencilState: StencilState = StencilState()
    /// Raster state.
    var rasterState: RasterState = RasterState()
    
    internal func _apply(_ engine: Engine,
                         _ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor:MTLDepthStencilDescriptor) {
        let hardwareRenderer = engine._hardwareRenderer;
        blendState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
        depthState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
        stencilState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
        rasterState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
    }
}
