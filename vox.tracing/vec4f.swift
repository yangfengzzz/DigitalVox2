//
//  vec4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec4f = SIMD4<Float>

let zero4f = vec4f(0, 0, 0, 0)

let one4f = vec4f(1, 1, 1, 1)

@inlinable
func xyz(a: vec4f) -> vec3f {
    [a.x, a.y, a.z];
}

@inlinable
func dot(_ a: vec4f, _ b: vec4f) -> Float {
    simd_dot(a, b)
}

@inlinable
func length(_ a: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func length_squared(_ a: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func normalize(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func distance(_ a: vec4f, _ b: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func distance_squared(_ a: vec4f, _ b: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func angle(_ a: vec4f, _ b: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func slerp(_ a: vec4f, _ b: vec4f, _ u: Float) -> vec4f {
    fatalError("TODO")
}

// Max element and clamp.
@inlinable
func max(_ a: vec4f, _ b: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4f, _ b: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec4f, _ b: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4f, _ b: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func clamp(_ x: vec4f, _ min: Float, _ max: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec4f, _ b: vec4f, _ u: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec4f, _ b: vec4f, _ u: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func sum(_ a: vec4f) -> Float {
    fatalError("TODO")
}

@inlinable
func mean(_ a: vec4f) -> Float {
    fatalError("TODO")
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func sqr(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func sqrt(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func exp(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func log(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func exp2(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func log2(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec4f, _ b: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec4f, _ b: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func gain(_ a: vec4f, _ b: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func isfinite(_ a: vec4f) -> Bool {
    fatalError("TODO")
}

@inlinable
func swap(_ a: inout vec4f, _ b: inout vec4f) {
    fatalError("TODO")
}

// Quaternion operations represented as xi + yj + zk + w
// const auto identity_quat4f = vec4f{0, 0, 0, 1};
@inlinable
func quat_mul(_ a: vec4f, _ b: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func quat_mul(_ a: vec4f, _ b: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func quat_conjugate(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func quat_inverse(_ a: vec4f) -> vec4f {
    fatalError("TODO")
}
