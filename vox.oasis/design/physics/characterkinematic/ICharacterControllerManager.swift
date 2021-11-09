//
//  ICharacterControllerManager.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ICharacterControllerManager {
    func purgeControllers();

    func createController(_ desc: ICharacterControllerDesc) -> ICharacterController

    func computeInteractions(_ elapsedTime: Float)

    func setTessellation(_ flag: Bool, _ maxEdgeLength: Float)

    func setOverlapRecoveryModule(_ flag: Bool)

    func setPreciseSweeps(_ flag: Bool)

    func setPreventVerticalSlidingAgainstCeiling(_ flag: Bool)

    func shiftOrigin(_ shift: Vector3)
}
