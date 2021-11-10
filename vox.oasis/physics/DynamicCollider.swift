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
    
    /// The linear damping of the dynamic collider.
    func setLinearDamping(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setLinearDamping(value)
    }

    /// The angular damping of the dynamic collider.
    func setAngularDamping(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setAngularDamping(value)
    }

    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    func setLinearVelocity(_ value: Vector3) {
        (_nativeCollider as! IDynamicCollider).setLinearVelocity(value)
    }

    /// The angular velocity vector of the dynamic collider measured in radians per second.
    func setAngularVelocity(_ value: Vector3) {
        (_nativeCollider as! IDynamicCollider).setAngularVelocity(value)
    }

    /// The mass of the dynamic collider.
    func setMass(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setMass(value)
    }

    /// The center of mass relative to the transform's origin.
    func setCenterOfMass(_ value: Vector3) {
        (_nativeCollider as! IDynamicCollider).setCenterOfMass(value)
    }

    /// The diagonal inertia tensor of mass relative to the center of mass.
    func setInertiaTensor(_ value: Vector3) {
        (_nativeCollider as! IDynamicCollider).setInertiaTensor(value)
    }

    /// The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
    func setMaxAngularVelocity(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setMaxAngularVelocity(value)
    }

    /// Maximum velocity of a collider when moving out of penetrating state.
    func setMaxDepenetrationVelocity(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setMaxDepenetrationVelocity(value)
    }

    /// The mass-normalized energy threshold, below which objects start going to sleep.
    func setSleepThreshold(_ value: Float) {
        (_nativeCollider as! IDynamicCollider).setSleepThreshold(value)
    }

    /// The solverIterations determines how accurately collider joints and collision contacts are resolved.
    func setSolverIterations(_ value: Int) {
        (_nativeCollider as! IDynamicCollider).setSolverIterations(value)
    }

    /// The colliders' collision detection mode.
    func setCollisionDetectionMode(value: CollisionDetectionMode) {
        (_nativeCollider as! IDynamicCollider).setCollisionDetectionMode(value: value)
    }

    /// Controls whether physics affects the dynamic collider.
    func setIsKinematic(_ value: Bool) {
        (_nativeCollider as! IDynamicCollider).setIsKinematic(value)
    }

    /// Controls whether physics will change the rotation of the object.
    func setFreezeRotation(_ value: Bool) {
        (_nativeCollider as! IDynamicCollider).setFreezeRotation(value)
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

    /// Applies force at position. As a result this will apply a torque and force on the object.
    func applyForceAtPosition(_ force: Vector3, _ pos: Vector3) {
        (_nativeCollider as! IDynamicCollider).addForceAtPosition(force, pos)
    }

    /// Moves the kinematic collider towards position.
    func movePosition(_ value: Vector3) {
        (_nativeCollider as! IDynamicCollider).movePosition(value)
    }

    /// Rotates the collider to rotation.
    func moveRotation(_ value: Quaternion) {
        (_nativeCollider as! IDynamicCollider).moveRotation(value)
    }

    /// Forces a collider to sleep at least one frame.
    func putToSleep() {
        (_nativeCollider as! IDynamicCollider).putToSleep()
    }

    /// Forces a collider to wake up.
    func wakeUp() {
        (_nativeCollider as! IDynamicCollider).wakeUp()
    }

    internal override func _onLateUpdate() {
        let transform = entity.transform!
        _nativeCollider.getWorldTransform(transform.worldPosition, transform.worldRotationQuaternion)
        _updateFlag.flag = false
    }
}
