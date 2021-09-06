//
//  uv_spherey.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_uvspherey(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                    _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_uvsphere(steps, scale, uvscale)
    shape.positions = shape.positions.map({ position in
        [position.x, position.z, position.y]
    })
    shape.normals = shape.normals.map({ normal in
        [normal.x, normal.z, normal.y]
    })
    shape.texcoords = shape.texcoords.map({ texcoord in
        [texcoord.x, 1 - texcoord.y]
    })
    shape.quads = shape.quads.map({ quad in
        [quad.x, quad.w, quad.z, quad.y]
    })
    return shape
}

func make_uvspherey(_ quads: inout [vec4i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                    _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}
