//
//  rounded_uv_cylinder.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a rounded uv cylinder
func make_rounded_uvcylinder(_ steps: vec3i = [32, 32, 32],
                             _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1],
                             _ radius: Float = 0.3) -> shape_data {
    var shape = make_uvcylinder(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, min(scale))
        let c = scale - radius
        for i in 0..<shape.positions.count {
            let phi = atan2(shape.positions[i].y, shape.positions[i].x)
            let r = length(vec2f(shape.positions[i].x, shape.positions[i].y))
            let z = shape.positions[i].z
            let pc = vec2f(r, abs(z))
            let ps: Float = (z < 0) ? -1.0 : 1.0
            if (pc.x >= c.x && pc.y >= c.y) {
                let pn = normalize(pc - c)
                shape.positions[i] = [cos(phi) * (c.x + radius * pn.x), sin(phi) * (c.x + radius * pn.x), ps * (c.y + radius * pn.y)]
                shape.normals[i] = [cos(phi) * pn.x, sin(phi) * pn.x, ps * pn.y]
            } else {
                continue
            }
        }
    }
    return shape
}

// Generate a uvcylinder
func make_rounded_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                             _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                             _ scale: vec2f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}
