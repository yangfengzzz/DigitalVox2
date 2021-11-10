//
//  PhysicsObstacle.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class PhysicsObstacle {
    internal var _nativeObstacle: IPhysicsObstacle!

    func getType() -> Int {
        _nativeObstacle.getType()
    }
}

class PhysicsBoxObstacle: PhysicsObstacle {
    private var _halfExtents = Vector3()

    var halfExtents: Vector3 {
        get {
            _halfExtents
        }
        set {
            if _halfExtents !== newValue {
                newValue.cloneTo(target: _halfExtents)
            }
            (_nativeObstacle as! IPhysicsBoxObstacle).setHalfExtents(_halfExtents)
        }
    }

    override init() {
        super.init()
        _nativeObstacle = PhysicsManager._nativePhysics.createBoxObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_nativeObstacle as! IPhysicsBoxObstacle).setPos(mPos)
    }

    func setRot(_ mRot: Quaternion) {
        (_nativeObstacle as! IPhysicsBoxObstacle).setRot(mRot)
    }
}

class PhysicsCapsuleObstacle: PhysicsObstacle {
    private var _radius: Float = 0
    private var _halfHeight: Float = 0

    var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            (_nativeObstacle as! IPhysicsCapsuleObstacle).setRadius(newValue)
        }
    }

    var halfHeight: Float {
        get {
            _halfHeight
        }
        set {
            _halfHeight = newValue
            (_nativeObstacle as! IPhysicsCapsuleObstacle).setHalfHeight(newValue)
        }
    }

    override init() {
        super.init()
        _nativeObstacle = PhysicsManager._nativePhysics.createCapsuleObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_nativeObstacle as! IPhysicsCapsuleObstacle).setPos(mPos)
    }

    func setRot(_ mRot: Quaternion) {
        (_nativeObstacle as! IPhysicsCapsuleObstacle).setRot(mRot)
    }
}
