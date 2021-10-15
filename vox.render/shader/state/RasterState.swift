//
//  RasterState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Raster state.
class RasterState {
    /// Specifies whether or not front- and/or back-facing polygons can be culled. */
    var cullMode: MTLCullMode = .front
    /// The multiplier by which an implementation-specific value is multiplied with to create a constant depth offset. */
    var depthBias: Float = 0
    /// The scale factor for the variable depth offset for each polygon. */
    var slopeScaledDepthBias: Float = 0

    internal var _cullFaceEnable: Bool = true

    internal func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                         _ hardwareRenderer: MetalRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
    }

    internal func _platformApply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                                 _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                                 _ hardwareRenderer: MetalRenderer) {
        let cullFaceEnable = cullMode != .none

        // apply front face.
        if (cullFaceEnable) {
            hardwareRenderer.setCullMode(cullMode)
        }

        // apply polygonOffset.
        if (depthBias != 0 || slopeScaledDepthBias != 0) {
            hardwareRenderer.setDepthBias(depthBias, slopeScaledDepthBias, 0)
        }
    }
}
