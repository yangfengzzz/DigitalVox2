//
//  IPhysicsBoxObstacle.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IPhysicsBoxObstacle: IPhysicsObstacle {
    func setPos(_ mPos: Vector3)
    func setRot(_ mRot: Quaternion)
    func setHalfExtents(_ mHalfExtents: Vector3)
}
