//
//  points.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a point set on a grid. Returns points, pos, norm, texcoord, radius.
func make_points(_ num: Int = 65536, _ uvscale: Float = 1, _ radius: Float = 0.001) -> shape_data {
    var shape = shape_data()
    shape.points = .init(repeating: 0, count: num)
    for i in 0..<num {
        shape.points[i] = i
    }
    shape.positions.append(contentsOf: [vec3f](repeating: vec3f(), count: num))
    shape.normals.append(contentsOf: [vec3f](repeating: vec3f(0, 0, 1), count: num))
    shape.texcoords.append(contentsOf: [vec2f](repeating: vec2f(), count: num))
    shape.radius.append(contentsOf: [Float](repeating: radius, count: num))
    for i in 0..<shape.texcoords.count {
        shape.texcoords[i] = [Float(i) / Float(num), 0]
    }
    return shape
}

func make_points(_ steps: vec2i = [256, 256],
                 _ size: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                 _ radius: vec2f = [0.001, 0.001]) -> shape_data {
    var shape = make_rect(steps, size, uvscale)
    shape.quads = []
    shape.points = .init(repeating: 0, count: shape.positions.count)
    for i in 0..<shape.positions.count {
        shape.points[i] = i
    }
    shape.radius = .init(repeating: 0.0, count: shape.positions.count)
    for i in 0..<shape.texcoords.count {
        shape.radius[i] = interpolate_line(radius.x, radius.y, shape.texcoords[i].y / uvscale.y)
    }
    return shape
}

// Generate a point set with points placed at the origin with texcoords
// varying along u.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ num: Int, _ uvscale: Float, _ point_radius: Float) {
    fatalError()
}

// Generate a point set along a quad.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                 _ rad: vec2f) {
    fatalError()
}
