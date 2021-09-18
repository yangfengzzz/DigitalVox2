//
//  ColorWriteMask.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation


/// Set which color channels can be rendered to frame buffer.
/// - Remark: enumeration can be combined using bit operations.
enum ColorWriteMask:Int {
    /// Do not write to any channel. */
    case None = 0
    /// Write to the red channel. */
    case Red = 0x1
    /// Write to the green channel. */
    case Green = 0x2
    /// Write to the blue channel. */
    case Blue = 0x4
    /// Write to the alpha channel. */
    case Alpha = 0x8
    /// Write to all channel. */
    case All = 0xf
}
