//
//  fvsphere.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a facevarying sphere
func make_fvsphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> fvshape_data {
    var shape = fvshape_data()
    make_fvsphere(&shape.quadspos, &shape.quadsnorm, &shape.quadstexcoord,
            &shape.positions, &shape.normals, &shape.texcoords, steps, scale, uvscale)
    return shape
}

func make_fvsphere(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                   _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ size: Float,
                   _ uvscale: Float) {
    fatalError()
}
