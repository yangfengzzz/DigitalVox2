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

    func setHalfExtents(_ mHalfExtents: Vector3) {
        (_nativeObstacle as! IPhysicsBoxObstacle).setHalfExtents(mHalfExtents)
    }
}

class PhysicsCapsuleObstacle: PhysicsObstacle {
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

    func setRadius(_ mRadius: Float) {
        (_nativeObstacle as! IPhysicsCapsuleObstacle).setRadius(mRadius)
    }

    func setHalfHeight(_ mHalfHeight: Float) {
        (_nativeObstacle as! IPhysicsCapsuleObstacle).setHalfHeight(mHalfHeight)
    }
}
