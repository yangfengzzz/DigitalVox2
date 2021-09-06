//
//  uv_disk.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a uv disk
func make_uvdisk(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                 _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect(steps, [1, 1], [1, 1])
    for i in 0..<shape.positions.count {
        let uv = shape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        shape.positions[i] = vec3f(cos(phi) * uv.y, sin(phi) * uv.y, 0) * scale
        shape.normals[i] = [0, 0, 1]
        shape.texcoords[i] = uv * uvscale
    }
    return shape
}

// Generate a uvdisk
func make_uvdisk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}
