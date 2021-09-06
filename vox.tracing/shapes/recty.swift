//
//  recty.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a plane in the xz plane.
func make_recty(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
                _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect(steps, scale, uvscale)
    shape.positions = shape.positions.map { position -> vec3f in
        var position = position
        position = [position.x, position.z, -position.y]
        return position
    }
    shape.normals = shape.normals.map({ normal -> vec3f in
        var normal = normal
        normal = [normal.x, normal.z, normal.y]
        return normal
    })

    return shape
}

// Make a quad.
func make_recty(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}
