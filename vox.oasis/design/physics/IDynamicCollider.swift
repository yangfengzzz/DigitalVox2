//
//  IDynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics dynamic collider.
protocol IDynamicCollider: ICollider {
    /// The linear damping of the dynamic collider.
    func setLinearDamping(_ value: Float)

    /// The angular damping of the dynamic collider.
    func setAngularDamping(_ value: Float)

    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    func setLinearVelocity(_ value: Vector3)

    /// The angular velocity vector of the dynamic collider measured in radians per second.
    func setAngularVelocity(_ value: Vector3)

    /// The mass of the dynamic collider.
    func setMass(_ value: Float)

    /// The center of mass relative to the transform's origin.
    func setCenterOfMass(_ value: Vector3)

    /// The diagonal inertia tensor of mass relative to the center of mass.
    func setInertiaTensor(_ value: Vector3)

    /// The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
    func setMaxAngularVelocity(_ value: Float)

    /// Maximum velocity of a collider when moving out of penetrating state.
    func setMaxDepenetrationVelocity(_ value: Float)

    /// The mass-normalized energy threshold, below which objects start going to sleep.
    func setSleepThreshold(_ value: Float)

    /// The solverIterations determines how accurately collider joints and collision contacts are resolved.
    func setSolverIterations(_ value: Int)

    /// The colliders' collision detection mode.
    func setCollisionDetectionMode(value: CollisionDetectionMode)

    /// Controls whether physics affects the dynamic collider.
    func setIsKinematic(_ value: Bool)

    /// Controls whether physics will change the rotation of the object.
    func setFreezeRotation(_ value: Bool)

    /// Apply a force to the dynamic collider.
    func addForce(_ force: Vector3)

    /// Apply a torque to the dynamic collider.
    func addTorque(_ torque: Vector3)

    /// Applies force at position. As a result this will apply a torque and force on the object.
    func addForceAtPosition(_ force: Vector3, _ pos: Vector3)

    /// Moves the kinematic collider towards position.
    func movePosition(_ value: Vector3)

    /// Rotates the collider to rotation.
    func moveRotation(_ value: Quaternion)

    /// Forces a collider to sleep at least one frame.
    func putToSleep()

    /// Forces a collider to wake up.
    func wakeUp()
}
