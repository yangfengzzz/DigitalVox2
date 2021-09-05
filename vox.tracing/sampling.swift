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
func shuffle<T>(vals: inout [T]) {
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
func sample_hemisphere(ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_pdf(direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with uniform distribution.
@inlinable
func sample_hemisphere(normal: vec3f, ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_pdf(normal: vec3f, direction: vec3f) -> Float {
    fatalError()
}

// Sample a spherical direction with uniform distribution.
@inlinable
func sample_sphere(ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_sphere_pdf(w: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine distribution.
@inlinable
func sample_hemisphere_cos(ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cos_pdf(direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine distribution.
@inlinable
func sample_hemisphere_cos(normal: vec3f, ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cos_pdf(normal: vec3f, direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine power distribution.
@inlinable
func sample_hemisphere_cospower(exponent: Float, ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cospower_pdf(exponent: Float, direction: vec3f) -> Float {
    fatalError()
}

// Sample an hemispherical direction with cosine power distribution.
@inlinable
func sample_hemisphere_cospower(exponent: Float, normal: vec3f, ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_hemisphere_cospower_pdf(exponent: Float, normal: vec3f, direction: vec3f) -> Float {
    fatalError()
}

// Sample a point uniformly on a disk.
@inlinable
func sample_disk(ruv: vec2f) -> vec2f {
    fatalError()
}

@inlinable
func sample_disk_pdf(point: vec2f) -> Float {
    fatalError()
}

// Sample a point uniformly on a cylinder, without caps.
@inlinable
func sample_cylinder(ruv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func sample_cylinder_pdf(point: vec3f) -> Float {
    fatalError()
}

// Sample a point uniformly on a triangle returning the baricentric coordinates.
@inlinable
func sample_triangle(ruv: vec2f) -> vec2f {
    fatalError()
}

// Sample a point uniformly on a triangle.
@inlinable
func sample_triangle(p0: vec3f, p1: vec3f, p2: vec3f, ruv: vec2f) -> vec3f {
    fatalError()
}

// Pdf for uniform triangle sampling, i.e. triangle area.
@inlinable
func sample_triangle_pdf(p0: vec3f, p1: vec3f, p2: vec3f) -> Float {
    fatalError()
}

// Sample an index with uniform distribution.
@inlinable
func sample_uniform(size: Int, r: Float) -> Int {
    fatalError()
}

@inlinable
func sample_uniform_pdf(size: Int) -> Float {
    fatalError()
}

// Sample an index with uniform distribution.
@inlinable
func sample_uniform(elements: [Float], r: Float) -> Float {
    fatalError()
}

@inlinable
func sample_uniform_pdf(elements: [Float]) -> Float {
    fatalError()
}

// Sample a discrete distribution represented by its cdf.
@inlinable
func sample_discrete(cdf: [Float], r: Float) -> Int {
    fatalError()
}

// Pdf for uniform discrete distribution sampling.
@inlinable
func sample_discrete_pdf(cdf: [Float], idx: Int) -> Float {
    fatalError()
}
