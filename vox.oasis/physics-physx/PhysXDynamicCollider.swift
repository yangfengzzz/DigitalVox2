//
//  PhysXDynamicCollider.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// The collision detection mode constants used for PhysXDynamicCollider.collisionDetectionMode.
enum CollisionDetectionMode {
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
    var linearVelocity = Vector3()
    
    var angularVelocity = Vector3()
    
    var linearDamping: Float = 0
    
    var angularDamping: Float = 0
    
    var mass: Float = 0
    
    var isKinematic: Bool = false
    
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init();
        _pxActor = PhysXPhysics._pxPhysics.createRigidDynamic(withPosition: position.elements,
                                                              rotation: rotation.elements);
    }
    
    func addForce(_ force: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForce(with: force.elements);
    }
    
    func addTorque(_ torque: Vector3) {
        (_pxActor as! CPxRigidDynamic).addTorque(with: torque.elements);
    }
    
}
