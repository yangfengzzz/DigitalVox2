//
//  CullMode.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Culling mode.
/// - Remark: specifies whether or not front- and/or back-facing polygons can be culled.
enum CullMode {
    /// Disable culling.
    case Off
    /// cut the front-face of the polygons.
    case Front
    /// cut the back-face of the polygons.
    case Back
}
