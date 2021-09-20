//
//  RenderBufferDepthFormat.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Render buffer depth format enumeration.
enum RenderBufferDepthFormat:Int {
    /// Render to depth buffer,engine will automatically select the supported precision.
    case Depth = 0
    /// Render to depth stencil buffer, engine will automatically select the supported precision.
    case DepthStencil = 1
    /// Render to stencil buffer.
    case Stencil = 2
    /// Force 16-bit depth buffer.
    case Depth16 = 3
    /// Force 24-bit depth buffer.
    case Depth24 = 4
    /// Force 32-bit depth buffer.
    case Depth32 = 5
    /// Force 16-bit depth + 8-bit stencil buffer.
    case Depth24Stencil8 = 6
    /// Force 32-bit depth + 8-bit stencil buffer.
    case Depth32Stencil8 = 7
}
