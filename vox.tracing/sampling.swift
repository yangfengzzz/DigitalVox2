//
//  sampling.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/5.
//

import Foundation

// -----------------------------------------------------------------------------
// RANDOM NUMBER GENERATION
// -----------------------------------------------------------------------------
// Next random numbers: floats in [0,1), ints in [0,n).
@inlinable
func rand1i(_ n: Int) -> Int {
    Int.random(in: 0..<n)
}

@inlinable
func rand1f() -> Float {
    Float.random(in: 0..<1)
}

@inlinable
func rand2f() -> vec2f {
    // force order of evaluation by using separate assignments.
    let x = rand1f()
    let y = rand1f()
    return [x, y]
}

@inlinable
func rand3f() -> vec3f {
    // force order of evaluation by using separate assignments.
    let x = rand1f()
    let y = rand1f()
    let z = rand1f()
    return [x, y, z]
}

// Shuffles a sequence of elements
@inlinable
func shuffle<T>(_ vals: inout [T]) {
    // https://en.wikipedia.org/wiki/Fisher–Yates_shuffle
    for i in stride(from: vals.count - 1, to: 0, by: -1) {
        let j = rand1i(i + 1)
        vals.swapAt(j, i)
    }
}

// -----------------------------------------------------------------------------
// MONETACARLO SAMPLING FUNCTIONS
// -----------------------------------------------------------------------------
// Sample an hemispherical direction with uniform distribution.
@inlinable
func sample_hemisphere(_ ruv: vec2f) -> vec3f {
    let z: Float = ruv.y
    let r: Float = sqrt(clamp(1.0 - z * z, 0.0, 1.0))
    let phi = 2 * Float.pi * ruv.x
    return [r * cos(phi), r * sin(phi), z]
}

@inlinable
func sample_hemisphere_pdf(_ direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with uniform distribution.
@inlinable
func sample_hemisphere(_ normal: vec3f, _ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_pdf(_ normal: vec3f, _ direction: vec3f) -> Float {
    fatalError()
}

// Sample a spherical direction with uniform distribution.
@inlinable
func sample_sphere(_ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_sphere_pdf(_ w: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine distribution.
@inlinable
func sample_hemisphere_cos(_ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cos_pdf(_ direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine distribution.
@inlinable
func sample_hemisphere_cos(_ normal: vec3f, _ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cos_pdf(_ normal: vec3f, _ direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine power distribution.
@inlinable
func sample_hemisphere_cospower(_ exponent: Float, _  ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cospower_pdf(_ exponent: Float, _ direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine power distribution.
@inlinable
func sample_hemisphere_cospower(_ exponent: Float, _ normal: vec3f, _ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cospower_pdf(_ exponent: Float, _ normal: vec3f, _ direction: vec3f) -> Float {
    fatalError()
}

// Sample a point uniformly on a disk.
@inlinable
func sample_disk(_ ruv: vec2f) -> vec2f {
    fatalError()
}

@inlinable
func sample_disk_pdf(_ point: vec2f) -> Float {
    fatalError()
}

// Sample a point uniformly on a cylinder, without caps.
@inlinable
func sample_cylinder(_ ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_cylinder_pdf(_ point: vec3f) -> Float {
    fatalError()
}

// Sample a point uniformly on a triangle returning the baricentric coordinates.
@inlinable
func sample_triangle(_ ruv: vec2f) -> vec2f {
    fatalError()
}

// Sample a point uniformly on a triangle.
@inlinable
func sample_triangle(_ p0: vec3f, _  p1: vec3f, _ p2: vec3f, _ ruv: vec2f) -> vec3f {
    fatalError()
}

// Pdf for uniform triangle sampling, i.e. triangle area.
@inlinable
func sample_triangle_pdf(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> Float {
    fatalError()
}

// Sample an index with uniform distribution.
@inlinable
func sample_uniform(_ size: Int, _ r: Float) -> Int {
    fatalError()
}

@inlinable
func sample_uniform_pdf(_ size: Int) -> Float {
    fatalError()
}

// Sample an index with uniform distribution.
@inlinable
func sample_uniform(_ elements: [Float], _ r: Float) -> Float {
    fatalError()
}

@inlinable
func sample_uniform_pdf(_ elements: [Float]) -> Float {
    fatalError()
}

// Sample a discrete distribution represented by its cdf.
@inlinable
func sample_discrete(_ cdf: [Float], _ r: Float) -> Int {
    fatalError()
}

// Pdf for uniform discrete distribution sampling.
@inlinable
func sample_discrete_pdf(_ cdf: [Float], _ idx: Int) -> Float {
    fatalError()
}
