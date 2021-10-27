//
//  IPhysicsManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface for physics manager.
protocol IPhysicsManager {
    /// Set gravity.
    func setGravity(gravity: Vector3)

    /// Add IColliderShape into the manager.
    func addColliderShape(colliderShape: IColliderShape)

    /// Remove IColliderShape.
    func removeColliderShape(colliderShape: IColliderShape)

    /// Add ICollider into the manager.
    func addCollider(collider: ICollider)

    /// Remove ICollider.
    func removeCollider(collider: ICollider)

    /// Call on every frame to update pose of objects.
    func update(elapsedTime: Float)

    /// Casts a ray through the Scene and returns the first hit.
    func raycast(ray: Ray,
                 distance: Float,
                 outHitResult: ((Float, Float, Vector3, Vector3) -> Void)?) -> Bool
}
