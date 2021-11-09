//
//  PhysXObstacle.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXObstacle: IPhysicsObstacle {
    internal var _pxObstacle: CPxObstacle!

    func getType() -> Int {
        Int(_pxObstacle.getType().rawValue)
    }
}

class PhysXBoxObstacle: PhysXObstacle, IPhysicsBoxObstacle {
    override init() {
        super.init()
        _pxObstacle = CPxBoxObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_pxObstacle as! CPxBoxObstacle).mPos = mPos.elements
    }

    func setRot(_ mRot: Quaternion) {
        (_pxObstacle as! CPxBoxObstacle).mRot = mRot.elements
    }

    func setHalfExtents(_ mHalfExtents: Vector3) {
        (_pxObstacle as! CPxBoxObstacle).mHalfExtents = mHalfExtents.elements
    }
}

class PhysXCapsuleObstacle: PhysXObstacle, IPhysicsCapsuleObstacle {
    override init() {
        super.init()
        _pxObstacle = CPxCapsuleObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_pxObstacle as! CPxCapsuleObstacle).mPos = mPos.elements
    }

    func setRot(_ mRot: Quaternion) {
        (_pxObstacle as! CPxCapsuleObstacle).mRot = mRot.elements
    }

    func setRadius(_ mRadius: Float) {
        (_pxObstacle as! CPxCapsuleObstacle).mRadius = mRadius
    }

    func setHalfHeight(_ mHalfHeight: Float) {
        (_pxObstacle as! CPxCapsuleObstacle).mHalfHeight = mHalfHeight
    }
}

