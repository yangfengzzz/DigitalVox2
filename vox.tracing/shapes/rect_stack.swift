//
//  rect_stack.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a quad stack
func make_rect_stack(_ steps: vec3i = [1, 1, 1],
                     _ scale: vec3f = [1, 1, 1], _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    for i in 0...steps.z {
        qshape = make_rect([steps.x, steps.y], [scale.x, scale.y], uvscale)
        qshape.positions = qshape.positions.map({ p in
            var p = p
            p.z = (-1 + 2 * Float(i) / Float(steps.z)) * scale.z
            return p
        })
        merge_shape_inplace(&shape, qshape)
    }
    return shape
}

func make_rect_stack(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec3f, _ uvscale: vec2f) {
    fatalError()
}
