//
//  point.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a point primitive. Returns points, pos, norm, texcoord, radius.
func make_point(_ radius: Float = 0.001) -> shape_data {
    var shape = shape_data()
    shape.points = [0]
    shape.positions = [[0, 0, 0]]
    shape.normals = [[0, 0, 1]]
    shape.texcoords = [[0, 0]]
    shape.radius = [radius]
    return shape
}

// Generate a point at the origin.
func make_point(_ points: inout [Int], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ point_radius: Float) {
    fatalError()
}
