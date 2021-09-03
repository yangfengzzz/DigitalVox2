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
}

// Interpolate vertex data
func eval_position(shape: fvshape_data, element: Int, uv: vec2f) -> vec3f {
    fatalError()
}

func eval_normal(shape: fvshape_data, element: Int, uv: vec2f) -> vec3f {
    fatalError()
}

func eval_texcoord(shape: fvshape_data, element: Int, uv: vec2f) -> vec2f {
    fatalError()
}

// Evaluate element normals
func eval_element_normal(shape: fvshape_data, element: Int) -> vec3f {
    fatalError()
}

// Compute per-vertex normals/tangents for lines/triangles/quads.
func compute_normals(shape: fvshape_data) -> [vec3f] {
    fatalError()
}

func compute_normals(normals: inout [vec3f], shape: fvshape_data) {
    fatalError()
}

// Conversions
func fvshape_to_shape(shape: fvshape_data, as_triangles: Bool = false) -> shape_data {
    fatalError()
}

func shape_to_fvshape(shape: shape_data) -> fvshape_data {
    fatalError()
}

// Subdivision
func subdivide_fvshape(shape: fvshape_data, subdivisions: Int, catmullclark: Bool) -> fvshape_data {
    fatalError()
}

// Shape statistics
func fvshape_stats(shape: fvshape_data, verbose: Bool = false) -> [String] {
    fatalError()
}
