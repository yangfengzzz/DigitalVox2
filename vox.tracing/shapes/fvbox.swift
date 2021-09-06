//
//  fvbox.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a facevarying box
func make_fvbox(_ steps: vec3i = [1, 1, 1],
                _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> fvshape_data {
    var shape = fvshape_data()
    make_fvbox(&shape.quadspos, &shape.quadsnorm, &shape.quadstexcoord,
            &shape.positions, &shape.normals, &shape.texcoords, steps, scale, uvscale)
    return shape
}

func make_fvbox(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                _ size: vec3f, _ uvscale: vec3f) {
    fatalError()
}
