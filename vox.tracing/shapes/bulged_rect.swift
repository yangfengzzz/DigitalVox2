//
//  bulged_rect.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/5.
//

import Foundation

func make_bulged_rect(_ steps: vec2i = [1, 1],
                      _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                      _ height: Float = 0.3) -> shape_data {
    var height = height
    var shape = make_rect(steps, scale, uvscale)
    if (height != 0) {
        height = min(height, min(scale))
        let radius = (1 + height * height) / (2 * height)
        let center = vec3f(0, 0, -radius + height)
        for i in 0..<shape.positions.count {
            let pn = normalize(shape.positions[i] - center)
            shape.positions[i] = center + pn * radius
            shape.normals[i] = pn
        }
    }
    return shape
}

func make_bulged_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                      _ scale: vec2f, _ uvscale: vec2f, _ height: Float) {
    fatalError()
}
