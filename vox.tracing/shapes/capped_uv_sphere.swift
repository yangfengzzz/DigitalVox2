//
//  capped_uv_sphere.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a sphere with slipped caps.
func make_capped_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                          _ uvscale: vec2f = [1, 1], _ cap: Float = 0.3) -> shape_data {
    var shape = make_uvsphere(steps, scale, uvscale)
    if (cap != 0) {
        let cap = min(cap, scale / 2)
        let zflip = (scale - cap)
        for i in 0..<shape.positions.count {
            if (shape.positions[i].z > zflip) {
                shape.positions[i].z = 2 * zflip - shape.positions[i].z
                shape.normals[i].x = -shape.normals[i].x
                shape.normals[i].y = -shape.normals[i].y
            } else if (shape.positions[i].z < -zflip) {
                shape.positions[i].z = 2 * (-zflip) - shape.positions[i].z
                shape.normals[i].x = -shape.normals[i].x
                shape.normals[i].y = -shape.normals[i].y
            }
        }
    }
    return shape
}

func make_capped_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                          _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                          _ scale: Float, uvscale: vec2f, cap: Float) {
    fatalError()
}
