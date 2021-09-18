//
//  StencilOperation.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Stencil operation mode.
/// - Remark: sets the front and/or back-facing stencil test actions.
enum StencilOperation {
    /// Keeps the current value.
    case Keep
    /// Sets the stencil buffer value to 0.
    case Zero
    /// Sets the stencil buffer value to the reference value.
    case Replace
    /// Increments the current stencil buffer value. Clamps to the maximum representable unsigned value.
    case IncrementSaturate
    /// Decrements the current stencil buffer value. Clamps to 0.
    case DecrementSaturate
    /// Inverts the current stencil buffer value bitwise.
    case Invert
    /// Increments the current stencil buffer value. Wraps stencil buffer value to zero when incrementing the maximum representable unsigned value.
    case IncrementWrap
    /// Decrements the current stencil buffer value. Wraps stencil buffer value to the maximum representable unsigned value when decrementing a stencil buffer value of 0.
    case DecrementWrap
}
