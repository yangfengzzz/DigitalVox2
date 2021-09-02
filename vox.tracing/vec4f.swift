//
//  vec4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec4f = SIMD4<Float>

public let zero4f = vec4f(0, 0, 0, 0)

public let one4f = vec4f(1, 1, 1, 1)

@inlinable
func xyz(a: vec4f) -> vec3f {
    [a.x, a.y, a.z]
}

@inlinable
func dot(_ a: vec4f, _ b: vec4f) -> Float {
    simd_dot(a, b)
}

@inlinable
func length(_ a: vec4f) -> Float {
    simd_length(a)
}

@inlinable
func length_squared(_ a: vec4f) -> Float {
    simd_length_squared(a)
}

@inlinable
func normalize(_ a: vec4f) -> vec4f {
    simd_normalize(a)
}

@inlinable
func distance(_ a: vec4f, _ b: vec4f) -> Float {
    simd_distance(a, b)
}

@inlinable
func distance_squared(_ a: vec4f, _ b: vec4f) -> Float {
    simd_distance_squared(a, b)
}

@inlinable
func angle(_ a: vec4f, _ b: vec4f) -> Float {
    return acos(simd_clamp(dot(normalize(a), normalize(b)), -1.0, 1.0))
}

@inlinable
func slerp(_ a: vec4f, _ b: vec4f, _ u: Float) -> vec4f {
    let result = simd_slerp(simd_quatf(ix: a.x, iy: a.y, iz: a.z, r: a.w),
            simd_quatf(ix: b.x, iy: b.y, iz: b.z, r: b.w), u)
    return [result.imag.x, result.imag.y, result.imag.z, result.real]
}

// Max element and clamp.
@inlinable
func max(_ a: vec4f, _ b: Float) -> vec4f {
    simd_max(a, [b, b, b, b])
}

@inlinable
func min(_ a: vec4f, _ b: Float) -> vec4f {
    simd_min(a, [b, b, b, b])
}

@inlinable
func max(_ a: vec4f, _ b: vec4f) -> vec4f {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec4f, _ b: vec4f) -> vec4f {
    simd_min(a, b)
}

@inlinable
func clamp(_ x: vec4f, _ min: Float, _ max: Float) -> vec4f {
    simd_clamp(x, [min, min, min, min], [max, max, max, max])
}

@inlinable
func lerp(_ a: vec4f, _ b: vec4f, _ u: Float) -> vec4f {
    a * (1 - u) + b * u
}

@inlinable
func lerp(_ a: vec4f, _ b: vec4f, _ u: vec4f) -> vec4f {
    a * (1 - u) + b * u
}

@inlinable
func max(_ a: vec4f) -> Float {
    a.max()
}

@inlinable
func min(_ a: vec4f) -> Float {
    a.min()
}

@inlinable
func sum(_ a: vec4f) -> Float {
    a.sum()
}

@inlinable
func mean(_ a: vec4f) -> Float {
    sum(a) / 4
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec4f) -> vec4f {
    simd_abs(a)
}

@inlinable
func sqr(_ a: vec4f) -> vec4f {
    a * a
}

@inlinable
func sqrt(_ a: vec4f) -> vec4f {
    a.squareRoot()
}

@inlinable
func exp(_ a: vec4f) -> vec4f {
    _simd_exp_f4(a)
}

@inlinable
func log(_ a: vec4f) -> vec4f {
    _simd_log_f4(a)
}

@inlinable
func exp2(_ a: vec4f) -> vec4f {
    _simd_exp2_f4(a)
}

@inlinable
func log2(_ a: vec4f) -> vec4f {
    _simd_log2_f4(a)
}

@inlinable
func pow(_ a: vec4f, _ b: Float) -> vec4f {
    _simd_pow_f4(a, [b, b, b, b])
}

@inlinable
func pow(_ a: vec4f, _ b: vec4f) -> vec4f {
    _simd_pow_f4(a, b)
}

@inlinable
func gain(_ a: vec4f, _ b: Float) -> vec4f {
    [gain(a.x, b), gain(a.y, b), gain(a.z, b), gain(a.w, b)]
}

@inlinable
func isfinite(_ a: vec4f) -> Bool {
    a.x.isFinite && a.y.isFinite && a.z.isFinite && a.w.isFinite
}

@inlinable
func swap(_ a: inout vec4f, _ b: inout vec4f) {
    Swift.swap(&a, &b)
}

// Quaternion operations represented as xi + yj + zk + w
// const auto identity_quat4f = vec4f{0, 0, 0, 1}
@inlinable
func quat_mul(_ a: vec4f, _ b: Float) -> vec4f {
    a * b
}

@inlinable
func quat_mul(_ a: vec4f, _ b: vec4f) -> vec4f {
    a * b
}

@inlinable
func quat_conjugate(_ a: vec4f) -> vec4f {
    [-a.x, -a.y, -a.z, a.w]
}

@inlinable
func quat_inverse(_ a: vec4f) -> vec4f {
    quat_conjugate(a) / dot(a, a)
}
