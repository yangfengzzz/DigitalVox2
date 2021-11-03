//
//  soa_transform.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Stores an affine transformation with separate translation, rotation and scale
// attributes.
struct SoaTransform {
    var translation: SoaFloat3
    var rotation: SoaQuaternion
    var scale: SoaFloat3

    init(_ translation: SoaFloat3,
         _ rotation: SoaQuaternion,
         _ scale: SoaFloat3) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }

    static func identity() -> SoaTransform {
        SoaTransform(SoaFloat3.zero(),
                SoaQuaternion.identity(),
                SoaFloat3.one())
    }
}
