//
//  CameraClearFlags.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/9.
//

import Foundation

/// Camera clear flags enumeration.
enum CameraClearFlags:Int {
    /// Clear depth and color from background.
    case DepthColor = 0
    /// Clear depth only.
    case Depth = 1
    /// Do nothing.
    case None = 2
}
