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

// MARK:- float4x4
extension float4x4 {
    // MARK:- Translate
    init(translation: SIMD3<Float>) {
        let matrix = float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }

    // MARK:- Scale
    init(scaling: SIMD3<Float>) {
        let matrix = float4x4(
                [scaling.x, 0, 0, 0],
                [0, scaling.y, 0, 0],
                [0, 0, scaling.z, 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }

    // MARK:- Rotate
    init(rotationX angle: Float) {
        let matrix = float4x4(
                [1, 0, 0, 0],
                [0, cos(angle), sin(angle), 0],
                [0, -sin(angle), cos(angle), 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationY angle: Float) {
        let matrix = float4x4(
                [cos(angle), 0, -sin(angle), 0],
                [0, 1, 0, 0],
                [sin(angle), 0, cos(angle), 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationZ angle: Float) {
        let matrix = float4x4(
                [cos(angle), sin(angle), 0, 0],
                [-sin(angle), cos(angle), 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotation angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }

    init(rotationYXZ angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationY * rotationX * rotationZ
    }

    // MARK:- Identity
    static func identity() -> float4x4 {
        matrix_identity_float4x4
    }
}
