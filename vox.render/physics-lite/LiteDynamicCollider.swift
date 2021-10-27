//
//  LiteDynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// A dynamic collider can act with self-defined movement or physical force
class LiteDynamicCollider: LiteCollider, IDynamicCollider {
    var angularDamping: Float = 0
    var angularVelocity = Vector3()
    var isKinematic: Bool = false
    var linearDamping: Float = 0
    var linearVelocity = Vector3()
    var mass: Float = 0

    /// Initialize dynamic actor.
    /// - Parameters:
    ///   - position: The global position
    ///   - rotation: The global rotation
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _transform.setPosition(x: position.x, y: position.y, z: position.z)
        _transform.setRotationQuaternion(x: rotation.x, y: rotation.y, z: rotation.z, w: rotation.w)
    }


    func addForce(_ force: Vector3) {
        fatalError("Physics-lite don't support addForce. Use Physics-PhysX instead!")
    }


    func addTorque(_ torque: Vector3) {
        fatalError("Physics-lite don't support addTorque. Use Physics-PhysX instead!")
    }
}
