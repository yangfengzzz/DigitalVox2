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
    func setWorldTransform(position: Vector3, rotation: Quaternion)

    /// Get global transform of collider.
    func getWorldTransform(outPosition: Vector3, outRotation: Quaternion)

    /// Add collider shape on collider.
    func addShape(shape: IColliderShape)

    /// Remove collider shape on collider.
    func removeShape(shape: IColliderShape)
}
