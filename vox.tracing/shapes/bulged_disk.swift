//
//  bulged_disk.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a bulged disk
func make_bulged_disk(
        _ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1, _ height: Float = 0.3) -> shape_data {
    var shape = make_disk(steps, scale, uvscale)
    if (height != 0) {
        let height = min(height, scale)
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

func make_bulged_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                      _ uvscale: Float, _ height: Float) {
    fatalError()
}
