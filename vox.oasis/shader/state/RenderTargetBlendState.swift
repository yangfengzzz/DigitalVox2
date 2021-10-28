//
//  RenderTargetBlendState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

/// The blend state of the render target.
class RenderTargetBlendState {
    /// Whether to enable blend.
    var enabled: Bool = false
    /// color (RGB) blend operation.
    var colorBlendOperation: MTLBlendOperation = .add
    /// alpha (A) blend operation.
    var alphaBlendOperation: MTLBlendOperation = .add
    /// color blend factor (RGB) for source.
    var sourceColorBlendFactor: MTLBlendFactor = .one
    /// alpha blend factor (A) for source.
    var sourceAlphaBlendFactor: MTLBlendFactor = .one
    /// color blend factor (RGB) for destination.
    var destinationColorBlendFactor: MTLBlendFactor = .zero
    /// alpha blend factor (A) for destination.
    var destinationAlphaBlendFactor: MTLBlendFactor = .zero
    /// color mask.
    var colorWriteMask: MTLColorWriteMask = .all
}
