//
//  vec3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec3f = SIMD3<Float>

let zero3f = vec3f(0, 0, 0)

let one3f = vec3f(1, 1, 1)

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
    fatalError("TODO")
}

@inlinable
func length_squared(_ a: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func normalize(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func distance(_ a: vec3f, _ b: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func distance_squared(_ a: vec3f, _ b: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func angle(_ a: vec3f, _ b: vec3f) -> Float {
    fatalError("TODO")
}

// Orthogonal vectors.
@inlinable
func orthogonal(_ v: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func orthonormalize(_ a: vec3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

// Reflected and refracted vector.
@inlinable
func reflect(_ w: vec3f, _ n: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func refract(_ w: vec3f, _ n: vec3f, _ inv_eta: Float) -> vec3f {
    fatalError("TODO")
}

// Max element and clamp.
@inlinable
func max(_ a: vec3f, _ b: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3f, _ b: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func clamp(_ x: vec3f, _ min: Float, _ max: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec3f, _ b: vec3f, _ u: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec3f, _ b: vec3f, _ u: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func sum(_ a: vec3f) -> Float {
    fatalError("TODO")
}

@inlinable
func mean(_ a: vec3f) -> Float {
    fatalError("TODO")
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func sqr(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func sqrt(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func exp(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func log(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func exp2(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func log2(_ a: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec3f, _ b: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func gain(_ a: vec3f, _ b: Float) -> vec3f {
    fatalError("TODO")
}

@inlinable
func isfinite(_ a: vec3f) -> Bool {
    fatalError("TODO")
}

@inlinable
func swap(_ a: inout vec3f, _ b: inout vec3f) {
    fatalError("TODO")
}
