//
//  PhysXCharacterControllerManager.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXCharacterControllerManager: ICharacterControllerManager {
    internal var _pxControllerManager: CPxControllerManager!

    func purgeControllers() {
        _pxControllerManager.purgeControllers()
    }

    func createController(_ desc: ICharacterControllerDesc) -> ICharacterController {
        let pxController = _pxControllerManager.createController((desc as! PhysXCharacterControllerDesc)._pxControllerDesc)
        if desc.getType() == CPxControllerShapeType_eCAPSULE.rawValue {
            let controller = PhysXCapsuleCharacterController()
            controller._pxController = pxController
            return controller
        } else {
            let controller = PhysXBoxCharacterController()
            controller._pxController = pxController
            return controller
        }
    }

    func computeInteractions(_ elapsedTime: Float) {
        _pxControllerManager.computeInteractions(elapsedTime)
    }

    func setTessellation(_ flag: Bool, _ maxEdgeLength: Float) {
        _pxControllerManager.setTessellation(flag, maxEdgeLength)
    }

    func setOverlapRecoveryModule(_ flag: Bool) {
        _pxControllerManager.setOverlapRecoveryModule(flag)
    }

    func setPreciseSweeps(_ flag: Bool) {
        _pxControllerManager.setPreciseSweeps(flag)
    }

    func setPreventVerticalSlidingAgainstCeiling(_ flag: Bool) {
        _pxControllerManager.setPreventVerticalSlidingAgainstCeiling(flag)
    }

    func shiftOrigin(_ shift: Vector3) {
        _pxControllerManager.shiftOrigin(shift.elements)
    }
}
