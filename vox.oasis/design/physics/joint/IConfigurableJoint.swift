//
//  IConfigurableJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IConfigurableJoint: IJoint {
    func setMotion(_ axis: Int, _ type: Int)

    func setHardDistanceLimit(_ extent: Float, contactDist: Float)

    func setSoftDistanceLimit(_ extent: Float, _ stiffness: Float, _ damping: Float)

    func setHardLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float)

    func setSoftLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float)

    func setHardTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float)

    func setSoftTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float)

    func setHardSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float)

    func setSoftSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float)

    func setHardPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ contactDist: Float)

    func setSoftPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ stiffness: Float, _ damping: Float)

    func setDrive(_ index: Int, _ driveStiffness: Float, _ driveDamping: Float, _ driveForceLimit: Float)

    func setDrivePosition(_ position: Vector3, _ rotation: Quaternion)

    func setDriveVelocity(_ linear: Vector3, _ angular: Vector3)

    func setProjectionLinearTolerance(_ tolerance: Float)

    func setProjectionAngularTolerance(_ tolerance: Float)
}
