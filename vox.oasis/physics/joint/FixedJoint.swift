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

    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createFixedJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

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
}
