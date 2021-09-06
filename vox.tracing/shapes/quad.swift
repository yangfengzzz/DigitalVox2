//
//  quad.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_quad(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    let quad_positions: [vec3f] = [
        [-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]]
    let quad_normals: [vec3f] = [
        [0, 0, 1], [0, 0, 1], [0, 0, 1], [0, 0, 1]]
    let quad_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0], [0, 0]]
    let quad_quads: [vec4i] = [[0, 1, 2, 3]]
    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = quad_quads
        shape.positions = quad_positions
        shape.normals = quad_normals
        shape.texcoords = quad_texcoords
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                quad_quads, quad_positions, subdivisions)
        (shape.quads, shape.normals) = subdivide_quads(
                quad_quads, quad_normals, subdivisions)
        (shape.quads, shape.texcoords) = subdivide_quads(
                quad_quads, quad_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_quad(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}
