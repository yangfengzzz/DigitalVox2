//
//  uv_sphere.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a sphere.
func make_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                   _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect([1, 1], [1, 1])
    for i in 0..<shape.positions.count {
        let uv = shape.texcoords[i]
        let a = vec2f(2 * Float.pi * uv.x, Float.pi * (1 - uv.y))
        shape.positions[i] = vec3f(cos(a.x) * sin(a.y), sin(a.x) * sin(a.y), cos(a.y)) * scale
        shape.normals[i] = normalize(shape.positions[i])
        shape.texcoords[i] = uv * uvscale
    }
    return shape
}

// Generate a uvsphere
func make_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                   _ scale: Float, uvscale: vec2f) {
    fatalError()
}
