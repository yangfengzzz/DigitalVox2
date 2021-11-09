//
//  PhysXCapsuleCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXCapsuleCharacterController: PhysXCharacterController, ICapsuleCharacterController {
    func setRadius(_ radius: Float) -> Bool {
        (_pxController as! CPxCapsuleController).setRadius(radius)
    }

    func setHeight(_ height: Float) -> Bool {
        (_pxController as! CPxCapsuleController).setHeight(height)
    }

    func setClimbingMode(_ mode: Int) -> Bool {
        (_pxController as! CPxCapsuleController).setClimbingMode(CPxCapsuleClimbingMode(UInt32(mode)))
    }
}
