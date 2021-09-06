//
//  box.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a box.
func make_box(_ steps: vec3i = [1, 1, 1],
              _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    // + z
    qshape = make_rect(
            [steps.x, steps.y], [scale.x, scale.y], [uvscale.x, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [p.x, p.y, scale.z]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [0, 0, 1]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // - z
    qshape = make_rect([steps.x, steps.y], [scale.x, scale.y], [uvscale.x, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [-p.x, p.y, -scale.z]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [0, 0, -1]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // + x
    qshape = make_rect([steps.z, steps.y], [scale.z, scale.y], [uvscale.z, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [scale.x, p.y, -p.x]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [1, 0, 0]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // - x
    qshape = make_rect([steps.z, steps.y], [scale.z, scale.y], [uvscale.z, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [-scale.x, p.y, p.x]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [-1, 0, 0]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // + y
    qshape = make_rect([steps.x, steps.z], [scale.x, scale.z], [uvscale.x, uvscale.z])
    for i in 0..<qshape.positions.count {
        qshape.positions[i] = [qshape.positions[i].x, scale.y, -qshape.positions[i].y]
        qshape.normals[i] = [0, 1, 0]
    }
    merge_shape_inplace(&shape, qshape)
    // - y
    qshape = make_rect([steps.x, steps.z], [scale.x, scale.z], [uvscale.x, uvscale.z])
    for i in 0..<qshape.positions.count {
        qshape.positions[i] = [qshape.positions[i].x, -scale.y, qshape.positions[i].y]
        qshape.normals[i] = [0, -1, 0]
    }
    merge_shape_inplace(&shape, qshape)
    return shape
}

// Make a cube.
func make_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
              _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
              _ scale: vec3f, uvscale: vec3f) {
    fatalError()
}
