//
//  simd_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Declare the Quaternion type.
extension SimdQuaternion {
    // Returns the identity quaternion.
    static func identity() -> SimdQuaternion {
        SimdQuaternion(xyzw: simd_float4.w_axis())
    }

    // the angle in radian.
    static func fromAxisAngle(_ _axis: SIMD4<Float>,
                              _ _angle: SIMD4<Float>) -> SimdQuaternion {
        guard areAllTrue1(isNormalizedEst3(_axis)) else {
            fatalError("axis is not normalized.")
        }
        let half_angle = _angle * simd_float4.load1(0.5)
        let half_sin = sinX(half_angle)
        let half_cos = cosX(half_angle)
        return SimdQuaternion(xyzw: setW(_axis * splatX(half_sin), half_cos))
    }

    // Returns a normalized quaternion initialized from an axis and angle cosine
    // representation.
    // Assumes the axis part (x, y, z) of _axis_angle is normalized.
    // _angle.x is the angle cosine in radian, it must be within [-1,1] range.
    static func fromAxisCosAngle(_ _axis: SIMD4<Float>,
                                 _ _cos: SIMD4<Float>) -> SimdQuaternion {
        let one = simd_float4.one()
        let half = simd_float4.load1(0.5)

        guard areAllTrue1(isNormalizedEst3(_axis)) else {
            fatalError("axis is not normalized.")
        }
        guard areAllTrue1(and(cmpGe(_cos, -one),
                cmpLe(_cos, one))) else {
            fatalError("cos is not in [-1,1] range.")
        }

        let half_cos2 = (one + _cos) * half
        let half_sin2 = one - half_cos2
        let half_sincos2 = setY(half_cos2, half_sin2)
        let half_sincos = sqrt(half_sincos2)
        let half_sin = splatY(half_sincos)
        return SimdQuaternion(xyzw: setW(_axis * half_sin, half_sincos))
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis.The input vectors don't need to be
    // normalized, they can be null also.
    static func fromVectors(_ _from: SIMD4<Float>,
                            _ _to: SIMD4<Float>) -> SimdQuaternion {
        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        let norm_from_norm_to =
                sqrtX(length3Sqr(_from) * length3Sqr(_to))
        let norm_from_norm_to_x = getX(norm_from_norm_to)
        if (norm_from_norm_to_x < 1.0e-6) {
            return SimdQuaternion.identity()
        }

        let real_part = norm_from_norm_to + dot3(_from, _to)
        var quat = SimdQuaternion(xyzw: SimdFloat4())
        if (getX(real_part) < 1.0e-6 * norm_from_norm_to_x) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis. Axis normalization can happen later, when we
            // normalize the quaternion.
            var from: [Float] = [0.0, 0.0, 0.0, 0.0]
            storePtrU(_from, &from)
            quat.xyzw = abs(from[0]) > abs(from[2])
                    ? simd_float4.load(-from[1], from[0], 0.0, 0.0)
                    : simd_float4.load(0.0, -from[2], from[1], 0.0)
        } else {
            // This is the general code path.
            quat.xyzw = setW(cross3(_from, _to), real_part)
        }
        return normalize(quat)
    }

    // Returns the quaternion that will rotate vector _from into vector _to,
    // around their plan perpendicular axis. The input vectors must be normalized.
    static func fromUnitVectors(_ _from: SIMD4<Float>,
                                _ _to: SIMD4<Float>) -> SimdQuaternion {
        // http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final
        guard areAllTrue1(and(isNormalizedEst3(_from),
                isNormalizedEst3(_to))) else {
            fatalError("Input vectors must be normalized.")
        }

        let real_part = simd_float4.x_axis() + dot3(_from, _to)
        if (getX(real_part) < 1.0e-6) {
            // If _from and _to are exactly opposite, rotate 180 degrees around an
            // arbitrary orthogonal axis.
            // Normalization isn't needed, as from is already.
            var from: [Float] = [0, 0, 0, 0]
            storePtrU(_from, &from)
            let quat = SimdQuaternion(xyzw:
            abs(from[0]) > abs(from[2])
                    ? simd_float4.load(-from[1], from[0], 0.0, 0.0)
                    : simd_float4.load(0.0, -from[2], from[1], 0.0))
            return quat
        } else {
            // This is the general code path.
            let quat = SimdQuaternion(xyzw: setW(cross3(_from, _to), real_part))
            return normalize(quat)
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
        let p1 = swizzle3332(_a.xyzw) * swizzle0122(_b.xyzw)
        let p2 = swizzle0120(_a.xyzw) * swizzle3330(_b.xyzw)
        let p13 = mAdd(swizzle1201(_a.xyzw), swizzle2011(_b.xyzw), p1)
        let p24 = nMAdd(swizzle2013(_a.xyzw), swizzle1203(_b.xyzw), p2)
        let quat = SimdQuaternion(xyzw: xor(p13 + p24, SimdInt4.mask_sign_w()))
        return quat
    }

    // Returns the negate of _q. This represent the same rotation as q.
    static prefix func -(_ _q: SimdQuaternion) -> SimdQuaternion {
        SimdQuaternion(xyzw: xor(_q.xyzw, SimdInt4.mask_sign()))
    }
}

// Returns the conjugate of _q. This is the same as the inverse if _q is
// normalized. Otherwise the magnitude of the inverse is 1.f/|_q|.
func conjugate(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: xor(_q.xyzw, SimdInt4.mask_sign_xyz()))
}

// Returns the normalized quaternion _q.
func normalize(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: normalize4(_q.xyzw))
}

// Returns the normalized quaternion _q if the norm of _q is not 0.
// Otherwise returns _safer.
func normalizeSafe(_ _q: SimdQuaternion,
                   _ _safer: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: normalizeSafe4(_q.xyzw, _safer.xyzw))
}

// Returns the estimated normalized quaternion _q.
func normalizeEst(_ _q: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: normalizeEst4(_q.xyzw))
}

// Returns the estimated normalized quaternion _q if the norm of _q is not 0.
// Otherwise returns _safer.
func normalizeSafeEst(_ _q: SimdQuaternion,
                      _ _safer: SimdQuaternion) -> SimdQuaternion {
    SimdQuaternion(xyzw: normalizeSafeEst4(_q.xyzw, _safer.xyzw))
}

// Tests if the _q is a normalized quaternion.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
func isNormalized(_ _q: SimdQuaternion) -> SimdInt4 {
    isNormalized4(_q.xyzw)
}

// Tests if the _q is a normalized quaternion.
// Uses the estimated normalization coefficient, that matches estimated math
// functions (RecpEst, MormalizeEst...).
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
func isNormalizedEst(_ _q: SimdQuaternion) -> SimdInt4 {
    isNormalizedEst4(_q.xyzw)
}

// Returns to an axis angle representation of quaternion _q.
// Assumes quaternion _q is normalized.
func toAxisAngle(_ _q: SimdQuaternion) -> SimdFloat4 {
    guard areAllTrue1(isNormalizedEst4(_q.xyzw)) else {
        fatalError("_q is not normalized.")
    }

    let x_axis = simd_float4.x_axis()
    let clamped_w = clamp(-x_axis, splatW(_q.xyzw), x_axis)
    let half_angle = aCosX(clamped_w)

    // Assuming quaternion is normalized then s always positive.
    let s = splatX(sqrtX(nMAdd(clamped_w, clamped_w, x_axis)))
    // If s is close to zero then direction of axis is not important.
    let low = cmpLt(s, simd_float4.load1(1e-3))
    return select(low, x_axis,
            setW(_q.xyzw * rcpEstNR(s), half_angle + half_angle))
}

// Computes the transformation of a Quaternion and a vector _v.
// This is equivalent to carrying out the quaternion multiplications:
// _q.conjugate() * (*this) * _q
// w component of the returned vector is undefined.
func transformVector(_ _q: SimdQuaternion,
                     _ _v: _SimdFloat4) -> SimdFloat4 {
    // http://www.neil.dantam.name/note/dantam-quaternion.pdf
    // _v + 2.f * cross(_q.xyz, cross(_q.xyz, _v) + _q.w * _v)
    let cross1 = mAdd(splatW(_q.xyzw), _v, cross3(_q.xyzw, _v))
    let cross2 = cross3(_q.xyzw, cross1)
    return _v + cross2 + cross2
}
