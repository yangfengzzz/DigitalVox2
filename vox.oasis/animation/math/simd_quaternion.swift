//
//  simd_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Declare the Quaternion type.
struct SimdQuaternion {
    var xyzw: SimdFloat4

    // Returns the identity quaternion.
    static func identity() -> SimdQuaternion {
        SimdQuaternion(xyzw: OZZFloat4.w_axis())
    }

    // the angle in radian.
    static func FromAxisAngle(_ _axis: SIMD4<Float>,
                              _ _angle: SIMD4<Float>) -> SimdQuaternion {
        guard OZZInt4.areAllTrue1(with: OZZFloat4.isNormalizedEst3(with: _axis)) else {
            fatalError("axis is not normalized.")
        }
        let half_angle = _angle * OZZFloat4.load1(with: 0.5)
        let half_sin = OZZFloat4.sinX(with: half_angle)
        let half_cos = OZZFloat4.cosX(with: half_angle)
        return SimdQuaternion(xyzw: OZZFloat4.setWWith(_axis * OZZFloat4.splatX(with: half_sin), half_cos))
    }

    // Returns a normalized quaternion initialized from an axis and angle cosine
    // representation.
    // Assumes the axis part (x, y, z) of _axis_angle is normalized.
    // _angle.x is the angle cosine in radian, it must be within [-1,1] range.
    static func FromAxisCosAngle(_ _axis: SIMD4<Float>,
                                 _ _cos: SIMD4<Float>) -> SimdQuaternion {
        let one = OZZFloat4.one()
        let half = OZZFloat4.load1(with: 0.5)

        guard OZZInt4.areAllTrue1(with: OZZFloat4.isNormalizedEst3(with: _axis)) else {
            fatalError("axis is not normalized.")
        }
        guard OZZInt4.areAllTrue1(with: OZZInt4.and(with: OZZFloat4.cmpGe(with: _cos, -one),
                OZZFloat4.cmpLe(with: _cos, one))) else {
            fatalError("cos is not in [-1,1] range.")
        }

        let half_cos2 = (one + _cos) * half
        let half_sin2 = one - half_cos2
        let half_sincos2 = OZZFloat4.setYWith(half_cos2, half_sin2)
        let half_sincos = OZZFloat4.sqrt(with: half_sincos2)
        let half_sin = OZZFloat4.splatY(with: half_sincos)
        return SimdQuaternion(xyzw: OZZFloat4.setWWith(_axis * half_sin, half_sincos))
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis.The input vectors don't need to be
    // normalized, they can be null also.
    static func FromVectors(_ _from: SIMD4<Float>,
                            _ _to: SIMD4<Float>) -> SimdQuaternion {
        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        let norm_from_norm_to =
                OZZFloat4.sqrtX(with: OZZFloat4.length3Sqr(with: _from) * OZZFloat4.length3Sqr(with: _to))
        let norm_from_norm_to_x = OZZFloat4.getXWith(norm_from_norm_to)
        if (norm_from_norm_to_x < 1.0e-6) {
            return SimdQuaternion.identity()
        }

        let real_part = norm_from_norm_to + OZZFloat4.dot3(with: _from, _to)
        var quat = SimdQuaternion(xyzw: SimdFloat4())
        if (OZZFloat4.getXWith(real_part) < 1.0e-6 * norm_from_norm_to_x) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis. Axis normalization can happen later, when we
            // normalize the quaternion.
            var from: [Float] = [0.0, 0.0, 0.0, 0.0]
            OZZFloat4.storePtrU(with: _from, &from)
            quat.xyzw = abs(from[0]) > abs(from[2])
                    ? OZZFloat4.load(with: -from[1], from[0], 0.0, 0.0)
                    : OZZFloat4.load(with: 0.0, -from[2], from[1], 0.0)
        } else {
            // This is the general code path.
            quat.xyzw = OZZFloat4.setWWith(OZZFloat4.cross3(with: _from, _to), real_part)
        }
        return Normalize(quat)
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis. The input vectors must be normalized.
    static func FromUnitVectors(_ _from: SIMD4<Float>,
                                _ _to: SIMD4<Float>) -> SimdQuaternion {
        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        guard OZZInt4.areAllTrue1(with: OZZInt4.and(with: OZZFloat4.isNormalizedEst3(with: _from),
                OZZFloat4.isNormalizedEst3(with: _to))) else {
            fatalError("Input vectors must be normalized.")
        }

        let real_part = OZZFloat4.x_axis() + OZZFloat4.dot3(with: _from, _to)
        if (OZZFloat4.getXWith(real_part) < 1.0e-6) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis.
            // Normalization isn't needed, as from is already.
            var from: [Float] = [0, 0, 0, 0]
            OZZFloat4.storePtrU(with: _from, &from)
            let quat = SimdQuaternion(xyzw:
            abs(from[0]) > abs(from[2])
                    ? OZZFloat4.load(with: -from[1], from[0], 0.0, 0.0)
                    : OZZFloat4.load(with: 0.0, -from[2], from[1], 0.0))
            return quat
        } else {
            // This is the general code path.
            let quat = SimdQuaternion(xyzw: OZZFloat4.setWWith(OZZFloat4.cross3(with: _from, _to), real_part))
            return Normalize(quat)
        }
    }

    // Returns the multiplication of _a and _b. If both _a and _b are normalized,
    // then the result is normalized.
    static func *(_ _a: SimdQuaternion,
                  _ _b: SimdQuaternion) -> SimdQuaternion {
        // Original quaternion multiplication can be swizzled in a simd friendly way
        // if w is negated, and some w multiplications parts (1st/last) are swaped.
        //
        //        p1            p2            p3            p4
        //    _a.w * _b.x + _a.x * _b.w + _a.y * _b.z - _a.z * _b.y
        //    _a.w * _b.y + _a.y * _b.w + _a.z * _b.x - _a.x * _b.z
        //    _a.w * _b.z + _a.z * _b.w + _a.x * _b.y - _a.y * _b.x
        //    _a.w * _b.w - _a.x * _b.x - _a.y * _b.y - _a.z * _b.z
        // ... becomes ->
        //    _a.w * _b.x + _a.x * _b.w + _a.y * _b.z - _a.z * _b.y
        //    _a.w * _b.y + _a.y * _b.w + _a.z * _b.x - _a.x * _b.z
        //    _a.w * _b.z + _a.z * _b.w + _a.x * _b.y - _a.y * _b.x
        // - (_a.z * _b.z + _a.x * _b.x + _a.y * _b.y - _a.w * _b.w)
        let p1 =
                OZZFloat4.swizzle3332(with: _a.xyzw) * OZZFloat4.swizzle0122(with: _b.xyzw)
        let p2 =
                OZZFloat4.swizzle0120(with: _a.xyzw) * OZZFloat4.swizzle3330(with: _b.xyzw)
        let p13 =
                OZZFloat4.mAdd(with: OZZFloat4.swizzle1201(with: _a.xyzw), OZZFloat4.swizzle2011(with: _b.xyzw), p1)
        let p24 =
                OZZFloat4.nmAdd(with: OZZFloat4.swizzle2013(with: _a.xyzw), OZZFloat4.swizzle1203(with: _b.xyzw), p2)
        let quat = SimdQuaternion(xyzw: OZZFloat4.xor(with: p13 + p24, int4: OZZInt4.mask_sign_w()))
        return quat
    }

    // Returns the negate of _q. This represent the same rotation as q.
    static prefix func -(_ _q: SimdQuaternion) -> SimdQuaternion {
        SimdQuaternion(xyzw: OZZFloat4.xor(with: _q.xyzw, int4: OZZInt4.mask_sign()))
    }
}

// Returns the conjugate of _q. This is the same as the inverse if _q is
// normalized. Otherwise the magnitude of the inverse is 1.f/|_q|.
func Conjugate(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: OZZFloat4.xor(with: _q.xyzw, int4: OZZInt4.mask_sign_xyz()))
}

// Returns the normalized quaternion _q.
func Normalize(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: OZZFloat4.normalize4(with: _q.xyzw))
}

// Returns the normalized quaternion _q if the norm of _q is not 0.
// Otherwise returns _safer.
func NormalizeSafe(_ _q: SimdQuaternion,
                   _ _safer: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: OZZFloat4.normalizeSafe4(with: _q.xyzw, _safer.xyzw))
}

// Returns the estimated normalized quaternion _q.
func NormalizeEst(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: OZZFloat4.normalizeEst4(with: _q.xyzw))
}

// Returns the estimated normalized quaternion _q if the norm of _q is not 0.
// Otherwise returns _safer.
func NormalizeSafeEst(_ _q: SimdQuaternion,
                      _ _safer: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: OZZFloat4.normalizeSafeEst4(with: _q.xyzw, _safer.xyzw))
}

// Tests if the _q is a normalized quaternion.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
func IsNormalized(_ _q: SimdQuaternion) -> SimdInt4 {
    OZZFloat4.isNormalized4(with: _q.xyzw)
}

// Tests if the _q is a normalized quaternion.
// Uses the estimated normalization coefficient, that matches estimated math
// functions (RecpEst, MormalizeEst...).
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
func IsNormalizedEst(_ _q: SimdQuaternion) -> SimdInt4 {
    OZZFloat4.isNormalizedEst4(with: _q.xyzw)
}

// Returns to an axis angle representation of quaternion _q.
// Assumes quaternion _q is normalized.
func ToAxisAngle(_ _q: SimdQuaternion) -> SimdFloat4 {
    guard OZZInt4.areAllTrue1(with: OZZFloat4.isNormalizedEst4(with: _q.xyzw)) else {
        fatalError("_q is not normalized.")
    }

    let x_axis = OZZFloat4.x_axis()
    let clamped_w = OZZFloat4.clamp(with: -x_axis, OZZFloat4.splatW(with: _q.xyzw), x_axis)
    let half_angle = OZZFloat4.aCosX(with: clamped_w)

    // Assuming quaternion is normalized then s always positive.
    let s = OZZFloat4.splatX(with: OZZFloat4.sqrtX(with: OZZFloat4.nmAdd(with: clamped_w, clamped_w, x_axis)))
    // If s is close to zero then direction of axis is not important.
    let low = OZZFloat4.cmpLt(with: s, OZZFloat4.load1(with: 1e-3))
    return OZZFloat4.select(with: low, x_axis,
            OZZFloat4.setWWith(_q.xyzw * OZZFloat4.rcpEstNR(with: s), half_angle + half_angle))
}

// Computes the transformation of a Quaternion and a vector _v.
// This is equivalent to carrying out the quaternion multiplications:
// _q.conjugate() * (*this) * _q
// w component of the returned vector is undefined.
func TransformVector(_ _q: SimdQuaternion,
                     _ _v: _SimdFloat4) -> SimdFloat4 {
    // http://www.neil.dantam.name/note/dantam-quaternion.pdf
    // _v + 2.f * cross(_q.xyz, cross(_q.xyz, _v) + _q.w * _v)
    let cross1 = OZZFloat4.mAdd(with: OZZFloat4.splatW(with: _q.xyzw), _v, OZZFloat4.cross3(with: _q.xyzw, _v))
    let cross2 = OZZFloat4.cross3(with: _q.xyzw, cross1)
    return _v + cross2 + cross2
}
