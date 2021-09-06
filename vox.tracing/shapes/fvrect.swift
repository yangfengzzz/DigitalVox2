//
//  fvrect.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a facevarying rect
func make_fvrect(_ steps: vec2i = [1, 1],
                 _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1]) -> fvshape_data {
    let rect = make_rect(steps, scale, uvscale)
    var shape = fvshape_data()
    shape.positions = rect.positions
    shape.normals = rect.normals
    shape.texcoords = rect.texcoords
    shape.quadspos = rect.quads
    shape.quadsnorm = rect.quads
    shape.quadstexcoord = rect.quads
    return shape
}

// Make fvquad
func make_fvrect(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ size: vec2f, _ uvscale: vec2f) {
    fatalError()
}
