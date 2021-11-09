//
//  Joint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class Joint: Component {
    internal var _nativeJoint: IJoint!

    private var _force: Float = 0
    private var _torque: Float = 0

    private struct JointActor {
        var _collider: Collider?
        var _localPosition = Vector3()
        var _localRotation = Quaternion()
        var _invMassScale: Float = 0
        var _invInertiaScale: Float = 0
    }

    private var _jointActor0 = JointActor()
    private var _jointActor1 = JointActor()

    var actor0: Collider? {
        get {
            _jointActor0._collider
        }
        set {
            _jointActor0._collider = newValue
            _nativeJoint.setActors(_jointActor0._collider?._nativeCollider, _jointActor1._collider?._nativeCollider)
        }
    }

    var actor1: Collider? {
        get {
            _jointActor1._collider
        }
        set {
            _jointActor1._collider = newValue
            _nativeJoint.setActors(_jointActor0._collider?._nativeCollider, _jointActor1._collider?._nativeCollider)
        }
    }


    var localPosition0: Vector3 {
        get {
            _jointActor0._localPosition
        }
        set {
            if newValue !== _jointActor0._localPosition {
                newValue.cloneTo(target: _jointActor0._localPosition)
                _nativeJoint.setLocalPose(0, _jointActor0._localPosition, _jointActor0._localRotation)
            }
        }
    }

    var localRotation0: Quaternion {
        get {
            _jointActor0._localRotation
        }
        set {
            if newValue !== _jointActor0._localRotation {
                newValue.cloneTo(target: _jointActor0._localRotation)
                _nativeJoint.setLocalPose(0, _jointActor0._localPosition, _jointActor0._localRotation)
            }
        }
    }

    var localPosition1: Vector3 {
        get {
            _jointActor1._localPosition
        }
        set {
            if newValue !== _jointActor1._localPosition {
                newValue.cloneTo(target: _jointActor1._localPosition)
                _nativeJoint.setLocalPose(1, _jointActor1._localPosition, _jointActor1._localRotation)
            }
        }
    }

    var localRotation1: Quaternion {
        get {
            _jointActor1._localRotation
        }
        set {
            if newValue !== _jointActor1._localRotation {
                newValue.cloneTo(target: _jointActor1._localRotation)
                _nativeJoint.setLocalPose(1, _jointActor1._localPosition, _jointActor1._localRotation)
            }
        }
    }

    var BreakForce: Float {
        get {
            _force
        }
        set {
            _force = newValue
            _nativeJoint.setBreakForce(_force, _torque)
        }
    }

    var BreakTorque: Float {
        get {
            _torque
        }
        set {
            _torque = newValue
            _nativeJoint.setBreakForce(_force, _torque)
        }
    }

    var invMassScale0: Float {
        get {
            _jointActor0._invMassScale
        }
        set {
            _jointActor0._invMassScale = newValue
            _nativeJoint.setInvMassScale0(_jointActor0._invMassScale)
        }
    }

    var invInertiaScale0: Float {
        get {
            _jointActor0._invInertiaScale
        }
        set {
            _jointActor0._invInertiaScale = newValue
            _nativeJoint.setInvInertiaScale0(_jointActor0._invInertiaScale)
        }
    }

    var invMassScale1: Float {
        get {
            _jointActor1._invMassScale
        }
        set {
            _jointActor1._invMassScale = newValue
            _nativeJoint.setInvMassScale1(_jointActor1._invMassScale)
        }
    }

    var invInertiaScale1: Float {
        get {
            _jointActor1._invInertiaScale
        }
        set {
            _jointActor1._invInertiaScale = newValue
            _nativeJoint.setInvInertiaScale1(_jointActor1._invInertiaScale)
        }
    }

    func setConstraintFlag(_ flags: PxConstraintFlag, _ value: Bool) {
        _nativeJoint.setConstraintFlag(flags.rawValue, value)
    }
}

enum PxConstraintFlag: Int {
    /// whether the constraint is broken
    case eBROKEN = 1
    /// whether actor1 should get projected to actor0 for this constraint (note: projection of a static/kinematic actor to a dynamic actor will be ignored)
    case ePROJECT_TO_ACTOR0 = 2
    /// whether actor0 should get projected to actor1 for this constraint (note: projection of a static/kinematic actor to a dynamic actor will be ignored)
    case ePROJECT_TO_ACTOR1 = 4
    /// whether the actors should get projected for this constraint (the direction will be chosen by PhysX)
    case ePROJECTION = 6
    /// whether contacts should be generated between the objects this constraint constrains
    case eCOLLISION_ENABLED = 8
    /// whether this constraint should be visualized, if constraint visualization is turned on
    case eVISUALIZATION = 16
    /// limits for drive strength are forces rather than impulses
    case eDRIVE_LIMITS_ARE_FORCES = 32
    /// perform preprocessing for improved accuracy on D6 Slerp Drive (this flag will be removed in a future release when preprocessing is no longer required)
    case eIMPROVED_SLERP = 64
    /// suppress constraint preprocessing, intended for use with rowResponseThreshold. May result in worse solver accuracy for ill-conditioned constraints.
    case eDISABLE_PREPROCESSING = 128
    /// enables extended limit ranges for angular limits (e.g. limit values > PxPi or < -PxPi)
    case eENABLE_EXTENDED_LIMITS = 256
}
