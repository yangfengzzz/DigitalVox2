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
        fatalError()
    }

    // Returns a normalized quaternion initialized from an axis and angle cosine
    // representation.
    // Assumes the axis part (x, y, z) of _axis_angle is normalized.
    // _angle.x is the angle cosine in radian, it must be within [-1,1] range.
    static func FromAxisCosAngle(_ _axis: VecFloat3, _  _cos: Float) -> VecQuaternion {
        fatalError()
    }

    // Returns a normalized quaternion initialized from an Euler representation.
    // Euler angles are ordered Heading, Elevation and Bank, or Yaw, Pitch and
    // Roll.
    static func FromEuler(_  _yaw: Float, _   _pitch: Float, _  _roll: Float) -> VecQuaternion {
        fatalError()
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis.The input vectors don't need to be
    // normalized, they can be null as well.
    static func FromVectors(_ _from: VecFloat3, _ _to: VecFloat3) -> VecQuaternion {
        fatalError()
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis. The input vectors must be normalized.
    static func FromUnitVectors(_ _from: VecFloat3, _ _to: VecFloat3) -> VecQuaternion {
        fatalError()
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
// normalized. Otherwise the magnitude of the inverse is 1.f/|_q|.
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
