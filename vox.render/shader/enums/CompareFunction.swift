//
//  CompareFunction.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Depth/Stencil comparison function.
/// - Remark: Specifies a function that compares incoming pixel depth/stencil to the current depth/stencil buffer value.
enum CompareFunction {
    /// never pass.
    case Never
    /// pass if the incoming value is less than the depth/stencil buffer value.
    case Less
    /// pass if the incoming value equals the depth/stencil buffer value.
    case Equal
    /// pass if the incoming value is less than or equal to the depth/stencil buffer value.
    case LessEqual
    /// pass if the incoming value is greater than the depth/stencil buffer value.
    case Greater
    /// pass if the incoming value is not equal to the depth/stencil buffer value.
    case NotEqual
    /// pass if the incoming value is greater than or equal to the depth/stencil buffer value.
    case GreaterEqual
    /// always pass.
    case Always
}
