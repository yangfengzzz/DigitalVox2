//
//  CapsuleCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class CapsuleCharacterController: CharacterController {
    func setRadius(_ radius: Float) -> Bool {
        (_nativeCharacterController as! ICapsuleCharacterController).setRadius(radius)
    }

    func setHeight(_ height: Float) -> Bool {
        (_nativeCharacterController as! ICapsuleCharacterController).setHeight(height)
    }

    func setClimbingMode(_ mode: Int) -> Bool {
        (_nativeCharacterController as! ICapsuleCharacterController).setClimbingMode(mode)
    }

    func setDesc(_ desc: CapsuleCharacterControllerDesc) {
        _nativeCharacterController = engine.physicsManager!.characterControllerManager!.createController(desc._nativeCharacterControllerDesc)
    }
}
