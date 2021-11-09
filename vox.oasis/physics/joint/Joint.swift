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

    private var _actor0: Collider?
    private var _localPose0 = (Vector3(), Quaternion())
    private var _invMassScale0: Float = 0
    private var _invInertiaScale0: Float = 0

    private var _actor1: Collider?
    private var _localPose1 = (Vector3(), Quaternion())
    private var _invMassScale1: Float = 0
    private var _invInertiaScale1: Float = 0

    var actor0: Collider? {
        get {
            _actor0
        }
        set {
            _actor0 = newValue
            _nativeJoint.setActors(_actor0?._nativeCollider, _actor1?._nativeCollider)
        }
    }

    var actor1: Collider? {
        get {
            _actor1
        }
        set {
            _actor1 = newValue
            _nativeJoint.setActors(_actor0?._nativeCollider, _actor1?._nativeCollider)
        }
    }


    var localPosition0: Vector3 {
        get {
            return _localPose0.0
        }
        set {
            if newValue !== _localPose0.0 {
                newValue.cloneTo(target: _localPose0.0)
                _nativeJoint.setLocalPose(0, _localPose0.0, _localPose0.1)
            }
        }
    }

    var localRotation0: Quaternion {
        get {
            return _localPose0.1
        }
        set {
            if newValue !== _localPose0.1 {
                newValue.cloneTo(target: _localPose0.1)
                _nativeJoint.setLocalPose(0, _localPose0.0, _localPose0.1)
            }
        }
    }

    var localPosition1: Vector3 {
        get {
            return _localPose1.0
        }
        set {
            if newValue !== _localPose1.0 {
                newValue.cloneTo(target: _localPose1.0)
                _nativeJoint.setLocalPose(1, _localPose1.0, _localPose1.1)
            }
        }
    }

    var localRotation1: Quaternion {
        get {
            return _localPose1.1
        }
        set {
            if newValue !== _localPose1.1 {
                newValue.cloneTo(target: _localPose1.1)
                _nativeJoint.setLocalPose(1, _localPose1.0, _localPose1.1)
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
            _invMassScale0
        }
        set {
            _invMassScale0 = newValue
            _nativeJoint.setInvMassScale0(invMassScale0)
        }
    }

    var invInertiaScale0: Float {
        get {
            _invInertiaScale0
        }
        set {
            _invInertiaScale0 = newValue
            _nativeJoint.setInvInertiaScale0(invInertiaScale0)
        }
    }

    var invMassScale1: Float {
        get {
            _invMassScale1
        }
        set {
            _invMassScale1 = newValue
            _nativeJoint.setInvMassScale1(invMassScale1)
        }
    }

    var invInertiaScale1: Float {
        get {
            _invInertiaScale1
        }
        set {
            _invInertiaScale1 = newValue
            _nativeJoint.setInvInertiaScale1(invInertiaScale1)
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
};
