//
//  rounded_box.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_rounded_box(_ steps: vec3i = [1, 1, 1],
                      _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1],
                      _ radius: Float = 0.3) -> shape_data {
    var shape = make_box(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, min(scale))
        let c = scale - radius
        for i in 0..<shape.positions.count {
            let pc = vec3f(abs(shape.positions[i].x), abs(shape.positions[i].y),
                    abs(shape.positions[i].z))
            let ps = vec3f(shape.positions[i].x < 0 ? -1.0 : 1.0,
                    shape.positions[i].y < 0 ? -1.0 : 1.0,
                    shape.positions[i].z < 0 ? -1.0 : 1.0)
            if (pc.x >= c.x && pc.y >= c.y && pc.z >= c.z) {
                let pn = normalize(pc - c)
                shape.positions[i] = c + radius * pn
                shape.normals[i] = pn
            } else if (pc.x >= c.x && pc.y >= c.y) {
                let pn = normalize((pc - c) * vec3f(1, 1, 0))
                shape.positions[i] = [c.x + radius * pn.x, c.y + radius * pn.y, pc.z]
                shape.normals[i] = pn
            } else if (pc.x >= c.x && pc.z >= c.z) {
                let pn = normalize((pc - c) * vec3f(1, 0, 1))
                shape.positions[i] = [c.x + radius * pn.x, pc.y, c.z + radius * pn.z]
                shape.normals[i] = pn
            } else if (pc.y >= c.y && pc.z >= c.z) {
                let pn = normalize((pc - c) * vec3f(0, 1, 1))
                shape.positions[i] = [pc.x, c.y + radius * pn.y, c.z + radius * pn.z]
                shape.normals[i] = pn
            } else {
                continue
            }
            shape.positions[i] *= ps
            shape.normals[i] *= ps
        }
    }
    return shape
}

func make_rounded_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                      _ scale: vec3f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}
