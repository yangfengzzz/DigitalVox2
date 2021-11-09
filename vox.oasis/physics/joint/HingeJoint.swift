//
//  HingeJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class HingeJoint: Joint {
    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! IHingeJoint).setHardLimit(lowerLimit, upperLimit, contactDist)
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! IHingeJoint).setSoftLimit(lowerLimit, upperLimit, stiffness, damping)
    }

    func setDriveVelocity(_ velocity: Float) {
        (_nativeJoint as! IHingeJoint).setDriveVelocity(velocity)
    }

    func setDriveForceLimit(_ limit: Float) {
        (_nativeJoint as! IHingeJoint).setDriveForceLimit(limit)
    }

    func setDriveGearRatio(_ ratio: Float) {
        (_nativeJoint as! IHingeJoint).setDriveGearRatio(ratio)
    }

    func setRevoluteJointFlag(_ flag: Int, _ value: Bool) {
        (_nativeJoint as! IHingeJoint).setRevoluteJointFlag(flag, value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! IHingeJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_nativeJoint as! IHingeJoint).setProjectionAngularTolerance(tolerance)
    }
}
