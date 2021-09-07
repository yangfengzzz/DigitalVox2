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
    fatalError()
}

func eval_environment(_ scene: scene_data, _ direction: vec3f) -> vec3f {
    fatalError()
}
