//
//  PhysXTranslationalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXTranslationalJoint: PhysXJoint, ITranslationalJoint {
    init(_ actor0: PhysXCollider, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createPrismaticJoint(
                actor0._pxActor, position0.elements, rotation0.elements,
                actor1._pxActor, position1.elements, rotation1.elements)
    }

    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxPrismaticJoint).setLimit(CPxJointLinearLimitPair(
                hardLimit: CPxTolerancesScale.new(), lowerLimit, upperLimit, contactDist))
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxPrismaticJoint).setLimit(
                CPxJointLinearLimitPair(softLimit: lowerLimit, upperLimit,
                        CPxSpring(stiffness: stiffness, damping)))
    }

    func setPrismaticJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxPrismaticJoint).setPrismaticJointFlag(CPxPrismaticJointFlag(UInt32(flag)), value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxPrismaticJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxPrismaticJoint).setProjectionAngularTolerance(tolerance)
    }
}
