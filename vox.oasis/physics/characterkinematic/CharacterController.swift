//
//  CharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class CharacterController: Component {
    internal var _nativeCharacterController: ICharacterController!

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _nativeCharacterController.move(disp, minDist, elapsedTime)
    }

    func setPosition(_ position: Vector3) -> Bool {
        _nativeCharacterController.setPosition(position)
    }

    func setFootPosition(_ position: Vector3) {
        _nativeCharacterController.setFootPosition(position)
    }

    func setStepOffset(_ offset: Float) {
        _nativeCharacterController.setStepOffset(offset)
    }

    func setNonWalkableMode(_ flag: Int) {
        _nativeCharacterController.setNonWalkableMode(flag)
    }

    func setContactOffset(_ offset: Float) {
        _nativeCharacterController.setContactOffset(offset)
    }

    func setUpDirection(_ up: Vector3) {
        _nativeCharacterController.setUpDirection(up)
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        _nativeCharacterController.setSlopeLimit(slopeLimit)
    }

    func invalidateCache() {
        _nativeCharacterController.invalidateCache()
    }

    func resize(_ height: Float) {
        _nativeCharacterController.resize(height)
    }
}
