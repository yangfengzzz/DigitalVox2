//
//  ContainmentType.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Defines how the bounding volumes intersects or contain one another.
enum ContainmentType {
    /// Indicates that there is no overlap between two bounding volumes.
    case Disjoint
    /// Indicates that one bounding volume completely contains another volume.
    case Contains
    /// Indicates that bounding volumes partially overlap one another.
    case Intersects
}
