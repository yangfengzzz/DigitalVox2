//
//  random_points.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make random points in a cube. Returns points, pos, norm, texcoord, radius.
func make_random_points(_ num: Int = 65536, _ size: vec3f = [1, 1, 1],
                        _ uvscale: Float = 1, _ radius: Float = 0.001, _ seed: UInt64 = 17) -> shape_data {
    fatalError()
}

// Generate a point set.
func make_random_points(_ points: inout [Int], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                        _ num: Int, size: vec3f, _ uvscale: Float, _ point_radius: Float,
                        _ seed: UInt64) {
    fatalError()
}
