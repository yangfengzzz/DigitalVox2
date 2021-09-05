//
//  rect.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/5.
//

import Foundation

// Make a plane.
func make_rect(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
               _ uvscale: vec2f = [1, 1]) -> shape_data {
    make_quads(steps, scale, uvscale)
}

// Make a quad.
func make_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
               _ scale: vec2f, _ uvscale: vec2f) {
    positions = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    normals = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    texcoords = .init(repeating: vec2f(), count: (steps.x + 1) * (steps.y + 1))
    for j in 0...steps.y {
        for i in 0...steps.x {
            let uv = vec2f(Float(i) / Float(steps.x), Float(j) / Float(steps.y))
            positions[j * (steps.x + 1) + i] = [(2 * uv.x - 1) * scale.x, (2 * uv.y - 1) * scale.y, 0]
            normals[j * (steps.x + 1) + i] = [0, 0, 1]
            texcoords[j * (steps.x + 1) + i] = vec2f(uv.x, 1 - uv.y) * uvscale
        }
    }

    quads = .init(repeating: vec4i(), count: steps.x * steps.y)
    for j in 0..<steps.y {
        for i in 0..<steps.x {
            quads[j * steps.x + i] = [
                j * (steps.x + 1) + i,
                j * (steps.x + 1) + i + 1, (j + 1) * (steps.x + 1) + i + 1,
                (j + 1) * (steps.x + 1) + i
            ]
        }
    }
}
