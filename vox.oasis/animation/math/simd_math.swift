//
//  simd_math.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

extension Float4x4 {
    // Returns the identity matrix.
    static func identity() -> Float4x4 {
        OZZFloat4x4.identity()
    }

    // Returns a translation matrix.
    // _v.w is ignored.
    static func Translation(_v: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.translation(with: _v)
    }

    // Returns a scaling matrix that scales along _v.
    // _v.w is ignored.
    static func Scaling(_v: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.scaling(with: _v)
    }

    // Returns the rotation matrix built from Euler angles defined by x, y and z
    // components of _v. Euler angles are ordered Heading, Elevation and Bank, or
    // Yaw, Pitch and Roll. _v.w is ignored.
    static func FromEuler(_v: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.fromEuler(with: _v)
    }

    // Returns the rotation matrix built from axis defined by _axis.xyz and
    // _angle.x
    static func FromAxisAngle(_axis: SIMD4<Float>,
                              _angle: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.fromAxisAngle(with: _axis, _angle)
    }

    // Returns the rotation matrix built from quaternion defined by x, y, z and w
    // components of _v.
    static func FromQuaternion(_v: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.fromQuaternion(with: _v)
    }

    // Returns the affine transformation matrix built from split translation,
    // rotation (quaternion) and scale.
    static func FromAffine(_translation: SIMD4<Float>,
                           _quaternion: SIMD4<Float>,
                           _scale: SIMD4<Float>) -> Float4x4 {
        OZZFloat4x4.fromAffine(with: _translation, _quaternion, _scale)
    }

    static func *(_ _m: Float4x4, _ _v: SIMD4<Float>) -> SIMD4<Float> {
        var _m = _m
        return OZZFloat4x4.mul(with: &_m, vec: _v)
    }

    static func *(_ _a: Float4x4, _ _b: Float4x4) -> Float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.mul(with: &_a, mat: &_b)
    }

    static func +(_ _a: Float4x4, _ _b: Float4x4) -> Float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.add(with: &_a, &_b)
    }

    static func -(_ _a: Float4x4, _ _b: Float4x4) -> Float4x4 {
        var _a = _a
        var _b = _b
        return OZZFloat4x4.sub(with: &_a, &_b)
    }
}
