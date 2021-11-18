//
//  soa_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

extension SoaQuaternion {
    // Loads a quaternion from 4 SimdFloat4 values.
    static func load(_ _x: _SimdFloat4, _ _y: _SimdFloat4,
                     _ _z: _SimdFloat4, _ _w: SimdFloat4) -> SoaQuaternion {
        SoaQuaternion(x: _x, y: _y, z: _z, w: _w)
    }

    // Returns the identity SoaQuaternion.
    static func identity() -> SoaQuaternion {
        let zero = simd_float4.zero()
        return SoaQuaternion(x: zero, y: zero, z: zero, w: simd_float4.one())
    }
}

// Returns the conjugate of _q. This is the same as the inverse if _q is
// normalized. Otherwise the magnitude of the inverse is 1.f/|_q|.
func conjugate(_ _q: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(x: -_q.x, y: -_q.y, z: -_q.z, w: _q.w)
}

// Returns the negate of _q. This represent the same rotation as q.
prefix func -(_q: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(x: -_q.x, y: -_q.y, z: -_q.z, w: -_q.w)
}

// Returns the 4D dot product of quaternion _a and _b.
func dot(_ _a: SoaQuaternion, _ _b: SoaQuaternion) -> SimdFloat4 {
    _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

// Returns the normalized SoaQuaternion _q.
func normalize(_ _q: SoaQuaternion) -> SoaQuaternion {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaQuaternion(x: _q.x * inv_len, y: _q.y * inv_len, z: _q.z * inv_len,
            w: _q.w * inv_len)
}

// Returns the estimated normalized SoaQuaternion _q.
func normalizeEst(_ _q: SoaQuaternion) -> SoaQuaternion {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    // Uses RSqrtEstNR (with one more Newton-Raphson step) as quaternions loose
    // much precision due to normalization.
    let inv_len = rSqrtEstNR(len2)
    return SoaQuaternion(x: _q.x * inv_len, y: _q.y * inv_len, z: _q.z * inv_len,
            w: _q.w * inv_len)
}

// Test if each quaternion of _q is normalized.
func isNormalized(_ _q: SoaQuaternion) -> SimdInt4 {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceSq))
}

// Test if each quaternion of _q is normalized. using estimated tolerance.
func isNormalizedEst(_ _q: SoaQuaternion) -> SimdInt4 {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceEstSq))
}

// Returns the linear interpolation of SoaQuaternion _a and _b with coefficient
// _f.
func lerp(_ _a: SoaQuaternion, _ _b: SoaQuaternion,
          _ _f: _SimdFloat4) -> SoaQuaternion {
    SoaQuaternion(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y,
            z: (_b.z - _a.z) * _f + _a.z,
            w: (_b.w - _a.w) * _f + _a.w)
}

// Returns the linear interpolation of SoaQuaternion _a and _b with coefficient
// _f.
func nlerp(_ _a: SoaQuaternion, _ _b: SoaQuaternion,
           _ _f: _SimdFloat4) -> SoaQuaternion {
    let lerp = SoaFloat4(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y,
            z: (_b.z - _a.z) * _f + _a.z, w: (_b.w - _a.w) * _f + _a.w)
    let len2 =
            lerp.x * lerp.x + lerp.y * lerp.y + lerp.z * lerp.z + lerp.w * lerp.w
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaQuaternion(x: lerp.x * inv_len, y: lerp.y * inv_len, z: lerp.z * inv_len,
            w: lerp.w * inv_len)
}

// Returns the estimated linear interpolation of SoaQuaternion _a and _b with
// coefficient _f.
func nlerpEst(_ _a: SoaQuaternion,
              _ _b: SoaQuaternion, _ _f: _SimdFloat4) -> SoaQuaternion {
    let lerp = SoaFloat4(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y,
            z: (_b.z - _a.z) * _f + _a.z, w: (_b.w - _a.w) * _f + _a.w)
    let len2 =
            lerp.x * lerp.x + lerp.y * lerp.y + lerp.z * lerp.z + lerp.w * lerp.w
    // Uses RSqrtEstNR (with one more Newton-Raphson step) as quaternions loose
    // much precision due to normalization.
    let inv_len = rSqrtEstNR(len2)
    return SoaQuaternion(x: lerp.x * inv_len, y: lerp.y * inv_len, z: lerp.z * inv_len,
            w: lerp.w * inv_len)
}

// Returns the addition of _a and _b.
func +(_a: SoaQuaternion, _b: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(x: _a.x + _b.x, y: _a.y + _b.y, z: _a.z + _b.z, w: _a.w + _b.w)
}

// Returns the multiplication of _q and scalar value _f.
func *(_q: SoaQuaternion, _f: SimdFloat4) -> SoaQuaternion {
    SoaQuaternion(x: _q.x * _f, y: _q.y * _f, z: _q.z * _f, w: _q.w * _f)
}

// Returns the multiplication of _a and _b. If both _a and _b are normalized,
// then the result is normalized.
func *(_a: SoaQuaternion, _b: SoaQuaternion) -> SoaQuaternion {
    var x = _a.w * _b.x + _a.x * _b.w
    x += _a.y * _b.z - _a.z * _b.y
    var y = _a.w * _b.y + _a.y * _b.w
    y += _a.z * _b.x - _a.x * _b.z
    var z = _a.w * _b.z + _a.z * _b.w
    z += _a.x * _b.y - _a.y * _b.x
    let w = _a.w * _b.w - _a.x * _b.x - _a.y * _b.y - _a.z * _b.z

    return SoaQuaternion(x: x, y: y, z: z, w: w)
}

// Returns true if each element of _a is equal to each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func ==(_a: SoaQuaternion, _b: SoaQuaternion) -> SimdInt4 {
    let x = cmpEq(_a.x, _b.x)
    let y = cmpEq(_a.y, _b.y)
    let z = cmpEq(_a.z, _b.z)
    let w = cmpEq(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}
