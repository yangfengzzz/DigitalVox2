//
//  PhysicsMaterialCombineMode.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Describes how physics materials of the colliding objects are combined.
enum PhysicsMaterialCombineMode: Int {
    /// Averages the friction/bounce of the two colliding materials.
    case Average
    /// Uses the smaller friction/bounce of the two colliding materials.
    case Minimum
    /// Multiplies the friction/bounce of the two colliding materials.
    case Multiply
    /// Uses the larger friction/bounce of the two colliding materials.
    case Maximum
}
