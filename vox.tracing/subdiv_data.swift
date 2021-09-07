//
//  subdiv_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Subdiv data represented as face-varying primitives where
// each vertex data has its own topology.
struct subdiv_data {
    // face-varying primitives
    var quadspos: [vec4i] = []
    var quadsnorm: [vec4i] = []
    var quadstexcoord: [vec4i] = []

    // vertex data
    var positions: [vec3f] = []
    var normals: [vec3f] = []
    var texcoords: [vec2f] = []

    // subdivision data
    var subdivisions: Int = 0
    var catmullclark: Bool = true
    var smooth: Bool = true

    // displacement data
    var displacement: Float = 0
    var displacement_tex: Int = invalidid

    // shape reference
    var shape: Int = invalidid
}
