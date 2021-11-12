//
//  ICharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ICharacterController {
    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8

    func setPosition(_ position: Vector3) -> Bool

    func setFootPosition(_ position: Vector3)

    func setStepOffset(_ offset: Float)

    func setNonWalkableMode(_ flag: Int)

    func setContactOffset(_ offset: Float)

    func setUpDirection(_ up: Vector3)

    func setSlopeLimit(_ slopeLimit: Float)

    func invalidateCache()

    func resize(_ height: Float)

    /// Set unique id of the collider shape.
    func setUniqueID(_ id: Int)

    func getPosition(_ position: Vector3)
}
