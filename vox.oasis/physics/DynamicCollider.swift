//
//  DynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// A dynamic collider can act with self-defined movement or physical force.
class DynamicCollider: Collider {
    private var _linearDamping: Float = 0
    private var _angularDamping: Float = 0
    private var _linearVelocity = Vector3()
    private var _angularVelocity = Vector3()
    private var _mass: Float = 0
    private var _centerOfMass = Vector3()
    private var _inertiaTensor = Vector3()
    private var _maxAngularVelocity: Float = 0
    private var _maxDepenetrationVelocity: Float = 0
    private var _sleepThreshold: Float = 0
    private var _solverIterations: Int = 0
    private var _isKinematic: Bool = false
    private var _freezeRotation: Bool = false
    private var _collisionDetectionMode: CollisionDetectionMode = .Discrete

    /// The linear damping of the dynamic collider.
    var linearDamping: Float {
        get {
            _linearDamping
        }
        set {
            _linearDamping = newValue
            (_nativeCollider as! IDynamicCollider).setLinearDamping(newValue)
        }
    }

    /// The angular damping of the dynamic collider.
    var angularDamping: Float {
        get {
            _angularDamping
        }
        set {
            _angularDamping = newValue
            (_nativeCollider as! IDynamicCollider).setAngularDamping(newValue)
        }
    }

    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    var linearVelocity: Vector3 {
        get {
            _linearVelocity
        }
        set {
            if _linearVelocity !== newValue {
                newValue.cloneTo(target: _linearVelocity)
            }
            (_nativeCollider as! IDynamicCollider).setLinearVelocity(_linearVelocity)
        }
    }

    /// The angular velocity vector of the dynamic collider measured in radians per second.
    var angularVelocity: Vector3 {
        get {
            _angularVelocity
        }
        set {
            if _angularVelocity !== newValue {
                newValue.cloneTo(target: _angularVelocity)
            }
            (_nativeCollider as! IDynamicCollider).setAngularVelocity(_angularVelocity)
        }
    }

    /// The mass of the dynamic collider.
    var mass: Float {
        get {
            _mass
        }
        set {
            _mass = newValue
            (_nativeCollider as! IDynamicCollider).setMass(newValue)
        }
    }

    /// The center of mass relative to the transform's origin.
    var centerOfMass: Vector3 {
        get {
            _centerOfMass
        }
        set {
            if _centerOfMass !== newValue {
                newValue.cloneTo(target: _centerOfMass)
            }
            (_nativeCollider as! IDynamicCollider).setCenterOfMass(_centerOfMass)
        }
    }

    /// The diagonal inertia tensor of mass relative to the center of mass.
    var inertiaTensor: Vector3 {
        get {
            _inertiaTensor
        }
        set {
            if _inertiaTensor !== newValue {
                newValue.cloneTo(target: _inertiaTensor)
            }
            (_nativeCollider as! IDynamicCollider).setInertiaTensor(_inertiaTensor)
        }
    }

    /// The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
    var maxAngularVelocity: Float {
        get {
            _maxAngularVelocity
        }
        set {
            _maxAngularVelocity = newValue
            (_nativeCollider as! IDynamicCollider).setMaxAngularVelocity(newValue)
        }
    }

    /// Maximum velocity of a collider when moving out of penetrating state.
    var maxDepenetrationVelocity: Float {
        get {
            _maxDepenetrationVelocity
        }
        set {
            _maxDepenetrationVelocity = newValue
            (_nativeCollider as! IDynamicCollider).setMaxDepenetrationVelocity(newValue)
        }
    }

    /// The mass-normalized energy threshold, below which objects start going to sleep.
    var sleepThreshold: Float {
        get {
            _sleepThreshold
        }
        set {
            _sleepThreshold = newValue
            (_nativeCollider as! IDynamicCollider).setSleepThreshold(newValue)
        }
    }

    /// The solverIterations determines how accurately collider joints and collision contacts are resolved.
    var solverIterations: Int {
        get {
            _solverIterations
        }
        set {
            _solverIterations = newValue
            (_nativeCollider as! IDynamicCollider).setSolverIterations(newValue)
        }
    }

    /// Controls whether physics affects the dynamic collider.
    var isKinematic: Bool {
        get {
            _isKinematic
        }
        set {
            _isKinematic = newValue
            (_nativeCollider as! IDynamicCollider).setIsKinematic(newValue)
        }
    }

    /// Controls whether physics will change the rotation of the object.
    var freezeRotation: Bool {
        get {
            _freezeRotation
        }
        set {
            _freezeRotation = newValue
            (_nativeCollider as! IDynamicCollider).setFreezeRotation(newValue)
        }
    }

    /// The colliders' collision detection mode.
    var collisionDetectionMode: CollisionDetectionMode {
        get {
            _collisionDetectionMode
        }
        set {
            _collisionDetectionMode = newValue
            (_nativeCollider as! IDynamicCollider).setCollisionDetectionMode(newValue.rawValue)
        }
    }

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
        transform.worldPosition = transform.worldPosition
        transform.worldRotationQuaternion = transform.worldRotationQuaternion
        _updateFlag.flag = false
    }
}
