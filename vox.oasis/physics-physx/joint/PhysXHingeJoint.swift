//
//  PhysXHingeJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXHingeJoint: PhysXJoint, IHingeJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createRevoluteJoint(
                actor0?._pxActor ?? nil, position0.elements, rotation0.elements,
                actor1?._pxActor ?? nil, position1.elements, rotation1.elements)
    }

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
