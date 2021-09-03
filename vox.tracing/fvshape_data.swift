//
//  fvshape_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// Shape data stored as a face-varying mesh
struct fvshape_data {
    // element data
    var quadspos: [vec4i] = []
    var quadsnorm: [vec4i] = []
    var quadstexcoord: [vec4i] = []

    // vertex data
    var positions: [vec3f] = []
    var normals: [vec3f] = []
    var texcoords: [vec2f] = []

    init() {
    }
}

// Interpolate vertex data
func eval_position(_ shape: fvshape_data, _ element: Int, _ uv: vec2f) -> vec3f {
    if (!shape.quadspos.isEmpty) {
        let quad = shape.quadspos[element]
        return interpolate_quad(shape.positions[quad.x], shape.positions[quad.y],
                shape.positions[quad.z], shape.positions[quad.w], uv)
    } else {
        return [0, 0, 0]
    }
}

func eval_normal(_ shape: fvshape_data, _ element: Int, _ uv: vec2f) -> vec3f {
    if (shape.normals.isEmpty) {
        return eval_element_normal(shape, element)
    }
    if (!shape.quadspos.isEmpty) {
        let quad = shape.quadsnorm[element]
        return normalize(
                interpolate_quad(shape.normals[quad.x], shape.normals[quad.y],
                        shape.normals[quad.z], shape.normals[quad.w], uv))
    } else {
        return [0, 0, 1]
    }
}

func eval_texcoord(_ shape: fvshape_data, _ element: Int, _ uv: vec2f) -> vec2f {
    if (shape.texcoords.isEmpty) {
        return uv
    }
    if (!shape.quadspos.isEmpty) {
        let quad = shape.quadstexcoord[element]
        return interpolate_quad(shape.texcoords[quad.x], shape.texcoords[quad.y],
                shape.texcoords[quad.z], shape.texcoords[quad.w], uv)
    } else {
        return uv
    }
}

// Evaluate element normals
func eval_element_normal(_ shape: fvshape_data, _ element: Int) -> vec3f {
    if (!shape.quadspos.isEmpty) {
        let quad = shape.quadspos[element]
        return quad_normal(shape.positions[quad.x], shape.positions[quad.y],
                shape.positions[quad.z], shape.positions[quad.w])
    } else {
        return [0, 0, 0]
    }
}

// Compute per-vertex normals/tangents for lines/triangles/quads.
func compute_normals(_ shape: fvshape_data) -> [vec3f] {
    if (!shape.quadspos.isEmpty) {
        return quads_normals(shape.quadspos, shape.positions)
    } else {
        return [vec3f](repeating: [0, 0, 1], count: shape.positions.count)
    }
}

func compute_normals(_ normals: inout [vec3f], _ shape: fvshape_data) {
    if (!shape.quadspos.isEmpty) {
        quads_normals(&normals, shape.quadspos, shape.positions)
    } else {
        normals.append(contentsOf: [vec3f](repeating: [0, 0, 1], count: shape.positions.count))
    }
}

// Conversions
func fvshape_to_shape(_ fvshape: fvshape_data, _ as_triangles: Bool = false) -> shape_data {
    var shape = shape_data()
    split_facevarying(&shape.quads, &shape.positions, &shape.normals, &shape.texcoords,
            fvshape.quadspos, fvshape.quadsnorm, fvshape.quadstexcoord,
            fvshape.positions, fvshape.normals, fvshape.texcoords)
    return shape
}

func shape_to_fvshape(_ shape: shape_data) -> fvshape_data {
    if (!shape.points.isEmpty || !shape.lines.isEmpty) {
        fatalError("cannor convert shape")
    }
    var fvshape = fvshape_data()
    fvshape.positions = shape.positions
    fvshape.normals = shape.normals
    fvshape.texcoords = shape.texcoords
    fvshape.quadspos = !shape.quads.isEmpty ? shape.quads
            : triangles_to_quads(shape.triangles)
    fvshape.quadsnorm = !shape.normals.isEmpty ? fvshape.quadspos
            : []
    fvshape.quadstexcoord = !shape.texcoords.isEmpty ? fvshape.quadspos
            : []
    return fvshape
}

// Subdivision
func subdivide_fvshape(_ shape: fvshape_data, _ subdivisions: Int, _ catmullclark: Bool) -> fvshape_data {
    // This should be probably re-implemented in a faster fashion.
    if (subdivisions == 0) {
        return shape
    }
    var subdivided = fvshape_data()
    if (!catmullclark) {
        (subdivided.quadspos, subdivided.positions) = subdivide_quads(
                shape.quadspos, shape.positions, subdivisions)
        (subdivided.quadsnorm, subdivided.normals) = subdivide_quads(
                shape.quadsnorm, shape.normals, subdivisions)
        (subdivided.quadstexcoord, subdivided.texcoords) = subdivide_quads(
                shape.quadstexcoord, shape.texcoords, subdivisions)
    } else {
        (subdivided.quadspos, subdivided.positions) =
                subdivide_catmullclark(shape.quadspos, shape.positions, subdivisions)
        (subdivided.quadsnorm, subdivided.normals) = subdivide_catmullclark(
                shape.quadsnorm, shape.normals, subdivisions)
        (subdivided.quadstexcoord, subdivided.texcoords) =
                subdivide_catmullclark(
                        shape.quadstexcoord, shape.texcoords, subdivisions, true)
    }
    return subdivided
}

// Shape statistics
func fvshape_stats(_ shape: fvshape_data, _ verbose: Bool = false) -> [String] {
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
    stats.append("fvquads:      " + format(shape.quadspos.count))
    stats.append("positions:    " + format(shape.positions.count))
    stats.append("normals:      " + format(shape.normals.count))
    stats.append("texcoords:    " + format(shape.texcoords.count))
    stats.append("center:       " + format3(center(bbox)))
    stats.append("size:         " + format3(size(bbox)))
    stats.append("min:          " + format3(bbox.min))
    stats.append("max:          " + format3(bbox.max))

    return stats
}
