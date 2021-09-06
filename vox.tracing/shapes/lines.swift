//
//  lines.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Generate lines set along a quad. Returns lines, pos, norm, texcoord, radius.
func make_lines(_ steps: vec2i = [4, 65536],
                _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                _ rad: vec2f = [0.001, 0.001]) -> shape_data {
    var shape = shape_data()
    shape.positions = .init(repeating: vec3f(), count: (steps.x + 1) * steps.y)
    shape.normals = .init(repeating: vec3f(), count: (steps.x + 1) * steps.y)
    shape.texcoords = .init(repeating: vec2f(), count: (steps.x + 1) * steps.y)
    shape.radius = .init(repeating: 0, count: (steps.x + 1) * steps.y)
    if (steps.y > 1) {
        for j in 0..<steps.y {
            for i in 0...steps.x {
                let uv = vec2f(Float(i) / Float(steps.x), Float(j) / Float(steps.y - 1))
                shape.positions[j * (steps.x + 1) + i] = [(uv.x - 0.5) * scale.x, (uv.y - 0.5) * scale.y, 0]
                shape.normals[j * (steps.x + 1) + i] = [1, 0, 0]
                shape.texcoords[j * (steps.x + 1) + i] = uv * uvscale
                shape.radius[j * (steps.x + 1) + i] = interpolate_line(rad.x, rad.y, uv.x)
            }
        }
    } else {
        for i in 0...steps.x {
            let uv = vec2f(Float(i) / Float(steps.x), 0)
            shape.positions[i] = [(uv.x - 0.5) * scale.x, 0, 0]
            shape.normals[i] = [1, 0, 0]
            shape.texcoords[i] = uv * uvscale
            shape.radius[i] = interpolate_line(rad.x, rad.y, uv.x)
        }
    }

    shape.lines = .init(repeating: vec2i(), count: steps.x * steps.y)
    for j in 0..<steps.y {
        for i in 0..<steps.x {
            shape.lines[j * steps.x + i] = [j * (steps.x + 1) + i, j * (steps.x + 1) + i + 1]
        }
    }

    return shape
}

// Generate lines set along a quad.
func make_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                _ rad: vec2f) {
    fatalError()
}
