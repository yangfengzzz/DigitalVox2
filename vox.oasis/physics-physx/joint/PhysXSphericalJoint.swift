//
//  PhysXSphericalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXSphericalJoint: PhysXJoint, ISphericalJoint {
    func setHardLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_pxJoint as! CPxSphericalJoint).setLimitCone(CPxJointLimitCone(hardLimit: yLimitAngle, zLimitAngle, contactDist))
    }

    func setSoftLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxSphericalJoint).setLimitCone(
                CPxJointLimitCone(softLimit: yLimitAngle, zLimitAngle,
                        CPxSpring(stiffness: stiffness, damping)))
    }

    func setSphericalJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxSphericalJoint).setSphericalJointFlag(CPxSphericalJointFlag(UInt32(flag)), value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxSphericalJoint).setProjectionLinearTolerance(tolerance)
    }
}
