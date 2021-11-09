//
//  PhysXBoxCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXBoxCharacterController: PhysXCharacterController, IBoxCharacterController {
    func setHalfHeight(_ halfHeight: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfHeight(halfHeight)
    }

    func setHalfSideExtent(_ halfSideExtent: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfSideExtent(halfSideExtent)
    }

    func setHalfForwardExtent(_ halfForwardExtent: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfForwardExtent(halfForwardExtent)
    }
}
