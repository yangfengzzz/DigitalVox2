//
//  RenderQueueType.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Render queue type.
enum RenderQueueType: Int {
    /// Opaque queue.
    case Opaque = 1000
    /// Opaque queue, alpha cutoff.
    case AlphaTest = 2000
    /// Transparent queue, rendering from back to front to ensure correct rendering of transparent objects.
    case Transparent = 3000
}
