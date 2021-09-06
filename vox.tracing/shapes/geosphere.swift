//
//  geosphere.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

func make_geosphere(_ scale: Float = 1, _  subdivisions: Int = 0) -> shape_data {
    // https://stackoverflow.com/questions/17705621/algorithm-for-a-geodesic-sphere
    let X: Float = 0.525731112119133606
    let Z: Float = 0.850650808352039932
    let geosphere_positions: [vec3f] = [
        [-X, 0.0, Z], [X, 0.0, Z],
        [-X, 0.0, -Z], [X, 0.0, -Z], [0.0, Z, X], [0.0, Z, -X], [0.0, -Z, X],
        [0.0, -Z, -X], [Z, X, 0.0], [-Z, X, 0.0], [Z, -X, 0.0], [-Z, -X, 0.0]]
    let geosphere_triangles: [vec3i] = [
        [0, 1, 4], [0, 4, 9],
        [9, 4, 5], [4, 8, 5], [4, 1, 8], [8, 1, 10], [8, 10, 3], [5, 8, 3],
        [5, 3, 2], [2, 3, 7], [7, 3, 10], [7, 10, 6], [7, 6, 11], [11, 6, 0],
        [0, 6, 1], [6, 10, 1], [9, 11, 0], [9, 2, 11], [9, 5, 2], [7, 11, 2]]

    var shape = shape_data()
    if (subdivisions == 0) {
        shape.triangles = geosphere_triangles
        shape.positions = geosphere_positions
        shape.normals = geosphere_positions
    } else {
        (shape.triangles, shape.positions) = subdivide_triangles(
                geosphere_triangles, geosphere_positions, subdivisions)
        shape.positions = shape.positions.map({ position in
            normalize(position)
        })
        shape.normals = shape.positions
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_geosphere(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ scale: Float, _ subdivisions: Int) {
    fatalError()
}
