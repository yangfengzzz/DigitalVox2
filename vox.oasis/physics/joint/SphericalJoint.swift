//
//  SphericalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class SphericalJoint: Joint {
    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createSphericalJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

    func setHardLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_nativeJoint as! ISphericalJoint).setHardLimitCone(yLimitAngle, zLimitAngle, contactDist)
    }

    func setSoftLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! ISphericalJoint).setSoftLimitCone(yLimitAngle, zLimitAngle, stiffness, damping)
    }

    func setSphericalJointFlag(_ flag: Int, _ value: Bool) {
        (_nativeJoint as! ISphericalJoint).setSphericalJointFlag(flag, value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! ISphericalJoint).setProjectionLinearTolerance(tolerance)
    }
}
