//
//  BoxCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class BoxCharacterController: CharacterController {
    private var _halfHeight: Float = 0
    private var _halfSideExtent: Float = 0
    private var _halfForwardExtent: Float = 0

    var halfHeight: Float {
        get {
            _halfHeight
        }
        set {
            _halfHeight = newValue
            _ = (_nativeCharacterController as! IBoxCharacterController).setHalfHeight(newValue)
        }
    }

    var halfSideExtent: Float {
        get {
            _halfSideExtent
        }
        set {
            _halfSideExtent = newValue
            _ = (_nativeCharacterController as! IBoxCharacterController).setHalfSideExtent(newValue)
        }
    }

    var halfForwardExtent: Float {
        get {
            _halfForwardExtent
        }
        set {
            _halfForwardExtent = newValue
            _ = (_nativeCharacterController as! IBoxCharacterController).setHalfForwardExtent(newValue)
        }
    }

    func setDesc(_ desc: BoxCharacterControllerDesc) {
        _nativeCharacterController = engine.physicsManager!.characterControllerManager!.createController(desc._nativeCharacterControllerDesc)
        _nativeCharacterController.setUniqueID(_id)
    }
}
