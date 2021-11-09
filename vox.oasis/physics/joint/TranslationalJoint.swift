//
//  TranslationalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class TranslationalJoint: Joint {
    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createTranslationalJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_nativeJoint as! ITranslationalJoint).setHardLimit(lowerLimit, upperLimit, contactDist)
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! ITranslationalJoint).setSoftLimit(lowerLimit, upperLimit, stiffness, damping)
    }

    func setPrismaticJointFlag(_ flag: Int, _ value: Bool) {
        (_nativeJoint as! ITranslationalJoint).setPrismaticJointFlag(flag, value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! ITranslationalJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_nativeJoint as! ITranslationalJoint).setProjectionAngularTolerance(tolerance)
    }
}
