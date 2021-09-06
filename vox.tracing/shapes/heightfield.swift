//
//  heightfield.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a heightfield mesh.
func make_heightfield(_ size: vec2i, _ height: [Float]) -> shape_data {
    var shape = make_recty([size.x - 1, size.y - 1], vec2f(Float(size.x), Float(size.y)) / Float(max(size)), [1, 1])
    for j in 0..<size.y {
        for i in 0..<size.x {
            shape.positions[j * size.x + i].y = height[j * size.x + i]
        }
    }
    shape.normals = quads_normals(shape.quads, shape.positions)
    return shape
}

func make_heightfield(_ size: vec2i, _ color: [vec4f]) -> shape_data {
    var shape = make_recty([size.x - 1, size.y - 1],
            vec2f(Float(size.x), Float(size.y)) / Float(max(size)), [1, 1])
    for j in 0..<size.y {
        for i in 0..<size.x {
            shape.positions[j * size.x + i].y = mean(xyz(color[j * size.x + i]))
        }
    }
    shape.normals = quads_normals(shape.quads, shape.positions)
    return shape
}

// Make a heightfield mesh.
func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ height: [Float]) {
    fatalError()
}

func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ color: [vec4f]) {
    fatalError()
}
