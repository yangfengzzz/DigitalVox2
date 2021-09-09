//
//  CameraClearFlags.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/9.
//

import Foundation

/// Camera clear flags enumeration.
enum CameraClearFlags {
    /// Clear depth and color from background.
    case DepthColor
    /// Clear depth only.
    case Depth
    /// Do nothing.
    case None
}
