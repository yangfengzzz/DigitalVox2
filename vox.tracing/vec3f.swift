//
//  vec3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec3f = SIMD3<Float>

public let zero3f = vec3f(0, 0, 0)

public let one3f = vec3f(1, 1, 1)

@inlinable
func dot(_ a: vec3f, _ b: vec3f) -> Float {
    simd_dot(a, b)
}

@inlinable
func cross(_ a: vec3f, _ b: vec3f) -> Float {
    simd_cross(a, b).x
}

@inlinable
func length(_ a: vec3f) -> Float {
    simd_length(a)
}

@inlinable
func length_squared(_ a: vec3f) -> Float {
    simd_length_squared(a)
}

@inlinable
func normalize(_ a: vec3f) -> vec3f {
    simd_normalize(a)
}

@inlinable
func distance(_ a: vec3f, _ b: vec3f) -> Float {
    simd_distance(a, b)
}

@inlinable
func distance_squared(_ a: vec3f, _ b: vec3f) -> Float {
    simd_distance_squared(a, b)
}

@inlinable
func angle(_ a: vec3f, _ b: vec3f) -> Float {
    acos(simd_clamp(dot(normalize(a), normalize(b)), -1.0, 1.0))
}

// Orthogonal vectors.
@inlinable
func orthogonal(_ v: vec3f) -> vec3f {
    // http://lolengine.net/blog/2013/09/21/picking-orthogonal-vector-combing-coconuts)
    abs(v.x) > abs(v.z) ? vec3f(-v.y, v.x, 0) : vec3f(0, -v.z, v.y)
}

@inlinable
func orthonormalize(_ a: vec3f, _ b: vec3f) -> vec3f {
    normalize(a - b * dot(a, b))
}

// Reflected and refracted vector.
@inlinable
func reflect(_ w: vec3f, _ n: vec3f) -> vec3f {
    simd_reflect(w, n)
}

@inlinable
func refract(_ w: vec3f, _ n: vec3f, _ inv_eta: Float) -> vec3f {
    //todo maybe inv bug
    simd_refract(w, n, inv_eta)
}

// Max element and clamp.
@inlinable
func max(_ a: vec3f, _ b: Float) -> vec3f {
    simd_max(a, [b, b, b])
}

@inlinable
func min(_ a: vec3f, _ b: Float) -> vec3f {
    simd_min(a, [b, b, b])
}

@inlinable
func max(_ a: vec3f, _ b: vec3f) -> vec3f {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec3f, _ b: vec3f) -> vec3f {
    simd_min(a, b)
}

@inlinable
func clamp(_ x: vec3f, _ min: Float, _ max: Float) -> vec3f {
    simd_clamp(x, [min, min, min], [max, max, max])
}

@inlinable
func lerp(_ a: vec3f, _ b: vec3f, _ u: Float) -> vec3f {
    a * (1 - u) + b * u
}

@inlinable
func lerp(_ a: vec3f, _ b: vec3f, _ u: vec3f) -> vec3f {
    a * (1 - u) + b * u
}

@inlinable
func max(_ a: vec3f) -> Float {
    a.max()
}

@inlinable
func min(_ a: vec3f) -> Float {
    a.min()
}

@inlinable
func sum(_ a: vec3f) -> Float {
    a.sum()
}

@inlinable
func mean(_ a: vec3f) -> Float {
    sum(a) / 3
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec3f) -> vec3f {
    simd_abs(a)
}

@inlinable
func sqr(_ a: vec3f) -> vec3f {
    a * a
}

@inlinable
func sqrt(_ a: vec3f) -> vec3f {
    a.squareRoot()
}

@inlinable
func exp(_ a: vec3f) -> vec3f {
    [exp(a.x), exp(a.y), exp(a.z)]
}

@inlinable
func log(_ a: vec3f) -> vec3f {
    [log(a.x), log(a.y), log(a.z)]
}

@inlinable
func exp2(_ a: vec3f) -> vec3f {
    [exp2(a.x), exp2(a.y), exp2(a.z)]
}

@inlinable
func log2(_ a: vec3f) -> vec3f {
    [log2(a.x), log2(a.y), log2(a.z)]
}

@inlinable
func pow(_ a: vec3f, _ b: Float) -> vec3f {
    [pow(a.x, b), pow(a.y, b), pow(a.z, b)]
}

@inlinable
func pow(_ a: vec3f, _ b: vec3f) -> vec3f {
    [pow(a.x, b.x), pow(a.y, b.y), pow(a.z, b.z)]
}

@inlinable
func gain(_ a: vec3f, _ b: Float) -> vec3f {
    [gain(a.x, b), gain(a.y, b), gain(a.z, b)]
}

@inlinable
func isfinite(_ a: vec3f) -> Bool {
    a.x.isFinite && a.y.isFinite && a.z.isFinite
}

@inlinable
func swap(_ a: inout vec3f, _ b: inout vec3f) {
    Swift.swap(&a, &b)
}
