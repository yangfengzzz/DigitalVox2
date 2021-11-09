//
//  BoxCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class BoxCharacterController: CharacterController {
    func setHalfHeight(_ halfHeight: Float) -> Bool {
        (_nativeCharacterController as! IBoxCharacterController).setHalfHeight(halfHeight)
    }

    func setHalfSideExtent(_ halfSideExtent: Float) -> Bool {
        (_nativeCharacterController as! IBoxCharacterController).setHalfSideExtent(halfSideExtent)
    }

    func setHalfForwardExtent(_ halfForwardExtent: Float) -> Bool {
        (_nativeCharacterController as! IBoxCharacterController).setHalfForwardExtent(halfForwardExtent)
    }

    func setDesc(_ desc: BoxCharacterControllerDesc) {
        _nativeCharacterController = engine.physicsManager!.characterControllerManager!.createController(desc._nativeCharacterControllerDesc)
    }
}
