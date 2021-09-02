//
//  vec2i.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias vec2i = SIMD2<Int>

public let zero2i = vec2i(0, 0)

@inlinable
func max(_ a: vec2i, _ b: Int) -> vec2i {
    simd_max(a, [b, b])
}

@inlinable
func min(_ a: vec2i, _ b: Int) -> vec2i {
    simd_min(a, [b, b])
}

@inlinable
func max(_ a: vec2i, _ b: vec2i) -> vec2i {
    simd_max(a, b)
}

@inlinable
func min(_ a: vec2i, _ b: vec2i) -> vec2i {
    simd_max(a, b)
}

@inlinable
func clamp(_ a: vec2i, _ min: Int, _ max: Int) -> vec2i {
    simd_clamp(a, [min, min], [max, max])
}

@inlinable
func max(_ a: vec2i) -> Int {
    a.max()
}

@inlinable
func min(_ a: vec2i) -> Int {
    a.min()
}

@inlinable
func sum(_ a: vec2i) -> Int {
    a.wrappedSum()
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec2i) -> vec2i {
    simd_abs(a)
}

@inlinable
func swap(_ a: inout vec2i, _ b: inout vec2i) {
    Swift.swap(&a, &b)
}
