//
//  PhysXCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXCharacterControllerDesc: ICharacterControllerDesc {
    internal var _pxControllerDesc: CPxControllerDesc!

    func getType() -> Int {
        Int(_pxControllerDesc.getType().rawValue)
    }
}
