//
//  CapsuleCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class CapsuleCharacterControllerDesc {
    internal var _nativeCharacterControllerDesc: ICapsuleCharacterControllerDesc

    init() {
        _nativeCharacterControllerDesc = PhysicsManager._nativePhysics.createCapsuleCharacterControllerDesc()
    }
}
