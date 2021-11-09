//
//  SphericalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class SphericalJoint: Joint {
    private var _enableLimit:Bool = false
    private var _projectionLinearTolerance: Float = 0
    
    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createSphericalJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
        (_nativeJoint as! ISphericalJoint).setSphericalJointFlag(1 << 1, false)
    }

    func setHardLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_nativeJoint as! ISphericalJoint).setHardLimitCone(yLimitAngle, zLimitAngle, contactDist)
    }

    func setSoftLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_nativeJoint as! ISphericalJoint).setSoftLimitCone(yLimitAngle, zLimitAngle, stiffness, damping)
    }
   
    var enableLimit:Bool {
        get {
            _enableLimit
        }
        set {
            _enableLimit = newValue
            (_nativeJoint as! ISphericalJoint).setSphericalJointFlag(1 << 1, newValue)
        }
    }
    
    var projectionLinearTolerance: Float {
        get {
            _projectionLinearTolerance
        }
        set {
            _projectionLinearTolerance = newValue
            (_nativeJoint as! ISphericalJoint).setProjectionLinearTolerance(_projectionLinearTolerance)
        }
    }
}
