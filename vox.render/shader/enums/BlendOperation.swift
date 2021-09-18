//
//  BlendOperation.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Blend operation function.
/// - Remark: defines how a new pixel is combined with a pixel.
enum BlendOperation {
    /// src + dst.
    case Add
    /// src - dst.
    case Subtract
    /// dst - src.
    case ReverseSubtract
    /// Minimum of source and destination.
    case Min
    /// Maximum of source and destination.
    case Max
}
