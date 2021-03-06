//
//  PhysXDynamicCollider.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// The collision detection mode constants used for PhysXDynamicCollider.collisionDetectionMode.
enum CollisionDetectionMode : Int {
    /// Continuous collision detection is off for this dynamic collider.
    case Discrete
    /// Continuous collision detection is on for colliding with static mesh geometry.
    case Continuous
    /// Continuous collision detection is on for colliding with static and dynamic geometry.
    case ContinuousDynamic
    /// Speculative continuous collision detection is on for static and dynamic geometries
    case ContinuousSpeculative
}

/// Use these flags to constrain motion of dynamic collider.
enum DynamicColliderConstraints {
    /// Freeze motion along the X-axis.
    case FreezePositionX
    /// Freeze motion along the Y-axis.
    case FreezePositionY
    /// Freeze motion along the Z-axis.
    case FreezePositionZ
    /// Freeze rotation along the X-axis.
    case FreezeRotationX
    /// Freeze rotation along the Y-axis.
    case FreezeRotationY
    /// Freeze rotation along the Z-axis.
    case FreezeRotationZ
    /// Freeze motion along all axes.
    case FreezePosition
    /// Freeze rotation along all axes.
    case FreezeRotation
    /// Freeze rotation and motion along all axes.
    case FreezeAll
}

/// A dynamic collider can act with self-defined movement or physical force
class PhysXDynamicCollider: PhysXCollider, IDynamicCollider {
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _pxActor = PhysXPhysics._pxPhysics.createRigidDynamic(withPosition: position.elements,
                rotation: rotation.normalize().elements)
    }

    func setLinearDamping(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setLinearDamping(value)
    }

    func setAngularDamping(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setAngularDamping(value)
    }

    func setLinearVelocity(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setLinearVelocity(value.elements)
    }

    func setAngularVelocity(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setAngularVelocity(value.elements)
    }

    func setMass(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMass(value)
    }

    func setCenterOfMass(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setCMassLocalPose(value.elements,
                rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
    }

    func setInertiaTensor(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setMassSpaceInertiaTensor(value.elements)
    }

    func setMaxAngularVelocity(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMaxAngularVelocity(value)
    }

    func setMaxDepenetrationVelocity(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMaxDepenetrationVelocity(value)
    }

    func setSleepThreshold(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setSleepThreshold(value)
    }

    func setSolverIterations(_ value: Int) {
        (_pxActor as! CPxRigidDynamic).setSolverIterationCounts(UInt32(value), minVelocityIters: 1)
    }

    func setCollisionDetectionMode(_ value: Int) {
        switch (value) {
        case CollisionDetectionMode.Continuous.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: true)
            break
        case CollisionDetectionMode.ContinuousDynamic.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: true)
            break
        case CollisionDetectionMode.ContinuousSpeculative.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: true)
            break
        case CollisionDetectionMode.Discrete.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: false)
            break
        default:
            break
        }
    }

    func setIsKinematic(_ value: Bool) {
        if (value) {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: true)
        } else {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: false)
        }
    }

    func setFreezeRotation(_ value: Bool) {
        setConstraints(DynamicColliderConstraints.FreezeRotation, value)
    }

    func addForce(_ force: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForce(force.elements)
    }

    func addTorque(_ torque: Vector3) {
        (_pxActor as! CPxRigidDynamic).addTorque(torque.elements)
    }

    func addForceAtPosition(_ force: Vector3, _ pos: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForceAtPos(with: force.elements, pos: pos.elements, mode: eFORCE)
    }

    func movePosition(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setKinematicTarget(value.elements, rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
    }

    func moveRotation(_ value: Quaternion) {
        (_pxActor as! CPxRigidDynamic).setKinematicTarget([0, 0, 0], rotation: value.elements)
    }

    func putToSleep() {
        (_pxActor as! CPxRigidDynamic).putToSleep()
    }

    func wakeUp() {
        (_pxActor as! CPxRigidDynamic).wakeUp()
    }

    private func setConstraints(_ flag: DynamicColliderConstraints, _ value: Bool) {
        switch (flag) {
        case DynamicColliderConstraints.FreezePositionX:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            break
        case DynamicColliderConstraints.FreezePositionY:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezePositionZ:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationX:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationY:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationZ:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        case DynamicColliderConstraints.FreezeAll:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        case DynamicColliderConstraints.FreezePosition:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotation:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        }
    }
}
