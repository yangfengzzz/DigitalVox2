//
//  cube.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_cube(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    let cube_positions: [vec3f] = [
        [-1, -1, +1], [+1, -1, +1],
        [1, +1, +1], [-1, +1, +1], [+1, -1, -1], [-1, -1, -1], [-1, +1, -1],
        [1, +1, -1], [+1, -1, +1], [+1, -1, -1], [+1, +1, -1], [+1, +1, +1],
        [-1, -1, -1], [-1, -1, +1], [-1, +1, +1], [-1, +1, -1], [-1, +1, +1],
        [1, +1, +1], [+1, +1, -1], [-1, +1, -1], [+1, -1, +1], [-1, -1, +1],
        [-1, -1, -1], [+1, -1, -1]]
    let cube_normals: [vec3f] = [
        [0, 0, +1], [0, 0, +1],
        [0, 0, +1], [0, 0, +1], [0, 0, -1], [0, 0, -1], [0, 0, -1], [0, 0, -1],
        [1, 0, 0], [+1, 0, 0], [+1, 0, 0], [+1, 0, 0], [-1, 0, 0], [-1, 0, 0],
        [-1, 0, 0], [-1, 0, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0],
        [0, -1, 0], [0, -1, 0], [0, -1, 0], [0, -1, 0]]
    let cube_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0],
        [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0],
        [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1],
        [1, 1], [1, 0], [0, 0]]
    let cube_quads: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]

    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = cube_quads
        shape.positions = cube_positions
        shape.normals = cube_normals
        shape.texcoords = cube_texcoords
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                cube_quads, cube_positions, subdivisions)
        (shape.quads, shape.normals) = subdivide_quads(
                cube_quads, cube_normals, subdivisions)
        (shape.quads, shape.texcoords) = subdivide_quads(
                cube_quads, cube_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_cube(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}
