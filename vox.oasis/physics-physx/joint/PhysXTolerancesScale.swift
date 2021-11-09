//
//  PhysXTolerancesScale.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

extension CPxTolerancesScale {
    static func new() -> CPxTolerancesScale {
        CPxTolerancesScale(length: 1.0, speed: 10.0)
    }
}
