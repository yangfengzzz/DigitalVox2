//
//  BoxCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class BoxCharacterControllerDesc {
    internal var _nativeCharacterControllerDesc: IBoxCharacterControllerDesc

    init() {
        _nativeCharacterControllerDesc = PhysicsManager._nativePhysics.createBoxCharacterControllerDesc()
    }
}
