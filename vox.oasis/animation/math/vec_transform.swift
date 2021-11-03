//
//  vec_transform.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Stores an affine transformation with separate translation, rotation and scale
// attributes.
struct VecTransform {
    // Translation affine transformation component.
    var translation: VecFloat3

    // Rotation affine transformation component.
    var rotation: VecQuaternion

    // Scale affine transformation component.
    var scale: VecFloat3

    init(_ translation: VecFloat3, _ rotation: VecQuaternion, _ scale: VecFloat3) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }

    // Builds an identity transform.
    static func identity() -> VecTransform {
        VecTransform(VecFloat3.zero(), VecQuaternion.identity(), VecFloat3.one())
    }
}
