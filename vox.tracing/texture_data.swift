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
    if (texture.width == 0 || texture.height == 0) {
        return [0, 0, 0, 0]
    }

    // get texture width/height
    let size = vec2i(texture.width, texture.height)

    // get coordinates normalized for tiling
    var s: Float = 0.0, t: Float = 0.0
    if (clamp_to_edge) {
        s = simd_clamp(uv.x, 0.0, 1.0) * Float(size.x)
        t = simd_clamp(uv.y, 0.0, 1.0) * Float(size.y)
    } else {
        s = fmod(uv.x, 1.0) * Float(size.x)
        if (s < 0) {
            s += Float(size.x)
        }
        t = fmod(uv.y, 1.0) * Float(size.y)
        if (t < 0) {
            t += Float(size.y)
        }
    }

    // get image coordinates and residuals
    let i = Int(simd_clamp(s, 0, Float(size.x) - 1)), j = Int(simd_clamp(t, 0, Float(size.y) - 1))
    let ii = (i + 1) % size.x, jj = (j + 1) % size.y
    let u = s - Float(i), v = t - Float(j)

    // handle interpolation
    if (no_interpolation) {
        return lookup_texture(texture, i, j, as_linear)
    } else {
        var result = lookup_texture(texture, i, j, as_linear) * (1 - u) * (1 - v)
        result += lookup_texture(texture, i, jj, as_linear) * (1 - u) * v
        result += lookup_texture(texture, ii, j, as_linear) * u * (1 - v)
        return result + lookup_texture(texture, ii, jj, as_linear) * u * v
    }
}

func eval_texture(_ scene: scene_data, _ texture: Int, _ uv: vec2f,
                  _ ldr_as_linear: Bool = false, _ no_interpolation: Bool = false,
                  _ clamp_to_edge: Bool = false) -> vec4f {
    if (texture == invalidid) {
        return [1, 1, 1, 1]
    }
    return eval_texture(scene.textures[texture], uv, ldr_as_linear, no_interpolation)
}

// pixel access
func lookup_texture(_ texture: texture_data, _ i: Int, _ j: Int, _ as_linear: Bool = false) -> vec4f {
    var color = vec4f(0, 0, 0, 0)
    if (!texture.pixelsf.isEmpty) {
        color = texture.pixelsf[j * texture.width + i]
    } else {
        color = byte_to_float(texture.pixelsb[j * texture.width + i])
    }
    if (as_linear && !texture.linear) {
        return srgb_to_rgb(color)
    } else {
        return color
    }
}

// conversion from image
func image_to_texture(_ image: image_data) -> texture_data {
    var texture = texture_data(width: image.width, height: image.height, linear: image.linear, pixelsf: [], pixelsb: [])
    if (image.linear) {
        texture.pixelsf = image.pixels
    } else {
        texture.pixelsb = .init(repeating: vec4b(), count: image.pixels.count)
        float_to_byte(&texture.pixelsb, image.pixels)
    }
    return texture
}
