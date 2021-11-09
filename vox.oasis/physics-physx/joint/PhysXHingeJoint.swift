//
//  PhysXHingeJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXHingeJoint: PhysXJoint, IHingeJoint {
    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxRevoluteJoint).setLimit(CPxJointAngularLimitPair(hardLimit: lowerLimit, upperLimit, contactDist))
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxRevoluteJoint).setLimit(
                CPxJointAngularLimitPair(softLimit: lowerLimit, upperLimit,
                        CPxSpring(stiffness: stiffness, damping)))
    }

    func setDriveVelocity(_ velocity: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveVelocity(velocity)
    }

    func setDriveForceLimit(_ limit: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveForceLimit(limit)
    }

    func setDriveGearRatio(_ ratio: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveGearRatio(ratio)
    }

    func setRevoluteJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxRevoluteJoint).setRevoluteJointFlag(CPxRevoluteJointFlag(UInt32(flag)), value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxRevoluteJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxRevoluteJoint).setProjectionAngularTolerance(tolerance)
    }
}
