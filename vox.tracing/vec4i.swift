//
//  vec4i.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias vec4i = SIMD4<Int>

public let zero4i = vec4i(0, 0, 0, 0)

@inlinable
func xyz(_ a: vec4i) -> vec3i {
    [a.x, a.y, a.z]
}

@inlinable
func max(_ a: vec4i, _ b: Int) -> vec4i {
    simd_max(a, [b, b, b, b])
}

@inlinable
func min(_ a: vec4i, _ b: Int) -> vec4i {
    simd_min(a, [b, b, b, b])
}

@inlinable
func max(_ a: vec4i, _ b: vec4i) -> vec4i {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec4i, _ b: vec4i) -> vec4i {
    simd_min(a, b)
}

@inlinable
func clamp(_ a: vec4i, _ min: Int, _ max: Int) -> vec4i {
    simd_clamp(a, [min, min], [max, max])
}

@inlinable
func max(_ a: vec4i) -> Int {
    a.max()
}

@inlinable
func min(_ a: vec4i) -> Int {
    a.min()
}

@inlinable
func sum(_ a: vec4i) -> Int {
    a.wrappedSum()
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec4i) -> vec4i {
    simd_abs(a)
}

@inlinable
func swap(_ a: inout vec4i, _ b: inout vec4i) {
    Swift.swap(&a, &b)
}
