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
    func setGravity(_ gravity: Vector3)

    /// Add IColliderShape into the manager.
    func addColliderShape(_ colliderShape: IColliderShape)

    /// Remove IColliderShape.
    func removeColliderShape(_ colliderShape: IColliderShape)

    /// Add ICollider into the manager.
    func addCollider(_ collider: ICollider)

    /// Remove ICollider.
    func removeCollider(_ collider: ICollider)

    /// Call on every frame to update pose of objects.
    func update(_ elapsedTime: Float)

    /// Casts a ray through the Scene and returns the first hit.
    func raycast(_ ray: Ray,
                 _ distance: Float,
                 _ outHitResult: ((Float, Float, Vector3, Vector3) -> Void)?) -> Bool
}
