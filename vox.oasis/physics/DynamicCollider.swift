//
//  DynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// A dynamic collider can act with self-defined movement or physical force.
class DynamicCollider: Collider {
    required init(_ entity: Entity) {
        super.init(entity)
        let transform = entity.transform!
        _nativeCollider = PhysicsManager._nativePhysics.createDynamicCollider(
                transform.worldPosition,
                transform.worldRotationQuaternion
        )
    }

    /// Apply a force to the DynamicCollider.
    /// - Parameter force: The force make the collider move
    func applyForce(_ force: Vector3) {
        (_nativeCollider as! IDynamicCollider).addForce(force)
    }

    /// Apply a torque to the DynamicCollider.
    /// - Parameter torque: The force make the collider rotate
    func applyTorque(_ torque: Vector3) {
        (_nativeCollider as! IDynamicCollider).addTorque(torque)
    }

    internal override func _onLateUpdate() {
        let transform = entity.transform!
        _nativeCollider.getWorldTransform(transform.worldPosition, transform.worldRotationQuaternion)
        _updateFlag.flag = false
    }
}
