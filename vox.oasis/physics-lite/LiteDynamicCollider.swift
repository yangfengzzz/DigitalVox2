//
//  LiteDynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// A dynamic collider can act with self-defined movement or physical force
class LiteDynamicCollider: LiteCollider, IDynamicCollider {
    /// Initialize dynamic actor.
    /// - Parameters:
    ///   - position: The global position
    ///   - rotation: The global rotation
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _transform.setPosition(x: position.x, y: position.y, z: position.z)
        _transform.setRotationQuaternion(x: rotation.x, y: rotation.y, z: rotation.z, w: rotation.w)
    }

    func setLinearDamping(_ value: Float) {
        fatalError("Physics-lite don't support setLinearDamping. Use Physics-PhysX instead!")
    }

    func setAngularDamping(_ value: Float) {
        fatalError("Physics-lite don't support setAngularDamping. Use Physics-PhysX instead!")
    }

    func setLinearVelocity(_ value: Vector3) {
        fatalError("Physics-lite don't support setLinearVelocity. Use Physics-PhysX instead!")
    }

    func setAngularVelocity(_ value: Vector3) {
        fatalError("Physics-lite don't support setAngularVelocity. Use Physics-PhysX instead!")
    }

    func setMass(_ value: Float) {
        fatalError("Physics-lite don't support setMass. Use Physics-PhysX instead!")
    }

    func setCenterOfMass(_ value: Vector3) {
        fatalError("Physics-lite don't support setCenterOfMass. Use Physics-PhysX instead!")
    }

    func setInertiaTensor(_ value: Vector3) {
        fatalError("Physics-lite don't support setInertiaTensor. Use Physics-PhysX instead!")
    }

    func setMaxAngularVelocity(_ value: Float) {
        fatalError("Physics-lite don't support setMaxAngularVelocity. Use Physics-PhysX instead!")
    }

    func setMaxDepenetrationVelocity(_ value: Float) {
        fatalError("Physics-lite don't support setMaxDepenetrationVelocity. Use Physics-PhysX instead!")
    }

    func setSleepThreshold(_ value: Float) {
        fatalError("Physics-lite don't support setSleepThreshold. Use Physics-PhysX instead!")
    }

    func setSolverIterations(_ value: Int) {
        fatalError("Physics-lite don't support setSolverIterations. Use Physics-PhysX instead!")
    }

    func setCollisionDetectionMode(value: CollisionDetectionMode) {
        fatalError("Physics-lite don't support setCollisionDetectionMode. Use Physics-PhysX instead!")
    }

    func setIsKinematic(_ value: Bool) {
        fatalError("Physics-lite don't support setIsKinematic. Use Physics-PhysX instead!")
    }

    func setFreezeRotation(_ value: Bool) {
        fatalError("Physics-lite don't support setFreezeRotation. Use Physics-PhysX instead!")
    }

    func addForce(_ force: Vector3) {
        fatalError("Physics-lite don't support addForce. Use Physics-PhysX instead!")
    }

    func addTorque(_ torque: Vector3) {
        fatalError("Physics-lite don't support addTorque. Use Physics-PhysX instead!")
    }

    func addForceAtPosition(_ force: Vector3, _ pos: Vector3) {
        fatalError("Physics-lite don't support addForceAtPosition. Use Physics-PhysX instead!")
    }

    func movePosition(_ value: Vector3) {
        fatalError("Physics-lite don't support movePosition. Use Physics-PhysX instead!")
    }

    func moveRotation(_ value: Quaternion) {
        fatalError("Physics-lite don't support moveRotation. Use Physics-PhysX instead!")
    }

    func putToSleep() {
        fatalError("Physics-lite don't support putToSleep. Use Physics-PhysX instead!")
    }

    func wakeUp() {
        fatalError("Physics-lite don't support wakeUp. Use Physics-PhysX instead!")
    }
}
