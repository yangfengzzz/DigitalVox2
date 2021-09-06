//
//  disk.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a disk
func make_disk(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    var shape = make_rect([steps, steps], [1, 1], [uvscale, uvscale])
    shape.positions = shape.positions.map({ position in
        // Analytical Methods for Squaring the Disc, by C. Fong
        // https://arxiv.org/abs/1509.06344
        let xy = vec2f(position.x, position.y)
        let uv = vec2f(xy.x * sqrt(1 - xy.y * xy.y / 2), xy.y * sqrt(1 - xy.x * xy.x / 2))
        return vec3f(uv.x, uv.y, 0) * scale
    })
    return shape
}

// Generate a disk
func make_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
               _ uvscale: Float) {
    fatalError()
}
