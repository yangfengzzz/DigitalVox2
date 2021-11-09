//
//  FixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class FixedJoint: Joint {
    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createFixedJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! IFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_nativeJoint as! IFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
