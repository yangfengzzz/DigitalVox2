//
//  PhysXCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXCharacterController: ICharacterController {
    internal var _pxController: CPxController!

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _pxController.move(disp.elements, minDist, elapsedTime)
    }

    func setPosition(_ position: Vector3) -> Bool {
        _pxController.setPosition(position.elements)
    }

    func setFootPosition(_ position: Vector3) {
        _pxController.setFootPosition(position.elements)
    }

    func setStepOffset(_ offset: Float) {
        _pxController.setStepOffset(offset)
    }

    func setNonWalkableMode(_ flag: Int) {
        _pxController.setNonWalkableMode(CPxControllerNonWalkableMode(UInt32(flag)))
    }

    func setContactOffset(_ offset: Float) {
        _pxController.setContactOffset(offset)
    }

    func setUpDirection(_ up: Vector3) {
        _pxController.setUpDirection(up.elements)
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        _pxController.setSlopeLimit(slopeLimit)
    }

    func invalidateCache() {
        _pxController.invalidateCache()
    }

    func resize(_ height: Float) {
        _pxController.resize(height)
    }
}
