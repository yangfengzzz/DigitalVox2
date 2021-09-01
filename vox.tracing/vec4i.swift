//
//  vec4i.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias vec4i = SIMD4<Int>

let zero4i = vec4i(0, 0, 0, 0)

@inlinable
func xyz(a: vec4i) -> vec3i {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec4i, _ b: Int) -> vec4i {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4i, _ b: Int) -> vec4i {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec4i, _ b: vec4i) -> vec4i {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4i, _ b: vec4i) -> vec4i {
    fatalError("TODO")
}

@inlinable
func clamp(_ a: vec4i, _ min: Int, _ max: Int) -> vec4i {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec4i) -> Int {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec4i) -> Int {
    fatalError("TODO")
}

@inlinable
func sum(_ a: vec4i) -> Int {
    fatalError("TODO")
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec4i) -> vec4i {
    fatalError("TODO")
}

@inlinable
func swap(_ a: inout vec4i, _ b: inout vec4i) {
    fatalError("TODO")
}
