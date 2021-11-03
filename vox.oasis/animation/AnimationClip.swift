//
//  AnimationClip.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/3.
//

import MetalKit

class AnimationClip {
    let name: String
    var jointAnimation: [String: Animation?] = [:]
    var duration: Float = 0
    var speed: Float = 1

    init(name: String) {
        self.name = name
    }

    func getPose(at: Float, jointPath: String) -> float4x4? {
        guard let jointAnimation = jointAnimation[jointPath] ?? nil else {
            return nil
        }

        let time = at * speed
        let rotation =
                jointAnimation.getRotation(at: time) ?? simd_quatf()
        let translation =
                jointAnimation.getTranslation(at: time) ?? SIMD3<Float>(repeating: 0)
        let scale =
                jointAnimation.getScales(at: time) ?? SIMD3<Float>(repeating: 1)
        let pose = simd_float4x4(translation: translation) * simd_float4x4(rotation) * simd_float4x4(scaling: scale)
        return pose
    }
}
