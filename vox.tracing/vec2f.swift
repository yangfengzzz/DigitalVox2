//
//  vec2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec2f = SIMD2<Float>

let zero2f = vec2f(0, 0)

let one2f = vec2f(1, 1)

@inlinable
func dot(_ a: vec2f, _ b: vec2f) -> Float {
    simd_dot(a, b)
}

@inlinable
func cross(_ a: vec2f, _ b: vec2f) -> Float {
    simd_cross(a, b).x
}

@inlinable
func length(_ a: vec2f) -> Float {
    simd_length(a)
}

@inlinable
func length_squared(_ a: vec2f) -> Float {
    simd_length_squared(a)
}

@inlinable
func normalize(_ a: vec2f) -> vec2f {
    simd_normalize(a)
}

@inlinable
func distance(_ a: vec2f, _ b: vec2f) -> Float {
    simd_distance(a, b)
}

@inlinable
func distance_squared(_ a: vec2f, _ b: vec2f) -> Float {
    simd_distance_squared(a, b)
}

@inlinable
func angle(_ a: vec2f, _ b: vec2f) -> Float {
    return acos(simd_clamp(dot(normalize(a), normalize(b)), -1.0, 1.0));
}

// Max element and clamp.
@inlinable
func max(_ a: vec2f, _ b: Float) -> vec2f {
    simd_max(a, [b, b])
}

@inlinable
func min(_ a: vec2f, _ b: Float) -> vec2f {
    simd_min(a, [b, b])
}

@inlinable
func max(_ a: vec2f, _ b: vec2f) -> vec2f {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec2f, _ b: vec2f) -> vec2f {
    simd_min(a, b)
}

@inlinable
func clamp(_ x: vec2f, _ min: Float, _ max: Float) -> vec2f {
    [simd_clamp(x.x, min, max), simd_clamp(x.y, min, max)]
}

@inlinable
func lerp(_ a: vec2f, _ b: vec2f, _ u: Float) -> vec2f {
    a * (1 - u) + b * u
}

@inlinable
func lerp(_ a: vec2f, _ b: vec2f, _ u: vec2f) -> vec2f {
    a * (1 - u) + b * u;
}

@inlinable
func max(_ a: vec2f) -> Float {
    a.max()
}

@inlinable
func min(_ a: vec2f) -> Float {
    a.min()
}

@inlinable
func sum(_ a: vec2f) -> Float {
    a.sum()
}

@inlinable
func mean(_ a: vec2f) -> Float {
    sum(a) / 2
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec2f) -> vec2f {
    simd_abs(a)
}

@inlinable
func sqr(_ a: vec2f) -> vec2f {
    a * a
}

@inlinable
func sqrt(_ a: vec2f) -> vec2f {
    a.squareRoot()
}

@inlinable
func exp(_ a: vec2f) -> vec2f {
    [exp(a.x), exp(a.y)]
}

@inlinable
func log(_ a: vec2f) -> vec2f {
    [log(a.x), log(a.y)]
}

@inlinable
func exp2(_ a: vec2f) -> vec2f {
    [exp2(a.x), exp2(a.y)]
}

@inlinable
func log2(_ a: vec2f) -> vec2f {
    [log2(a.x), log2(a.y)]
}

@inlinable
func isfinite(_ a: vec2f) -> Bool {
    a.x.isInfinite && a.y.isInfinite
}

@inlinable
func pow(_ a: vec2f, _ b: Float) -> vec2f {
    [pow(a.x, b), pow(a.y, b)]
}

@inlinable
func pow(_ a: vec2f, _ b: vec2f) -> vec2f {
    [pow(a.x, b.x), pow(a.y, b.y)]
}

@inlinable
func gain(_ a: vec2f, _ b: Float) -> vec2f {
    [gain(a.x, b), gain(a.y, b)]
}

@inlinable
func swap(_ a: inout vec2f, _ b: inout vec2f) {
    Swift.swap(&a, &b)
}
