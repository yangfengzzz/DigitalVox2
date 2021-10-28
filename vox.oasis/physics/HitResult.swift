//
//  HitResult.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Structure used to get information back from a raycast or a sweep.
class HitResult {
    /// The collider that was hit.
    var entity: Entity? = nil
    /// The distance from the origin to the hit point.
    var distance: Float = 0
    /// The hit point of the collider that was hit in world space.
    var point: Vector3 = Vector3()
    /// The hit normal of the collider that was hit in world space. 
    var normal: Vector3 = Vector3()
}
