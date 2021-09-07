//
//  environment_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Environment map.
struct environment_data {
    // environment data
    var frame: frame3f = identity3x4f
    var emission: vec3f = [0, 0, 0]
    var emission_tex: Int = invalidid
}

func eval_environment(_ scene: scene_data, _ environment: environment_data, _ direction: vec3f) -> vec3f {
    let wl = transform_direction(inverse(environment.frame), direction)
    var texcoord = vec2f(atan2(wl.z, wl.x) / (2 * Float.pi), acos(simd_clamp(wl.y, -1.0, 1.0)) / Float.pi)
    if (texcoord.x < 0) {
        texcoord.x += 1
    }
    return environment.emission * xyz(eval_texture(scene, environment.emission_tex, texcoord))
}

func eval_environment(_ scene: scene_data, _ direction: vec3f) -> vec3f {
    var emission = vec3f(0, 0, 0)
    for environment in scene.environments {
        emission += eval_environment(scene, environment, direction)
    }
    return emission
}
