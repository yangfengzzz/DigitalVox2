//
//  soa_transform.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Stores an affine transformation with separate translation, rotation and scale
// attributes.
extension SoaTransform {
    static func identity() -> SoaTransform {
        SoaTransform(translation: SoaFloat3.zero(),
                rotation: SoaQuaternion.identity(),
                scale: SoaFloat3.one())
    }
}
