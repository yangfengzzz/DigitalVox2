//
//  fvcube.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_fvcube(_ scale: Float = 1, _ subdivisions: Int = 0) -> fvshape_data {
    let fvcube_positions: [vec3f] = [
        [-1, -1, +1], [+1, -1, +1],
        [1, +1, +1], [-1, +1, +1], [+1, -1, -1], [-1, -1, -1], [-1, +1, -1],
        [1, +1, -1]]
    let fvcube_normals: [vec3f] = [
        [0, 0, +1], [0, 0, +1],
        [0, 0, +1], [0, 0, +1], [0, 0, -1], [0, 0, -1], [0, 0, -1], [0, 0, -1],
        [1, 0, 0], [+1, 0, 0], [+1, 0, 0], [+1, 0, 0], [-1, 0, 0], [-1, 0, 0],
        [-1, 0, 0], [-1, 0, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0],
        [0, -1, 0], [0, -1, 0], [0, -1, 0], [0, -1, 0]]
    let fvcube_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0],
        [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0],
        [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1],
        [1, 1], [1, 0], [0, 0]]
    let fvcube_quadspos: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7],
        [1, 4, 7, 2], [5, 0, 3, 6], [3, 2, 7, 6], [1, 0, 5, 4]]
    let fvcube_quadsnorm: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7],
        [8, 9, 10, 11], [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]
    let fvcube_quadstexcoord: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11],
        [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]

    var shape = fvshape_data()
    if (subdivisions == 0) {
        shape.quadspos = fvcube_quadspos
        shape.quadsnorm = fvcube_quadsnorm
        shape.quadstexcoord = fvcube_quadstexcoord
        shape.positions = fvcube_positions
        shape.normals = fvcube_normals
        shape.texcoords = fvcube_texcoords
    } else {
        (shape.quadspos, shape.positions) = subdivide_quads(
                fvcube_quadspos, fvcube_positions, subdivisions)
        (shape.quadsnorm, shape.normals) = subdivide_quads(
                fvcube_quadsnorm, fvcube_normals, subdivisions)
        (shape.quadstexcoord, shape.texcoords) = subdivide_quads(
                fvcube_quadstexcoord, fvcube_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_fvcube(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
                 _ subdivisions: Int) {
    fatalError()
}
