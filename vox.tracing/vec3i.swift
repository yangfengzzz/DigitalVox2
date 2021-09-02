//
//  vec3i.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias vec3i = SIMD3<Int>

public let zero3i = vec3i(0, 0, 0)

@inlinable
func max(_ a: vec3i, _ b: Int) -> vec3i {
    simd_max(a, [b, b])
}

@inlinable
func min(_ a: vec3i, _ b: Int) -> vec3i {
    simd_min(a, [b, b])
}

@inlinable
func max(_ a: vec3i, _ b: vec3i) -> vec3i {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec3i, _ b: vec3i) -> vec3i {
    simd_max(a, b)
}

@inlinable
func clamp(_ a: vec3i, _ min: Int, _ max: Int) -> vec3i {
    simd_clamp(a, [min, min], [max, max])
}

@inlinable
func max(_ a: vec3i) -> Int {
    a.max()
}

@inlinable
func min(_ a: vec3i) -> Int {
    a.min()
}

@inlinable
func sum(_ a: vec3i) -> Int {
    a.wrappedSum()
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec3i) -> vec3i {
    simd_abs(a)
}

@inlinable
func swap(_ a: inout vec3i, _ b: inout vec3i) {
    Swift.swap(&a, &b)
}
