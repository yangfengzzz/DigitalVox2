//
//  sphere.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a sphere.
func make_sphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    var shape = make_box([steps, steps, steps], [scale, scale, scale],
            [uvscale, uvscale, uvscale])
    shape.positions = shape.positions.map({ p in
        var p = p
        p = normalize(p) * scale
        return p
    })
    shape.normals = shape.positions
    shape.normals = shape.normals.map({ n in
        var n = n
        n = normalize(n)
        return n
    })
    return shape
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res.
func points_to_spheres(_ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) -> shape_data {
    var shape = shape_data()
    for vertex in vertices {
        var sphere = make_sphere(steps, scale, 1)
        sphere.positions = sphere.positions.map({ position in
            position + vertex
        })
        merge_shape_inplace(&shape, sphere)
    }
    return shape
}

//MARK:- 
// Generate a sphere
func make_sphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                 _ uvscale: Float) {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res and without texcoords and normals.
func points_to_spheres(_ quads: inout [vec4i], _ positions: inout [vec3f],
                       _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                       _ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) {
    fatalError()
}
