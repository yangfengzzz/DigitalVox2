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
    fatalError("TODO")
}

@inlinable
func length_squared(_ a: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func normalize(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func distance(_ a: vec2f, _ b: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func distance_squared(_ a: vec2f, _ b: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func angle(_ a: vec2f, _ b: vec2f) -> Float {
    fatalError("TODO")
}

// Max element and clamp.
@inlinable
func max(_ a: vec2f, _ b: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec2f, _ b: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func clamp(_ x: vec2f, _ min: Float, _ max: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec2f, _ b: vec2f, _ u: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: vec2f, _ b: vec2f, _ u: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func sum(_ a: vec2f) -> Float {
    fatalError("TODO")
}

@inlinable
func mean(_ a: vec2f) -> Float {
    fatalError("TODO")
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func sqr(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func sqrt(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func exp(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func log(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func exp2(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func log2(_ a: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func isfinite(_ a: vec2f) -> Bool {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec2f, _ b: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func pow(_ a: vec2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func gain(_ a: vec2f, _ b: Float) -> vec2f {
    fatalError("TODO")
}

@inlinable
func swap(_ a: inout vec2f, _ b: inout vec2f) {
    fatalError("TODO")
}
