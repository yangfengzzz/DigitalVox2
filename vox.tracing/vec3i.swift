//
//  vec3i.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias vec3i = SIMD3<Int>

let zero3i = vec3i(0, 0, 0)

@inlinable
func max(_ a: vec3i, _ b: Int) -> vec3i {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3i, _ b: Int) -> vec3i {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec3i, _ b: vec3i) -> vec3i {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3i, _ b: vec3i) -> vec3i {
    fatalError("TODO")
}

@inlinable
func clamp(_ a: vec3i, _ min: Int, _ max: Int) -> vec3i {
    fatalError("TODO")
}

@inlinable
func max(_ a: vec3i) -> Int {
    fatalError("TODO")
}

@inlinable
func min(_ a: vec3i) -> Int {
    fatalError("TODO")
}

@inlinable
func sum(_ a: vec3i) -> Int {
    fatalError("TODO")
}

// Functions applied to vector elements
@inlinable
func abs(_ a: vec3i) -> vec3i {
    fatalError("TODO")
}

@inlinable
func swap(_ a: inout vec3i, _ b: inout vec3i) {
    fatalError("TODO")
}
