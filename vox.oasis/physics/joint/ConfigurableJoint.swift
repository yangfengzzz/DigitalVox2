//
//  ConfigurableJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

enum ConfigurableJointAxis: Int {
    /// motion along the X axis
    case X = 0
    /// motion along the Y axis
    case Y = 1
    /// motion along the Z axis
    case Z = 2
    /// motion around the X axis
    case TWIST = 3
    /// motion around the Y axis
    case SWING1 = 4
    /// motion around the Z axis
    case SWING2 = 5
}

enum ConfigurableJointMotion: Int {
    /// The DOF is locked, it does not allow relative motion.
    case LOCKED = 0
    /// The DOF is limited, it only allows motion within a specific range.
    case LIMITED = 1
    /// The DOF is free and has its full range of motion.
    case FREE = 2
}

enum ConfigurableJointDrive: Int {
    /// drive along the X-axis
    case eX = 0
    /// drive along the Y-axis
    case eY = 1
    /// drive along the Z-axis
    case eZ = 2
    /// drive of displacement from the X-axis
    case eSWING = 3
    /// drive of the displacement around the X-axis
    case eTWIST = 4
    /// drive of all three angular degrees along a SLERP-path
    case eSLERP = 5
}

class ConfigurableJoint: Joint {
    private var _projectionLinearTolerance: Float = 0
    private var _projectionAngularTolerance: Float = 0

    var projectionLinearTolerance: Float {
        get {
            _projectionLinearTolerance
        }
        set {
            _projectionLinearTolerance = newValue
            (_nativeJoint as! IConfigurableJoint).setProjectionLinearTolerance(newValue)
        }
    }

    var projectionAngularTolerance: Float {
        get {
            _projectionAngularTolerance
        }
        set {
            _projectionAngularTolerance = newValue
            (_nativeJoint as! IConfigurableJoint).setProjectionAngularTolerance(newValue)
        }
    }

    init(_ collider0: Collider?, _ collider1: Collider?) {
        super.init()
        _nativeJoint = PhysicsManager._nativePhysics.createConfigurableJoint(
                collider0?._nativeCollider, Vector3(), Quaternion(),
                collider1?._nativeCollider, Vector3(), Quaternion())
    }

    //MARK: - Motion
    func setMotion(_ axis: ConfigurableJointAxis, _ type: ConfigurableJointMotion) {
        (_nativeJoint as! IConfigurableJoint).setMotion(axis.rawValue, type.rawValue)
    }

    //MARK: - Limit
    func setHardDistanceLimit(_ extent: Float, contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardDistanceLimit(extent, contactDist: contactDist)
    }

    func setSoftDistanceLimit(_ extent: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftDistanceLimit(extent, stiffness, damping)
    }

    func setHardLinearLimit(_ axis: ConfigurableJointAxis, _ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardLinearLimit(axis.rawValue, lowerLimit, upperLimit, contactDist)
    }

    func setSoftLinearLimit(_ axis: ConfigurableJointAxis, _ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftLinearLimit(axis.rawValue, lowerLimit, upperLimit, stiffness, damping)
    }

    func setHardTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardTwistLimit(lowerLimit, upperLimit, contactDist)
    }

    func setSoftTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftTwistLimit(lowerLimit, upperLimit, stiffness, damping)
    }

    func setHardSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardSwingLimit(yLimitAngle, zLimitAngle, contactDist)
    }

    func setSoftSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftSwingLimit(yLimitAngle, zLimitAngle, stiffness, damping)
    }

    func setHardPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardPyramidSwingLimit(yLimitAngleMin, yLimitAngleMax, zLimitAngleMin, zLimitAngleMax, contactDist)
    }

    func setSoftPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftPyramidSwingLimit(yLimitAngleMin, yLimitAngleMax, zLimitAngleMin, zLimitAngleMax, stiffness, damping)
    }

    //MARK: - Drive
    func setDrive(_ index: ConfigurableJointDrive, _ driveStiffness: Float, _ driveDamping: Float, _ driveForceLimit: Float) {
        (_nativeJoint as! IConfigurableJoint).setDrive(index.rawValue, driveStiffness, driveDamping, driveForceLimit)
    }

    func setDrivePosition(_ position: Vector3, _ rotation: Quaternion) {
        (_nativeJoint as! IConfigurableJoint).setDrivePosition(position, rotation)
    }

    func setDriveVelocity(_ linear: Vector3, _ angular: Vector3) {
        (_nativeJoint as! IConfigurableJoint).setDriveVelocity(linear, angular)
    }
}
