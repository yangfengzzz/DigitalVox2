//
//  simd_math.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

extension simd_float4x4 {
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

    // convert double4x4 to float4x4
    init(_ m: matrix_double4x4) {
        self.init()
        let matrix: float4x4 = float4x4(SIMD4<Float>(m.columns.0),
                                        SIMD4<Float>(m.columns.1),
                                        SIMD4<Float>(m.columns.2),
                                        SIMD4<Float>(m.columns.3))
        self = matrix
    }
    
    // Returns the identity matrix.
    static func identity() -> simd_float4x4 {
        OZZFloat4x4.identity()
    }

    // Returns a translation matrix.
    // _v.w is ignored.
    static func Translation(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.translation(with: _v)
    }

    // Returns a scaling matrix that scales along _v.
    // _v.w is ignored.
    static func Scaling(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.scaling(with: _v)
    }

    // Returns the rotation matrix built from Euler angles defined by x, y and z
    // components of _v. Euler angles are ordered Heading, Elevation and Bank, or
    // Yaw, Pitch and Roll. _v.w is ignored.
    static func FromEuler(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromEuler(with: _v)
    }

    // Returns the rotation matrix built from axis defined by _axis.xyz and
    // _angle.x
    static func FromAxisAngle(_axis: SIMD4<Float>,
                              _angle: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromAxisAngle(with: _axis, _angle)
    }

    // Returns the rotation matrix built from quaternion defined by x, y, z and w
    // components of _v.
    static func FromQuaternion(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromQuaternion(with: _v)
    }

    // Returns the affine transformation matrix built from split translation,
    // rotation (quaternion) and scale.
    static func FromAffine(_translation: SIMD4<Float>,
                           _quaternion: SIMD4<Float>,
                           _scale: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromAffine(with: _translation, _quaternion, _scale)
    }

    static func *(_ _m: simd_float4x4, _ _v: SIMD4<Float>) -> SIMD4<Float> {
        var _m = _m
        return OZZFloat4x4.mul(with: &_m, vec: _v)
    }

    static func *(_ _a: simd_float4x4, _ _b: simd_float4x4) -> simd_float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.mul(with: &_a, mat: &_b)
    }

    static func +(_ _a: simd_float4x4, _ _b: simd_float4x4) -> simd_float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.add(with: &_a, &_b)
    }

    static func -(_ _a: simd_float4x4, _ _b: simd_float4x4) -> simd_float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.sub(with: &_a, &_b)
    }
}
