//
//  RenderTargetBlendState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// The blend state of the render target.
class RenderTargetBlendState {
    /// Whether to enable blend.
    var enabled: Bool = false
    /// color (RGB) blend operation.
    var colorBlendOperation: BlendOperation = BlendOperation.Add
    /// alpha (A) blend operation.
    var alphaBlendOperation: BlendOperation = BlendOperation.Add
    /// color blend factor (RGB) for source.
    var sourceColorBlendFactor: BlendFactor = BlendFactor.One
    /// alpha blend factor (A) for source.
    var sourceAlphaBlendFactor: BlendFactor = BlendFactor.One
    /// color blend factor (RGB) for destination.
    var destinationColorBlendFactor: BlendFactor = BlendFactor.Zero
    /// alpha blend factor (A) for destination.
    var destinationAlphaBlendFactor: BlendFactor = BlendFactor.Zero
    /// color mask.
    var colorWriteMask: ColorWriteMask = ColorWriteMask.All
}
