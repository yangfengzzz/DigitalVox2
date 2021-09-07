//
//  texture_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Texture data as array of float or byte pixels. Textures can be stored in
// linear or non linear color space.
struct texture_data {
    var width: Int = 0
    var height: Int = 0
    var linear: Bool = false
    var pixelsf: [vec4f] = []
    var pixelsb: [vec4b] = []
}

// Evaluates a texture
func eval_texture(_ texture: texture_data, _ uv: vec2f,
                  _ as_linear: Bool = false, _ no_interpolation: Bool = false,
                  _ clamp_to_edge: Bool = false) -> vec4f {
    fatalError()
}

func eval_texture(_ scene: scene_data, _ texture: Int, _ uv: vec2f,
                  _ as_linear: Bool = false, _ no_interpolation: Bool = false,
                  _ clamp_to_edge: Bool = false) -> vec4f {
    fatalError()
}

// pixel access
func lookup_texture(_ texture: texture_data, _ i: Int, _ j: Int, _ as_linear: Bool = false) -> vec4f {
    fatalError()
}

// conversion from image
func image_to_texture(_ image: image_data) -> texture_data {
    fatalError()
}
