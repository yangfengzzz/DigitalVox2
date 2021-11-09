//
//  ConfigurableJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class ConfigurableJoint: Joint {
    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createConfigurableJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

    func setMotion(_ axis: Int, _ type: Int) {
        (_nativeJoint as! IConfigurableJoint).setMotion(axis, type)
    }

    func setHardDistanceLimit(_ extent: Float, contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardDistanceLimit(extent, contactDist: contactDist)
    }

    func setSoftDistanceLimit(_ extent: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftDistanceLimit(extent, stiffness, damping)
    }

    func setHardLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! IConfigurableJoint).setHardLinearLimit(axis, lowerLimit, upperLimit, contactDist)
    }

    func setSoftLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IConfigurableJoint).setSoftLinearLimit(axis, lowerLimit, upperLimit, stiffness, damping)
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

    func setDrive(_ index: Int, _ driveStiffness: Float, _ driveDamping: Float, _ driveForceLimit: Float) {
        (_nativeJoint as! IConfigurableJoint).setDrive(index, driveStiffness, driveDamping, driveForceLimit)
    }

    func setDrivePosition(_ position: Vector3, _ rotation: Quaternion) {
        (_nativeJoint as! IConfigurableJoint).setDrivePosition(position, rotation)
    }

    func setDriveVelocity(_ linear: Vector3, _ angular: Vector3) {
        (_nativeJoint as! IConfigurableJoint).setDriveVelocity(linear, angular)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! IConfigurableJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_nativeJoint as! IConfigurableJoint).setProjectionAngularTolerance(tolerance)
    }
}
