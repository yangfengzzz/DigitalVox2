//
//  bent_floor.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_bent_floor(_ steps: vec2i = [1, 1],
                     _ scale: vec2f = [10, 10], _ uvscale: vec2f = [10, 10],
                     _ radius: Float = 0.5) -> shape_data {
    var shape = make_floor(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, scale.y)
        let start = (scale.y - radius) / 2
        let end = start + radius
        for i in 0..<shape.positions.count {
            if (shape.positions[i].z < -end) {
                shape.positions[i] = [
                    shape.positions[i].x, -shape.positions[i].z - end + radius, -end]
                shape.normals[i] = [0, 0, 1]
            } else if (shape.positions[i].z < -start &&
                    shape.positions[i].z >= -end) {
                let phi: Float = (Float.pi / 2) * (-shape.positions[i].z - start) / radius
                shape.positions[i] = [shape.positions[i].x, -cos(phi) * radius + radius,
                                      -sin(phi) * radius - start]
                shape.normals[i] = [0, cos(phi), sin(phi)]
            } else {
            }
        }
    }
    return shape
}

func make_bent_floor(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                     _ scale: vec2f, _ uvscale: vec2f, _ radius: Float) {
    fatalError()
}
