//
//  BlendMode.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Alpha blend mode.
enum BlendMode {
    /// SRC ALPHA * SRC + (1 - SRC ALPHA) * DEST
    case Normal
    /// SRC ALPHA * SRC + ONE * DEST
    case Additive
}
