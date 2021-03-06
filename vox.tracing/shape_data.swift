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
    var radius: [Float] = []
    var tangents: [vec4f] = []
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
    if (!shape.points.isEmpty) {
        return [0, 0, 1]
    } else if (!shape.lines.isEmpty) {
        let line = shape.lines[element]
        return line_tangent(shape.positions[line.x], shape.positions[line.y])
    } else if (!shape.triangles.isEmpty) {
        let triangle = shape.triangles[element]
        return triangle_normal(shape.positions[triangle.x],
                shape.positions[triangle.y], shape.positions[triangle.z])
    } else if (!shape.quads.isEmpty) {
        let quad = shape.quads[element]
        return quad_normal(shape.positions[quad.x], shape.positions[quad.y],
                shape.positions[quad.z], shape.positions[quad.w])
    } else {
        return [0, 0, 0]
    }
}

// Compute per-vertex normals/tangents for lines/triangles/quads.
func compute_normals(_ shape: shape_data) -> [vec3f] {
    if (!shape.points.isEmpty) {
        return [vec3f](repeating: [0, 0, 1], count: shape.positions.count)
    } else if (!shape.lines.isEmpty) {
        return lines_tangents(shape.lines, shape.positions)
    } else if (!shape.triangles.isEmpty) {
        return triangles_normals(shape.triangles, shape.positions)
    } else if (!shape.quads.isEmpty) {
        return quads_normals(shape.quads, shape.positions)
    } else {
        return [vec3f](repeating: [0, 0, 1], count: shape.positions.count)
    }
}

func compute_normals(_ normals: inout [vec3f], _ shape: shape_data) {
    if (!shape.points.isEmpty) {
        normals.append(contentsOf: [vec3f](repeating: [0, 0, 1], count: shape.positions.count))
    } else if (!shape.lines.isEmpty) {
        lines_tangents(&normals, shape.lines, shape.positions)
    } else if (!shape.triangles.isEmpty) {
        triangles_normals(&normals, shape.triangles, shape.positions)
    } else if (!shape.quads.isEmpty) {
        quads_normals(&normals, shape.quads, shape.positions)
    } else {
        normals.append(contentsOf: [vec3f](repeating: [0, 0, 1], count: shape.positions.count))
    }
}

// An unevaluated location on a shape
struct shape_point {
    var element: Int = 0
    var uv = vec2f(0, 0)

    init(_ element: Int = 0, _ uv: vec2f = [0, 0]) {
        self.element = element
        self.uv = uv
    }
}

// Shape sampling
func sample_shape_cdf(_ shape: shape_data) -> [Float] {
    if (!shape.points.isEmpty) {
        return sample_points_cdf(shape.points.count)
    } else if (!shape.lines.isEmpty) {
        return sample_lines_cdf(shape.lines, shape.positions)
    } else if (!shape.triangles.isEmpty) {
        return sample_triangles_cdf(shape.triangles, shape.positions)
    } else if (!shape.quads.isEmpty) {
        return sample_quads_cdf(shape.quads, shape.positions)
    } else {
        return sample_points_cdf(shape.positions.count)
    }
}

func sample_shape_cdf(_ cdf: inout [Float], _ shape: shape_data) {
    if (!shape.points.isEmpty) {
        sample_points_cdf(&cdf, shape.points.count)
    } else if (!shape.lines.isEmpty) {
        sample_lines_cdf(&cdf, shape.lines, shape.positions)
    } else if (!shape.triangles.isEmpty) {
        sample_triangles_cdf(&cdf, shape.triangles, shape.positions)
    } else if (!shape.quads.isEmpty) {
        sample_quads_cdf(&cdf, shape.quads, shape.positions)
    } else {
        sample_points_cdf(&cdf, shape.positions.count)
    }
}

func sample_shape(_ shape: shape_data, _ cdf: [Float],
                  _ rn: Float, _ ruv: vec2f) -> shape_point {
    if (!shape.points.isEmpty) {
        let element = sample_points(cdf, rn)
        return shape_point(element, [0, 0])
    } else if (!shape.lines.isEmpty) {
        let (element, u) = sample_lines(cdf, rn, ruv.x)
        return shape_point(element, [u, 0])
    } else if (!shape.triangles.isEmpty) {
        let (element, uv) = sample_triangles(cdf, rn, ruv)
        return shape_point(element, uv)
    } else if (!shape.quads.isEmpty) {
        let (element, uv) = sample_quads(cdf, rn, ruv)
        return shape_point(element, uv)
    } else {
        let element = sample_points(cdf, rn)
        return shape_point(element, [0, 0])
    }
}

func sample_shape(_ shape: shape_data, _ num_samples: Int, _ seed: UInt64 = 98729387) -> [shape_point] {
    fatalError()
}

// Conversions
func quads_to_triangles(_ shape: shape_data) -> shape_data {
    var result = shape
    if (!shape.quads.isEmpty) {
        result.triangles = quads_to_triangles(shape.quads)
        result.quads = []
    }
    return result
}

func quads_to_triangles_inplace(_ shape: inout shape_data) {
    if (shape.quads.isEmpty) {
        return
    }
    shape.triangles = quads_to_triangles(shape.quads)
    shape.quads = []
}

// Subdivision
func subdivide_shape(_ shape: shape_data, _ subdivisions: Int, _ catmullclark: Bool) -> shape_data {
    // This should probably be re-implemented in a faster fashion,
    // but how it is not obvious
    if (subdivisions == 0) {
        return shape
    }
    var subdivided = shape_data()
    if (!subdivided.points.isEmpty) {
        subdivided = shape
    } else if (!subdivided.lines.isEmpty) {
        (_, subdivided.normals) = subdivide_lines(
                shape.lines, shape.normals, subdivisions)
        (_, subdivided.texcoords) = subdivide_lines(
                shape.lines, shape.texcoords, subdivisions)
        (_, subdivided.colors) = subdivide_lines(
                shape.lines, shape.colors, subdivisions)
        (_, subdivided.radius) = subdivide_lines(
                subdivided.lines, shape.radius, subdivisions)
        (subdivided.lines, subdivided.positions) = subdivide_lines(
                shape.lines, shape.positions, subdivisions)
    } else if (!subdivided.triangles.isEmpty) {
        (_, subdivided.normals) = subdivide_triangles(
                shape.triangles, shape.normals, subdivisions)
        (_, subdivided.texcoords) = subdivide_triangles(
                shape.triangles, shape.texcoords, subdivisions)
        (_, subdivided.colors) = subdivide_triangles(
                shape.triangles, shape.colors, subdivisions)
        (_, subdivided.radius) = subdivide_triangles(
                shape.triangles, shape.radius, subdivisions)
        (subdivided.triangles, subdivided.positions) = subdivide_triangles(
                shape.triangles, shape.positions, subdivisions)
    } else if (!subdivided.quads.isEmpty && !catmullclark) {
        (_, subdivided.normals) = subdivide_quads(
                shape.quads, shape.normals, subdivisions)
        (_, subdivided.texcoords) = subdivide_quads(
                shape.quads, shape.texcoords, subdivisions)
        (_, subdivided.colors) = subdivide_quads(
                shape.quads, shape.colors, subdivisions)
        (_, subdivided.radius) = subdivide_quads(
                shape.quads, shape.radius, subdivisions)
        (subdivided.quads, subdivided.positions) = subdivide_quads(
                shape.quads, shape.positions, subdivisions)
    } else if (!subdivided.quads.isEmpty && catmullclark) {
        (_, subdivided.normals) = subdivide_catmullclark(
                shape.quads, shape.normals, subdivisions)
        (_, subdivided.texcoords) = subdivide_catmullclark(
                shape.quads, shape.texcoords, subdivisions)
        (_, subdivided.colors) = subdivide_catmullclark(
                shape.quads, shape.colors, subdivisions)
        (_, subdivided.radius) = subdivide_catmullclark(
                shape.quads, shape.radius, subdivisions)
        (subdivided.quads, subdivided.positions) = subdivide_catmullclark(
                shape.quads, shape.positions, subdivisions)
    } else {
        // empty shape
    }
    return subdivided
}

// Shape statistics
func shape_stats(_ shape: shape_data, _ verbose: Bool = false) -> [String] {
    let format = { (num: Int) -> String in
        var str = String(num)
        while (str.count < 13) {
            str = " " + str
        }
        return str
    }
    let format3 = { (num: vec3f) -> String in
        var str = String(num.x) + " " + String(num.y) + " " + String(num.z)
        while (str.count < 13) {
            str = " " + str
        }
        return str
    }

    var bbox = invalidb3f
    for pos in shape.positions {
        bbox = merge(bbox, pos)
    }

    var stats: [String] = []
    stats.append("points:       " + format(shape.points.count))
    stats.append("lines:        " + format(shape.lines.count))
    stats.append("triangles:    " + format(shape.triangles.count))
    stats.append("quads:        " + format(shape.quads.count))
    stats.append("positions:    " + format(shape.positions.count))
    stats.append("normals:      " + format(shape.normals.count))
    stats.append("texcoords:    " + format(shape.texcoords.count))
    stats.append("colors:       " + format(shape.colors.count))
    stats.append("radius:       " + format(shape.radius.count))
    stats.append("center:       " + format3(center(bbox)))
    stats.append("size:         " + format3(size(bbox)))
    stats.append("min:          " + format3(bbox.min))
    stats.append("max:          " + format3(bbox.max))

    return stats
}
