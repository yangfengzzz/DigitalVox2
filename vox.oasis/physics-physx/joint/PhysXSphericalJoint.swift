//
//  PhysXSphericalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXSphericalJoint: PhysXJoint, ISphericalJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createSphericalJoint(
                actor0?._pxActor ?? nil, position0.elements, rotation0.elements,
                actor1?._pxActor ?? nil, position1.elements, rotation1.elements)
    }

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
