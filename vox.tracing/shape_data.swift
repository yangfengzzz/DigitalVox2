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
func eval_position(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> vec3f {
    if (!shape.points.isEmpty) {
        let point = shape.points[element]
        return shape.positions[point]
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return interpolate_line(
                shape.positions[line.x], shape.positions[line.y], uv.x)
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return interpolate_triangle(shape.positions[triangle.x],
                shape.positions[triangle.y], shape.positions[triangle.z], uv)
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return interpolate_quad(shape.positions[quad.x], shape.positions[quad.y],
                shape.positions[quad.z], shape.positions[quad.w], uv)
    } else {
        return [0, 0, 0]
    }
}

func eval_normal(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> vec3f {
    if (shape.normals.isEmpty) {
        return eval_element_normal(shape, element)
    }
    if (!shape.points.isEmpty) {
        let point = shape.points[element]
        return normalize(shape.normals[point])
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return normalize(
                interpolate_line(shape.normals[line.x], shape.normals[line.y], uv.x))
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return normalize(interpolate_triangle(shape.normals[triangle.x],
                shape.normals[triangle.y], shape.normals[triangle.z], uv))
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return normalize(
                interpolate_quad(shape.normals[quad.x], shape.normals[quad.y],
                        shape.normals[quad.z], shape.normals[quad.w], uv))
    } else {
        return [0, 0, 1]
    }
}

func eval_tangent(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> vec3f {
    eval_normal(shape, element, uv)
}

func eval_texcoord(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> vec2f {
    if (shape.texcoords.isEmpty) {
        return uv
    }
    if (!shape.points.isEmpty) {
        let point = shape.points[element]
        return shape.texcoords[point]
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return interpolate_line(
                shape.texcoords[line.x], shape.texcoords[line.y], uv.x)
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return interpolate_triangle(shape.texcoords[triangle.x],
                shape.texcoords[triangle.y], shape.texcoords[triangle.z], uv)
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return interpolate_quad(shape.texcoords[quad.x], shape.texcoords[quad.y],
                shape.texcoords[quad.z], shape.texcoords[quad.w], uv)
    } else {
        return uv
    }
}

func eval_color(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> vec4f {
    if (shape.colors.isEmpty) {
        return [1, 1, 1, 1]
    }
    if (!shape.points.isEmpty) {
        let point = shape.points[element]
        return shape.colors[point]
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return interpolate_line(shape.colors[line.x], shape.colors[line.y], uv.x)
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return interpolate_triangle(shape.colors[triangle.x],
                shape.colors[triangle.y], shape.colors[triangle.z], uv)
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return interpolate_quad(shape.colors[quad.x], shape.colors[quad.y],
                shape.colors[quad.z], shape.colors[quad.w], uv)
    } else {
        return [0, 0]
    }
}

func eval_radius(_ shape: shape_data, _ element: Int, _ uv: vec2f) -> Float {
    if (shape.radius.isEmpty) {
        return 0
    }
    if (!shape.points.isEmpty) {
        let point = shape.points[element]
        return shape.radius[point]
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return interpolate_line(shape.radius[line.x], shape.radius[line.y], uv.x)
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return interpolate_triangle(shape.radius[triangle.x],
                shape.radius[triangle.y], shape.radius[triangle.z], uv)
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return interpolate_quad(shape.radius[quad.x], shape.radius[quad.y],
                shape.radius[quad.z], shape.radius[quad.w], uv)
    } else {
        return 0
    }
}

// Evaluate element normals
func eval_element_normal(_ shape: shape_data, _ element: Int) -> vec3f {
    fatalError()
}

// Compute per-vertex normals/tangents for lines/triangles/quads.
func compute_normals(_ shape: shape_data) -> [vec3f] {
    fatalError()
}

func compute_normals(_ normals: inout [vec3f], _ shape: shape_data) {
    fatalError()
}

// An unevaluated location on a shape
struct shape_point {
    var element: Int = 0
    var uv = vec2f(0, 0)
}

// Shape sampling
func sample_shape_cdf(_ shape: shape_data) -> [Float] {
    fatalError()
}

func sample_shape_cdf(_ cdf: inout [Float], _ shape: shape_data) {
    fatalError()
}

func sample_shape(_ shape: shape_data, _ cdf: [Float],
                  _ rn: Float, _ ruv: vec2f) -> shape_point {
    fatalError()
}

func sample_shape(_ shape: shape_data, _ num_samples: Int, _ seed: UInt64 = 98729387) -> [shape_point] {
    fatalError()
}

// Conversions
func quads_to_triangles(_ shape: shape_data) -> shape_data {
    fatalError()
}

func quads_to_triangles_inplace(_ shape: inout shape_data) {
    fatalError()
}

// Subdivision
func subdivide_shape(_ shape: shape_data, _ subdivisions: Int, _ catmullclark: Bool) -> shape_data {
    fatalError()
}

// Shape statistics
func shape_stats(_ shape: shape_data, _ verbose: Bool = false) -> [String] {
    fatalError()
}
