//
//  ICollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics collider.
protocol ICollider {
    /// Set global transform of collider.
    func setWorldTransform(_ position: Vector3, _ rotation: Quaternion)

    /// Get global transform of collider.
    func getWorldTransform(_ outPosition: Vector3, _ outRotation: Quaternion)

    /// Add collider shape on collider.
    func addShape(_ shape: IColliderShape)

    /// Remove collider shape on collider.
    func removeShape(_ shape: IColliderShape)
}
