//
//  instance_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Instance.
struct instance_data {
    // instance data
    var frame: frame3f = identity3x4f
    var shape: Int = invalidid
    var material: Int = invalidid
}

// Evaluate instance properties
func eval_position(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> vec3f {
    fatalError()
}

func eval_element_normal(_ scene: scene_data, _ instance: instance_data,
                         _ element: Int) -> vec3f {
    fatalError()
}

func eval_normal(_ scene: scene_data, _ instance: instance_data,
                 _ element: Int, _ uv: vec2f) -> vec3f {
    fatalError()
}

func eval_texcoord(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> vec2f {
    fatalError()
}

func eval_element_tangents(_ scene: scene_data, _ instance: instance_data,
                           _ element: Int) -> (vec3f, vec3f) {
    fatalError()
}

func eval_normalmap(_ scene: scene_data, _ instance: instance_data,
                    _ element: Int, _ uv: vec2f) -> vec3f {
    fatalError()
}

func eval_shading_position(_ scene: scene_data, _ instance: instance_data,
                           _ element: Int, _ uv: vec2f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

func eval_shading_normal(_ scene: scene_data, _ instance: instance_data,
                         _ element: Int, _ uv: vec2f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

func eval_color(_ scene: scene_data, _ instance: instance_data,
                _ element: Int, _ uv: vec2f) -> vec4f {
    fatalError()
}

// Eval material to obtain emission, brdf and opacity.
func eval_material(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> material_point {
    fatalError()
}

// check if a material has a volume
func is_volumetric(_ scene: scene_data, _ instance: instance_data) -> Bool {
    fatalError()
}
