//
//  TextureCubeFace.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Define the face of the cube texture.
enum TextureCubeFace: Int {
    /// Positive X face for a cube-mapped texture.
    case PositiveX = 0
    /// Negative X face for a cube-mapped texture.
    case NegativeX = 1
    /// Positive Y face for a cube-mapped texture.
    case PositiveY = 2
    /// Negative Y face for a cube-mapped texture.
    case NegativeY = 3
    /// Positive Z face for a cube-mapped texture.
    case PositiveZ = 4
    /// Negative Z face for a cube-mapped texture.
    case NegativeZ = 5
}
