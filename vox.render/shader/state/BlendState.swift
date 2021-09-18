//
//  BlendState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

/// Blend state.
class BlendState {
    /// The blend state of the render target.
    var targetBlendState: RenderTargetBlendState = RenderTargetBlendState();
    /// Constant blend color.
    var blendColor: Color = Color(0, 0, 0, 0);
    /// Whether to use (Alpha-to-Coverage) technology.
    var alphaToCoverage: Bool = false;
}
