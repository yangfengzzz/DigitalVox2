//
//  FixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class FixedJoint: Joint {
    private var _projectionLinearTolerance: Float = 0
    private var _projectionAngularTolerance: Float = 0

    var projectionLinearTolerance: Float {
        get {
            _projectionLinearTolerance
        }
        set {
            _projectionLinearTolerance = newValue
            (_nativeJoint as! IFixedJoint).setProjectionLinearTolerance(_projectionLinearTolerance)
        }
    }

    var projectionAngularTolerance: Float {
        get {
            _projectionAngularTolerance
        }
        set {
            _projectionAngularTolerance = newValue
            (_nativeJoint as! IFixedJoint).setProjectionAngularTolerance(_projectionAngularTolerance)
        }
    }

    init(_ collider0: Collider?, _ collider1: Collider?) {
        super.init()
        _nativeJoint = PhysicsManager._nativePhysics.createFixedJoint(
                collider0?._nativeCollider, Vector3(), Quaternion(),
                collider1?._nativeCollider, Vector3(), Quaternion())
    }
}
