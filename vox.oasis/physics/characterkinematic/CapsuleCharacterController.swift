//
//  CapsuleCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

enum CapsuleClimbingMode: Int {
    /// Standard mode, let the capsule climb over surfaces according to impact normal
    case EASY
    /// Constrained mode, try to limit climbing according to the step offset
    case CONSTRAINED
}

class CapsuleCharacterController: CharacterController {
    private var _radius: Float = 0
    private var _height: Float = 0
    private var _climbingMode: CapsuleClimbingMode = .EASY

    var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            _ = (_nativeCharacterController as! ICapsuleCharacterController).setRadius(newValue)
        }
    }

    var height: Float {
        get {
            _height
        }
        set {
            _height = newValue
            _ = (_nativeCharacterController as! ICapsuleCharacterController).setHeight(newValue)
        }
    }

    var climbingMode: CapsuleClimbingMode {
        get {
            _climbingMode
        }
        set {
            _climbingMode = newValue
            _ = (_nativeCharacterController as! ICapsuleCharacterController).setClimbingMode(newValue.rawValue)
        }
    }

    func setDesc(_ desc: CapsuleCharacterControllerDesc) {
        _nativeCharacterController = engine.physicsManager!.characterControllerManager!.createController(desc._nativeCharacterControllerDesc)
        _nativeCharacterController.setUniqueID(_id)
    }
}
