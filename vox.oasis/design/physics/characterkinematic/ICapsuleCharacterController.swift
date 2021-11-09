//
//  ICapsuleCharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ICapsuleCharacterController: ICharacterController {
    func setRadius(_ radius: Float) -> Bool

    func setHeight(_ height: Float) -> Bool

    func setClimbingMode(_ mode: Int) -> Bool
}
