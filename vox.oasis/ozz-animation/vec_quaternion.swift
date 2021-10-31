//
//  vec_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

struct VecQuaternion {
    var x: Float
    var y: Float
    var z: Float
    var w: Float

    // Constructs an uninitialized quaternion.
    init() {
        x = 0
        y = 0
        z = 0
        w = 0
    }

    // Constructs a quaternion from 4 floating point values.
    init(_ _x: Float, _  _y: Float, _  _z: Float, _  _w: Float) {
        x = _x
        y = _y
        z = _z
        w = _w
    }

    // Returns a normalized quaternion initialized from an axis angle
    // representation.
    // Assumes the axis part (x, y, z) of _axis_angle is normalized.
    // _angle.x is the angle in radian.
    static func FromAxisAngle(_ _axis: VecFloat3, _  _angle: Float) -> VecQuaternion {
        guard IsNormalized(_axis) else {
            fatalError("axis is not normalized.")
        }
        let half_angle = _angle * 0.5
        let half_sin = sin(half_angle)
        let half_cos = cos(half_angle)
        return VecQuaternion(_axis.x * half_sin, _axis.y * half_sin, _axis.z * half_sin, half_cos)
    }

    // Returns a normalized quaternion initialized from an axis and angle cosine
    // representation.
    // Assumes the axis part (x, y, z) of _axis_angle is normalized.
    // _angle.x is the angle cosine in radian, it must be within [-1,1] range.
    static func FromAxisCosAngle(_ _axis: VecFloat3, _  _cos: Float) -> VecQuaternion {
        guard IsNormalized(_axis) else {
            fatalError("axis is not normalized.")
        }
        guard _cos >= -1.0 && _cos <= 1.0 else {
            fatalError("cos is not in [-1,1] range.")
        }

        let half_cos2 = (1.0 + _cos) * 0.5
        let half_sin = sqrt(1.0 - half_cos2)
        return VecQuaternion(_axis.x * half_sin, _axis.y * half_sin, _axis.z * half_sin, sqrt(half_cos2))
    }

    // Returns a normalized quaternion initialized from an Euler representation.
    // Euler angles are ordered Heading, Elevation and Bank, or Yaw, Pitch and
    // Roll.
    static func FromEuler(_  _yaw: Float, _   _pitch: Float, _  _roll: Float) -> VecQuaternion {
        let half_yaw = _yaw * 0.5
        let c1 = cos(half_yaw)
        let s1 = sin(half_yaw)
        let half_pitch = _pitch * 0.5
        let c2 = cos(half_pitch)
        let s2 = sin(half_pitch)
        let half_roll = _roll * 0.5
        let c3 = cos(half_roll)
        let s3 = sin(half_roll)
        let c1c2 = c1 * c2
        let s1s2 = s1 * s2
        return VecQuaternion(c1c2 * s3 + s1s2 * c3, s1 * c2 * c3 + c1 * s2 * s3,
                c1 * s2 * c3 - s1 * c2 * s3, c1c2 * c3 - s1s2 * s3)
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis.The input vectors don't need to be
    // normalized, they can be null as well.
    static func FromVectors(_ _from: VecFloat3, _ _to: VecFloat3) -> VecQuaternion {
        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        let norm_from_norm_to = sqrt(LengthSqr(_from) * LengthSqr(_to))
        if (norm_from_norm_to < 1.0e-5) {
            return VecQuaternion.identity()
        }
        let real_part = norm_from_norm_to + Dot(_from, _to)
        var quat = VecQuaternion()
        if (real_part < 1.0e-6 * norm_from_norm_to) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis. Axis normalization can happen later, when we
            // normalize the quaternion.
            quat = abs(_from.x) > abs(_from.z)
                    ? VecQuaternion(-_from.y, _from.x, 0.0, 0.0)
                    : VecQuaternion(0.0, -_from.z, _from.y, 0.0)
        } else {
            let cross = Cross(_from, _to)
            quat = VecQuaternion(cross.x, cross.y, cross.z, real_part)
        }
        return Normalize(quat)
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis. The input vectors must be normalized.
    static func FromUnitVectors(_ _from: VecFloat3, _ _to: VecFloat3) -> VecQuaternion {
        guard IsNormalized(_from) && IsNormalized(_to) else {
            fatalError("Input vectors must be normalized.")
        }

        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        let real_part = 1.0 + Dot(_from, _to)
        if (real_part < 1.0e-6) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis.
            // Normalisation isn't needed, as from is already.
            return abs(_from.x) > abs(_from.z)
                    ? VecQuaternion(-_from.y, _from.x, 0.0, 0.0)
                    : VecQuaternion(0.0, -_from.z, _from.y, 0.0)
        } else {
            let cross = Cross(_from, _to)
            return Normalize(VecQuaternion(cross.x, cross.y, cross.z, real_part))
        }
    }

    // Returns the identity quaternion.
    static func identity() -> VecQuaternion {
        VecQuaternion(0.0, 0.0, 0.0, 1.0)
    }
}

// Returns true if each element of a is equal to each element of _b.
func ==(_a: VecQuaternion, _b: VecQuaternion) -> Bool {
    _a.x == _b.x && _a.y == _b.y && _a.z == _b.z && _a.w == _b.w
}

// Returns true if one element of a differs from one element of _b.
func !=(_a: VecQuaternion, _b: VecQuaternion) -> Bool {
    _a.x != _b.x || _a.y != _b.y || _a.z != _b.z || _a.w != _b.w
}

// Returns the conjugate of _q. This is the same as the inverse if _q is
// normalized. Otherwise the magnitude of the inverse is 1.0/|_q|.
func Conjugate(_ _q: VecQuaternion) -> VecQuaternion {
    VecQuaternion(-_q.x, -_q.y, -_q.z, _q.w)
}

// Returns the addition of _a and _b.
func +(_a: VecQuaternion, _b: VecQuaternion) -> VecQuaternion {
    VecQuaternion(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z, _a.w + _b.w)
}

// Returns the multiplication of _q and a scalar _f.
func *(_q: VecQuaternion, _f: Float) -> VecQuaternion {
    VecQuaternion(_q.x * _f, _q.y * _f, _q.z * _f, _q.w * _f)
}

// Returns the multiplication of _a and _b. If both _a and _b are normalized,
// then the result is normalized.
func *(_a: VecQuaternion, _b: VecQuaternion) -> VecQuaternion {
    VecQuaternion(_a.w * _b.x + _a.x * _b.w + _a.y * _b.z - _a.z * _b.y,
            _a.w * _b.y + _a.y * _b.w + _a.z * _b.x - _a.x * _b.z,
            _a.w * _b.z + _a.z * _b.w + _a.x * _b.y - _a.y * _b.x,
            _a.w * _b.w - _a.x * _b.x - _a.y * _b.y - _a.z * _b.z)
}

// Returns the negate of _q. This represent the same rotation as q.
prefix func -(_q: VecQuaternion) -> VecQuaternion {
    VecQuaternion(-_q.x, -_q.y, -_q.z, -_q.w)
}

// Returns true if the angle between _a and _b is less than _tolerance.
func Compare(_ _a: VecQuaternion, _ _b: VecQuaternion,
             _ _cos_half_tolerance: Float) -> Bool {
    // Computes w component of a-1 * b.
    let cos_half_angle = _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
    return abs(cos_half_angle) >= _cos_half_tolerance
}

// Returns true if _q is a normalized quaternion.
func IsNormalized(_ _q: VecQuaternion) -> Bool {
    let sq_len = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    return abs(sq_len - 1.0) < kNormalizationToleranceSq
}

// Returns the normalized quaternion _q.
func Normalize(_ _q: VecQuaternion) -> VecQuaternion {
    let sq_len = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    guard sq_len != 0.0 else {
        fatalError("_q is not normalizable")
    }
    let inv_len = 1.0 / sqrt(sq_len)
    return VecQuaternion(_q.x * inv_len, _q.y * inv_len, _q.z * inv_len, _q.w * inv_len)
}

// Returns the normalized quaternion _q if the norm of _q is not 0.
// Otherwise returns _safer.
func NormalizeSafe(_ _q: VecQuaternion,
                   _ _safer: VecQuaternion) -> VecQuaternion {
    guard IsNormalized(_safer) else {
        fatalError("_safer is not normalized")
    }
    let sq_len = _q.x * _q.x + _q.y * _q.y + _q.z * _q.z + _q.w * _q.w
    if (sq_len == 0) {
        return _safer
    }
    let inv_len = 1.0 / sqrt(sq_len)
    return VecQuaternion(_q.x * inv_len, _q.y * inv_len, _q.z * inv_len, _q.w * inv_len)
}

// Returns to an axis angle representation of quaternion _q.
// Assumes quaternion _q is normalized.
func ToAxisAngle(_ _q: VecQuaternion) -> VecFloat4 {
    assert(IsNormalized(_q))
    let clamped_w = simd_clamp(-1.0, _q.w, 1.0)
    let angle = 2.0 * acos(clamped_w)
    let s = sqrt(1.0 - clamped_w * clamped_w)

    // Assuming quaternion normalized then s always positive.
    if (s < 0.001) {  // Tests to avoid divide by zero.
        // If s close to zero then direction of axis is not important.
        return VecFloat4(1.0, 0.0, 0.0, angle)
    } else {
        // Normalize axis
        let inv_s = 1.0 / s
        return VecFloat4(_q.x * inv_s, _q.y * inv_s, _q.z * inv_s, angle)
    }
}

// Returns to an Euler representation of quaternion _q.
// Quaternion _q does not require to be normalized.
func ToEuler(_ _q: VecQuaternion) -> VecFloat3 {
    let sqw = _q.w * _q.w
    let sqx = _q.x * _q.x
    let sqy = _q.y * _q.y
    let sqz = _q.z * _q.z
    // If normalized is one, otherwise is correction factor.
    let unit = sqx + sqy + sqz + sqw
    let test = _q.x * _q.y + _q.z * _q.w
    var euler = VecFloat3()
    if (test > 0.499 * unit) {  // Singularity at north pole
        euler.x = 2.0 * atan2(_q.x, _q.w)
        euler.y = kPi_2
        euler.z = 0
    } else if (test < -0.499 * unit) {  // Singularity at south pole
        euler.x = -2 * atan2(_q.x, _q.w)
        euler.y = -kPi_2
        euler.z = 0
    } else {
        euler.x = atan2(2.0 * _q.y * _q.w - 2.0 * _q.x * _q.z,
                sqx - sqy - sqz + sqw)
        euler.y = asin(2.0 * test / unit)
        euler.z = atan2(2.0 * _q.x * _q.w - 2.0 * _q.y * _q.z,
                -sqx + sqy - sqz + sqw)
    }
    return euler
}

// Returns the dot product of _a and _b.
func Dot(_ _a: VecQuaternion, _ _b: VecQuaternion) -> Float {
    return _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

// Returns the linear interpolation of quaternion _a and _b with coefficient
// _f.
func Lerp(_ _a: VecQuaternion, _ _b: VecQuaternion, _f: Float) -> VecQuaternion {
    return VecQuaternion((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z, (_b.w - _a.w) * _f + _a.w)
}

// Returns the linear interpolation of quaternion _a and _b with coefficient
// _f. _a and _n must be from the same hemisphere (aka dot(_a, _b) >= 0).
func NLerp(_ _a: VecQuaternion, _ _b: VecQuaternion,
           _ _f: Float) -> VecQuaternion {
    let lerp = VecFloat4((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z, (_b.w - _a.w) * _f + _a.w)
    let sq_len = lerp.x * lerp.x + lerp.y * lerp.y + lerp.z * lerp.z + lerp.w * lerp.w
    let inv_len = 1.0 / sqrt(sq_len)
    return VecQuaternion(lerp.x * inv_len, lerp.y * inv_len, lerp.z * inv_len,
            lerp.w * inv_len)
}

// Returns the spherical interpolation of quaternion _a and _b with
// coefficient _f.
func SLerp(_ _a: VecQuaternion, _ _b: VecQuaternion,
           _ _f: Float) -> VecQuaternion {
    assert(IsNormalized(_a))
    assert(IsNormalized(_b))
    // Calculate angle between them.
    let cos_half_theta = _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w

    // If _a=_b or _a=-_b then theta = 0 and we can return _a.
    if (abs(cos_half_theta) >= 0.999) {
        return _a
    }

    // Calculate temporary values.
    let half_theta = acos(cos_half_theta)
    let sin_half_theta = sqrt(1.0 - cos_half_theta * cos_half_theta)

    // If theta = pi then result is not fully defined, we could rotate around
    // any axis normal to _a or _b.
    if (sin_half_theta < 0.001) {
        return VecQuaternion((_a.x + _b.x) * 0.5, (_a.y + _b.y) * 0.5,
                (_a.z + _b.z) * 0.5, (_a.w + _b.w) * 0.5)
    }

    let ratio_a = sin((1.0 - _f) * half_theta) / sin_half_theta
    let ratio_b = sin(_f * half_theta) / sin_half_theta

    // Calculate Quaternion.
    return VecQuaternion(
            ratio_a * _a.x + ratio_b * _b.x, ratio_a * _a.y + ratio_b * _b.y,
            ratio_a * _a.z + ratio_b * _b.z, ratio_a * _a.w + ratio_b * _b.w)
}

// Computes the transformation of a Quaternion and a vector _v.
// This is equivalent to carrying out the quaternion multiplications:
// _q.conjugate() * (*this) * _q
func TransformVector(_ _q: VecQuaternion, _ _v: VecFloat3) -> VecFloat3 {
    // http://www.neil.dantam.name/note/dantam-quaternion.pdf
    // _v + 2.0 * cross(_q.xyz, cross(_q.xyz, _v) + _q.w * _v)
    let a = VecFloat3(_q.y * _v.z - _q.z * _v.y + _v.x * _q.w,
            _q.z * _v.x - _q.x * _v.z + _v.y * _q.w,
            _q.x * _v.y - _q.y * _v.x + _v.z * _q.w)
    let b = VecFloat3(_q.y * a.z - _q.z * a.y, _q.z * a.x - _q.x * a.z,
            _q.x * a.y - _q.y * a.x)
    return VecFloat3(_v.x + b.x + b.x, _v.y + b.y + b.y, _v.z + b.z + b.z)
}

