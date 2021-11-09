//
//  IBoxCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IBoxCharacterController: ICharacterController {
    func setHalfHeight(_ halfHeight: Float) -> Bool

    func setHalfSideExtent(_ halfSideExtent: Float) -> Bool

    func setHalfForwardExtent(_ halfForwardExtent: Float) -> Bool
}
