//
//  BlendFactor.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Blend factor.
/// - Remark: defines which function is used for blending pixel arithmetic
enum BlendFactor {
    /// (0, 0, 0, 0)
    case Zero
    /// (1, 1, 1, 1)
    case One
    /// (Rs, Gs, Bs, As)
    case SourceColor
    /// (1 - Rs, 1 - Gs, 1 - Bs, 1 - As)
    case OneMinusSourceColor
    /// (Rd, Gd, Bd, Ad)
    case DestinationColor
    /// (1 - Rd, 1 - Gd, 1 - Bd, 1 - Ad)
    case OneMinusDestinationColor
    /// (As, As, As, As)
    case SourceAlpha
    /// (1 - As, 1 - As, 1 - As, 1 - As)
    case OneMinusSourceAlpha
    /// (Ad, Ad, Ad, Ad)
    case DestinationAlpha
    /// (1 - Ad, 1 - Ad, 1 - Ad, 1 - Ad)
    case OneMinusDestinationAlpha
    /// (min(As, 1 - Ad), min(As, 1 - Ad), min(As, 1 - Ad), 10)
    case SourceAlphaSaturate
    /// (Rc, Gc, Bc, Ac)
    case BlendColor
    /// (1 - Rc, 1 - Gc, 1 - Bc, 1 - Ac)
    case OneMinusBlendColor
}
