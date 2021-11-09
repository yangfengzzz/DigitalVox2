//
//  TranslationalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class TranslationalJoint: Joint {
    private var _enableLimit: Bool = false
    private var _projectionLinearTolerance: Float = 0
    private var _projectionAngularTolerance: Float = 0

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

    var enableLimit: Bool {
        get {
            _enableLimit
        }
        set {
            _enableLimit = newValue
            (_nativeJoint as! ITranslationalJoint).setPrismaticJointFlag(1 << 1, newValue)
        }
    }

    var projectionLinearTolerance: Float {
        get {
            _projectionLinearTolerance
        }
        set {
            _projectionLinearTolerance = newValue
            (_nativeJoint as! ITranslationalJoint).setProjectionLinearTolerance(newValue)
        }
    }

    var projectionAngularTolerance: Float {
        get {
            _projectionAngularTolerance
        }
        set {
            _projectionAngularTolerance = newValue
            (_nativeJoint as! ITranslationalJoint).setProjectionAngularTolerance(newValue)
        }
    }
}
