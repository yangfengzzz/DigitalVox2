//
//  SpringJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

enum SpringJointFlag: Int {
    case MAX_DISTANCE_ENABLED = 2
    case MIN_DISTANCE_ENABLED = 4
    case SPRING_ENABLED = 8
}

class SpringJoint: Joint {
    private var _minDistance: Float = 0
    private var _maxDistance: Float = 0
    private var _tolerance: Float = 0
    private var _stiffness: Float = 0
    private var _damping: Float = 0

    required init(_ entity: Entity) {
        super.init(entity)
        _nativeJoint = PhysicsManager._nativePhysics.createSpringJoint(nil, Vector3(), Quaternion(), nil, Vector3(), Quaternion())
    }

    var minDistance: Float {
        get {
            _minDistance
        }
        set {
            _minDistance = newValue
            (_nativeJoint as! ISpringJoint).setMinDistance(newValue)
        }
    }

    var maxDistance: Float {
        get {
            _maxDistance
        }
        set {
            _maxDistance = newValue
            (_nativeJoint as! ISpringJoint).setMaxDistance(newValue)
        }
    }

    var tolerance: Float {
        get {
            _tolerance
        }
        set {
            _tolerance = newValue
            (_nativeJoint as! ISpringJoint).setTolerance(newValue)
        }
    }

    var stiffness: Float {
        get {
            _stiffness
        }
        set {
            _stiffness = newValue
            (_nativeJoint as! ISpringJoint).setStiffness(newValue)
        }
    }

    var damping: Float {
        get {
            _damping
        }
        set {
            _damping = newValue
            (_nativeJoint as! ISpringJoint).setDamping(newValue)
        }
    }

    func setDistanceJointFlag(_ flag: SpringJointFlag, _ value: Bool) {
        (_nativeJoint as! ISpringJoint).setDistanceJointFlag(flag.rawValue, value)
    }
}
