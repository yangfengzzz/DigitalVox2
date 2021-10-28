//
//  PlaneIntersectionType.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Defines the intersection between a plane and a bounding volume.
enum PlaneIntersectionType {
    /// There is no intersection, the bounding volume is in the back of the plane.
    case Back
    /// There is no intersection, the bounding volume is in the front of the plane.
    case Front
    /// The plane is intersected.
    case Intersecting
}
