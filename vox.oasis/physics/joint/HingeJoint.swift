//
//  HingeJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

enum HingeJointFlag: Int {
    /// enable the limit
    case LIMIT_ENABLED = 1
    /// enable the drive
    case DRIVE_ENABLED = 2
    /// if the existing velocity is beyond the drive velocity, do not add force
    case DRIVE_FREESPIN = 4
}

class HingeJoint: Joint {
    private var _driveVelocity: Float = 0
    private var _driveForceLimit: Float = 0
    private var _driveGearRatio: Float = 0
    private var _projectionLinearTolerance: Float = 0
    private var _projectionAngularTolerance: Float = 0

    var driveVelocity: Float {
        get {
            _driveVelocity
        }
        set {
            _driveVelocity = newValue
            (_nativeJoint as! IHingeJoint).setDriveVelocity(newValue)
        }
    }

    var driveForceLimit: Float {
        get {
            _driveForceLimit
        }
        set {
            _driveForceLimit = newValue
            (_nativeJoint as! IHingeJoint).setDriveForceLimit(newValue)
        }
    }

    var driveGearRatio: Float {
        get {
            _driveGearRatio
        }
        set {
            _driveGearRatio = newValue
            (_nativeJoint as! IHingeJoint).setDriveGearRatio(newValue)
        }
    }

    var projectionLinearTolerance: Float {
        get {
            _projectionLinearTolerance
        }
        set {
            _projectionLinearTolerance = newValue
            (_nativeJoint as! IHingeJoint).setProjectionLinearTolerance(newValue)
        }
    }

    var projectionAngularTolerance: Float {
        get {
            _projectionAngularTolerance
        }
        set {
            _projectionAngularTolerance = newValue
            (_nativeJoint as! IHingeJoint).setProjectionAngularTolerance(newValue)
        }
    }

    init(_ collider0: Collider?, _ collider1: Collider?) {
        super.init()
        _nativeJoint = PhysicsManager._nativePhysics.createHingeJoint(
                collider0?._nativeCollider, Vector3(), Quaternion(),
                collider1?._nativeCollider, Vector3(), Quaternion())
    }

    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! IHingeJoint).setHardLimit(lowerLimit, upperLimit, contactDist)
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IHingeJoint).setSoftLimit(lowerLimit, upperLimit, stiffness, damping)
    }

    func setHingeJointFlag(_ flag: HingeJointFlag, _ value: Bool) {
        (_nativeJoint as! IHingeJoint).setRevoluteJointFlag(flag.rawValue, value)
    }
}
