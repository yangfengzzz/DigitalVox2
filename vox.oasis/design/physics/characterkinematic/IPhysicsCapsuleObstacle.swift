//
//  IPhysicsCapsuleObstacle.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IPhysicsCapsuleObstacle: IPhysicsObstacle {
    func setPos(_ mPos: Vector3)
    func setRot(_ mRot: Quaternion)
    func setRadius(_ mRadius: Float)
    func setHalfHeight(_ mHalfHeight: Float)
}
