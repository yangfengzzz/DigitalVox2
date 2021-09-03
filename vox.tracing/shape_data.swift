//
//  shape_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// Shape data represented as indexed meshes of elements.
// May contain either points, lines, triangles and quads.
struct shape_data {
    // element data
    var points: [Int] = []
    var lines: [vec2i] = []
    var triangles: [vec3i] = []
    var quads: [vec4i] = []

    // vertex data
    var positions: [vec3f] = []
    var normals: [vec3f] = []
    var texcoords: [vec2f] = []
    var colors: [vec4f] = []
    var radius: [Float]
    var tangents: [vec4f]
}

// Interpolate vertex data
func eval_position(shape: shape_data, element: Int, uv: vec2f) -> vec3f {
    fatalError()
}

func eval_normal(shape: shape_data, element: Int, uv: vec2f) -> vec3f {
    fatalError()
}

func eval_tangent(shape: shape_data, element: Int, uv: vec2f) -> vec3f {
    fatalError()
}

func eval_texcoord(shape: shape_data, element: Int, uv: vec2f) -> vec2f {
    fatalError()
}

func eval_color(shape: shape_data, element: Int, uv: vec2f) -> vec4f {
    fatalError()
}

func eval_radius(shape: shape_data, element: Int, uv: vec2f) -> Float {
    fatalError()
}

// Evaluate element normals
func eval_element_normal(shape: shape_data, element: Int) -> vec3f {
    fatalError()
}

// Compute per-vertex normals/tangents for lines/triangles/quads.
func compute_normals(shape: shape_data) -> [vec3f] {
    fatalError()
}

func compute_normals(normals: inout [vec3f], shape: shape_data) {
    fatalError()
}

// An unevaluated location on a shape
struct shape_point {
    var element: Int = 0
    var uv = vec2f(0, 0)
}

// Shape sampling
func sample_shape_cdf(shape: shape_data) -> [Float] {
    fatalError()
}

func sample_shape_cdf(cdf: inout [Float], shape: shape_data) {
    fatalError()
}

func sample_shape(shape: shape_data, cdf: [Float],
                  rn: Float, ruv: vec2f) -> shape_point {
    fatalError()
}

func sample_shape(shape: shape_data, num_samples: Int, seed: UInt64 = 98729387) -> [shape_point] {
    fatalError()
}

// Conversions
func quads_to_triangles(shape: shape_data) -> shape_data {
    fatalError()
}

func quads_to_triangles_inplace(shape: inout shape_data) {
    fatalError()
}

// Subdivision
func subdivide_shape(shape: shape_data, subdivisions: Int, catmullclark: Bool) -> shape_data {
    fatalError()
}

// Shape statistics
func shape_stats(shape: shape_data, verbose: Bool = false) -> [String] {
    fatalError()
}
