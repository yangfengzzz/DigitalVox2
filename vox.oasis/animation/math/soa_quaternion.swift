//
//  soa_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

struct SoaQuaternion {
    var x: SimdFloat4
    var y: SimdFloat4
    var z: SimdFloat4
    var w: SimdFloat4

    init(_ x: SimdFloat4,
         _ y: SimdFloat4,
         _ z: SimdFloat4,
         _ w: SimdFloat4) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    // Loads a quaternion from 4 SimdFloat4 values.
    static func Load(_ _x: _SimdFloat4, _ _y: _SimdFloat4,
                     _ _z: _SimdFloat4, _ _w: SimdFloat4) -> SoaQuaternion {
        return SoaQuaternion(_x, _y, _z, _w)
    }

    // Returns the identity SoaQuaternion.
    static func identity() -> SoaQuaternion {
        let zero = OZZFloat4.zero()
        return SoaQuaternion(zero, zero, zero, OZZFloat4.one())
    }
}

// Returns the conjugate of _q. This is the same as the inverse if _q is
// normalized. Otherwise the magnitude of the inverse is 1.f/|_q|.
func Conjugate(_ _q: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(-_q.x, -_q.y, -_q.z, _q.w)
}

// Returns the negate of _q. This represent the same rotation as q.
prefix func -(_q: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(-_q.x, -_q.y, -_q.z, -_q.w)
}

// Returns the 4D dot product of quaternion _a and _b.
func Dot(_ _a: SoaQuaternion, _ _b: SoaQuaternion) -> SimdFloat4 {
    return _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

// Returns the normalized SoaQuaternion _q.
func Normalize(_ _q: SoaQuaternion) -> SoaQuaternion {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    let inv_len = OZZFloat4.one() / OZZFloat4.sqrt(with: len2)
    return SoaQuaternion(_q.x * inv_len, _q.y * inv_len, _q.z * inv_len,
            _q.w * inv_len)
}

// Returns the estimated normalized SoaQuaternion _q.
func NormalizeEst(_ _q: SoaQuaternion) -> SoaQuaternion {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    // Uses RSqrtEstNR (with one more Newton-Raphson step) as quaternions loose
    // much precision due to normalization.
    let inv_len = OZZFloat4.rSqrtEstNR(with: len2)
    return SoaQuaternion(_q.x * inv_len, _q.y * inv_len, _q.z * inv_len,
            _q.w * inv_len)
}

// Test if each quaternion of _q is normalized.
func IsNormalized(_ _q: SoaQuaternion) -> SimdInt4 {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    return OZZFloat4.cmpLt(with: OZZFloat4.abs(with: len2 - OZZFloat4.one()),
            OZZFloat4.load1(with: kNormalizationToleranceSq))
}

// Test if each quaternion of _q is normalized. using estimated tolerance.
func IsNormalizedEst(_ _q: SoaQuaternion) -> SimdInt4 {
    let len2 = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    return OZZFloat4.cmpLt(with: OZZFloat4.abs(with: len2 - OZZFloat4.one()),
            OZZFloat4.load1(with: kNormalizationToleranceEstSq))
}

// Returns the linear interpolation of SoaQuaternion _a and _b with coefficient
// _f.
func Lerp(_ _a: SoaQuaternion, _ _b: SoaQuaternion,
          _ _f: _SimdFloat4) -> SoaQuaternion {
    SoaQuaternion((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z,
            (_b.w - _a.w) * _f + _a.w)
}

// Returns the linear interpolation of SoaQuaternion _a and _b with coefficient
// _f.
func NLerp(_ _a: SoaQuaternion, _ _b: SoaQuaternion,
           _ _f: _SimdFloat4) -> SoaQuaternion {
    let lerp = SoaFloat4((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z, (_b.w - _a.w) * _f + _a.w)
    let len2 =
            lerp.x * lerp.x + lerp.y * lerp.y + lerp.z * lerp.z + lerp.w * lerp.w
    let inv_len = OZZFloat4.one() / OZZFloat4.sqrt(with: len2)
    return SoaQuaternion(lerp.x * inv_len, lerp.y * inv_len, lerp.z * inv_len,
            lerp.w * inv_len)
}

// Returns the estimated linear interpolation of SoaQuaternion _a and _b with
// coefficient _f.
func NLerpEst(_ _a: SoaQuaternion,
              _ _b: SoaQuaternion, _ _f: _SimdFloat4) -> SoaQuaternion {
    let lerp = SoaFloat4((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z, (_b.w - _a.w) * _f + _a.w)
    let len2 =
            lerp.x * lerp.x + lerp.y * lerp.y + lerp.z * lerp.z + lerp.w * lerp.w
    // Uses RSqrtEstNR (with one more Newton-Raphson step) as quaternions loose
    // much precision due to normalization.
    let inv_len = OZZFloat4.rSqrtEstNR(with: len2)
    return SoaQuaternion(lerp.x * inv_len, lerp.y * inv_len, lerp.z * inv_len,
            lerp.w * inv_len)
}

// Returns the addition of _a and _b.
func +(_a: SoaQuaternion, _b: SoaQuaternion) -> SoaQuaternion {
    SoaQuaternion(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z, _a.w + _b.w)
}

// Returns the multiplication of _q and scalar value _f.
func *(_q: SoaQuaternion, _f: SimdFloat4) -> SoaQuaternion {
    SoaQuaternion(_q.x * _f, _q.y * _f, _q.z * _f, _q.w * _f)
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
    
    return SoaQuaternion(x, y, z, w)
}

// Returns true if each element of _a is equal to each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func ==(_a: SoaQuaternion, _b: SoaQuaternion) -> SimdInt4 {
    let x = OZZFloat4.cmpEq(with: _a.x, _b.x)
    let y = OZZFloat4.cmpEq(with: _a.y, _b.y)
    let z = OZZFloat4.cmpEq(with: _a.z, _b.z)
    let w = OZZFloat4.cmpEq(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}
