//
//  uv_cylinder.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a uv cylinder
func make_uvcylinder(_ steps: vec3i = [32, 32, 32],
                     _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    // side
    qshape = make_rect([steps.x, steps.y], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * scale.x, sin(phi) * scale.x, (2 * uv.y - 1) * scale.y]
        qshape.normals[i] = [cos(phi), sin(phi), 0]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.y)
    }
    qshape.quads = qshape.quads.map({ quad in
        [quad.x, quad.w, quad.z, quad.y]
    })
    merge_shape_inplace(&shape, qshape)
    // top
    qshape = make_rect([steps.x, steps.z], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * uv.y * scale.x, sin(phi) * uv.y * scale.x, 0]
        qshape.normals[i] = [0, 0, 1]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.z)
        qshape.positions[i].z = scale.y
    }
    merge_shape_inplace(&shape, qshape)
    // bottom
    qshape = make_rect([steps.x, steps.z], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * uv.y * scale.x, sin(phi) * uv.y * scale.x, 0]
        qshape.normals[i] = [0, 0, 1]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.z)
        qshape.positions[i].z = -scale.y
        qshape.normals[i] = -qshape.normals[i]
    }
    qshape.quads = qshape.quads.map({ qquad in
        [qquad.z, qquad.y, qquad.x]
    })
    merge_shape_inplace(&shape, qshape)
    return shape
}

func polyline_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    var shape = shape_data()
    for idx in 0..<vertices.count - 1 {
        var cylinder = make_uvcylinder([steps, 1, 1], [scale, 1], [1, 1, 1])
        let frame = frame_from_z((vertices[idx] + vertices[idx + 1]) / 2,
                vertices[idx] - vertices[idx + 1])
        let length = distance(vertices[idx], vertices[idx + 1])
        cylinder.positions = cylinder.positions.map({ position in
            transform_point(frame, position * vec3f(1, 1, length / 2))
        })
        cylinder.normals = cylinder.normals.map({ normal in
            transform_direction(frame, normal)
        })
        merge_shape_inplace(&shape, cylinder)
    }
    return shape
}

func lines_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    var shape = shape_data()
    for idx in stride(from: 0, to: vertices.count, by: 2) {
        var cylinder = make_uvcylinder([steps, 1, 1], [scale, 1], [1, 1, 1])
        let frame = frame_from_z((vertices[idx + 0] + vertices[idx + 1]) / 2,
                vertices[idx + 0] - vertices[idx + 1])
        let length = distance(vertices[idx + 0], vertices[idx + 1])
        cylinder.positions = cylinder.positions.map({ position in
            transform_point(frame, position * vec3f(1, 1, length / 2))
        })
        cylinder.normals = cylinder.normals.map({ normal in
            transform_direction(frame, normal)
        })
        merge_shape_inplace(&shape, cylinder)
    }
    return shape
}

func lines_to_cylinders(_ lines: [vec2i], _ positions: [vec3f],
                        _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    var shape = shape_data()
    for line in lines {
        var cylinder = make_uvcylinder([steps, 1, 1], [scale, 1], [1, 1, 1])
        let frame = frame_from_z((positions[line.x] + positions[line.y]) / 2,
                positions[line.x] - positions[line.y])
        let length = distance(positions[line.x], positions[line.y])
        cylinder.positions = cylinder.positions.map({ position in
            transform_point(frame, position * vec3f(1, 1, length / 2))
        })
        cylinder.normals = cylinder.normals.map({ normal in
            transform_direction(frame, normal)
        })
        merge_shape_inplace(&shape, cylinder)
    }
    return shape
}

//MARK:-
// Generate a uvcylinder
func make_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec2f, _ uvscale: vec3f) {
    fatalError()
}

func polyline_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                           _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                           _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ lines: [vec2i], _ vertices: [vec3f], _ steps: Int = 4,
                        _ scale: Float = 0.01) {
    fatalError()
}
