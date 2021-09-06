//
//  image.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation


// -----------------------------------------------------------------------------
//MARK:- EXAMPLE IMAGES
// -----------------------------------------------------------------------------
// Comvert a bump map to a normal map.
func bump_to_normal(_ normalmap: inout image_data, _ bumpmap: image_data, _ scale: Float) {
    let width = bumpmap.width, height = bumpmap.height
    if (normalmap.width != bumpmap.width || normalmap.height != bumpmap.height) {
        normalmap = make_image(width, height, bumpmap.linear)
    }
    let dx = 1.0 / Float(width), dy = 1.0 / Float(height)
    for j in 0..<height {
        for i in 0..<width {
            let i1 = (i + 1) % width, j1 = (j + 1) % height
            let p00 = bumpmap.pixels[j * bumpmap.width + i],
                    p10 = bumpmap.pixels[j * bumpmap.width + i1],
                    p01 = bumpmap.pixels[j1 * bumpmap.width + i]
            let g00 = (p00.x + p00.y + p00.z) / 3
            let g01 = (p01.x + p01.y + p01.z) / 3
            let g10 = (p10.x + p10.y + p10.z) / 3
            var normal = vec3f(scale * (g00 - g10) / dx, scale * (g00 - g01) / dy, 1.0)
            normal.y = -normal.y  // make green pointing up, even if y axis
            // points down
            normal = normalize(normal) * 0.5 + vec3f(0.5, 0.5, 0.5)
            set_pixel(&normalmap, i, j, [normal.x, normal.y, normal.z, 1])
        }
    }
}

// Convert a bump map to a normal map. All linear color spaces.
func bump_to_normal(_ bumpmap: image_data, _ scale: Float = 1) -> image_data {
    var normalmap = make_image(bumpmap.width, bumpmap.height, bumpmap.linear)
    bump_to_normal(&normalmap, bumpmap, scale)
    return normalmap
}

// Convert a bump map to a normal map. All linear color spaces.
func bump_to_normal(_ normal: inout [vec4f], _ bump: [vec4f], _  width: Int,
                    _  height: Int, _  scale: Float = 1) {
    fatalError()
}

// Add a border to an image
func add_border(_ img: image_data, _ width: Float, _ color: vec4f = [0, 0, 0, 1]) -> image_data {
    fatalError()
}

// Add a border to an image
func add_border(_ pixels: inout [vec4f], _ source: [vec4f], _  width: Int,
                _ height: Int, _  thickness: Float, _ color: vec4f = [0, 0, 0, 1]) {
    fatalError()
}

func make_proc_image(_ width: Int, _ height: Int, _ linear: Bool, _ shader: (_ uv: vec2f) -> vec4f) -> image_data {
    var image = make_image(width, height, linear)
    let scale = 1.0 / Float(max(width, height))
    for j in 0..<height {
        for i in 0..<width {
            let uv = vec2f(Float(i) * scale, Float(j) * scale)
            image.pixels[j * width + i] = shader(uv)
        }
    }
    return image
}

// -----------------------------------------------------------------------------
//MARK:- IMAGE UTILITIES
// -----------------------------------------------------------------------------
// Conversion from/to floats.
func byte_to_float(_ fl: inout [vec4f], _ bt: [vec4b]) {
    fatalError()
}

func float_to_byte(_ bt: inout [vec4b], _ fl: [vec4f]) {
    fatalError()
}

// Conversion between linear and gamma-encoded images.
func srgb_to_rgb(_ rgb: inout [vec4f], _ srgb: [vec4f]) {
    fatalError()
}

func rgb_to_srgb(_ srgb: inout [vec4f], _ rgb: [vec4f]) {
    fatalError()
}

func srgb_to_rgb(_ rgb: inout [vec4f], _ srgb: [vec4b]) {
    fatalError()
}

func rgb_to_srgb(_ srgb: inout [vec4b], _ rgb: [vec4f]) {
    fatalError()
}

// Apply tone mapping
func tonemap_image(_ ldr: inout [vec4f], _ hdr: [vec4f], _ exposure: Float,
                   _ filmic: Bool = false, _ srgb: Bool = true) {
    fatalError()
}

func tonemap_image(_ ldr: inout [vec4b], _ hdr: [vec4f], _  exposure: Float,
                   _ filmic: Bool = false, _ srgb: Bool = true) {
    fatalError()
}

// Apply tone mapping using multithreading for speed
func tonemap_image_mt(_ ldr: inout [vec4f], _ hdr: [vec4f],
                      _ exposure: Float, _ filmic: Bool = false, _ srgb: Bool = true) {
    fatalError()
}

func tonemap_image_mt(_ ldr: inout [vec4b], _ hdr: [vec4f],
                      _ exposure: Float, _ filmic: Bool = false, _ srgb: Bool = true) {
    fatalError()
}

// Color grade a linear or srgb image to an srgb image.
// Uses multithreading for speed.
func colorgrade_image_mt(_ corrected: inout [vec4f], _ img: [vec4f],
                         _ linear: Bool, _ params: colorgrade_params) {
    fatalError()
}

func colorgrade_image_mt(_ corrected: inout [vec4b], _ img: [vec4f],
                         _ linear: Bool, _ params: colorgrade_params) {
    fatalError()
}

// determine white balance colors
func compute_white_balance(_ img: [vec4f]) -> vec3f {
    fatalError()
}

// Resize an image.
func resize_image(_ res: inout [vec4f], _ img: [vec4f], _ width: Int,
                  _ height: Int, _  res_width: Int, _ res_height: Int) {
    fatalError()
}

func resize_image(_ res: inout [vec4b], _  img: [vec4b], _ width: Int,
                  _ height: Int, _ res_width: Int, _ res_height: Int) {
    fatalError()
}

// Compute the difference between two images
func image_difference(_ diff: inout [vec4f], _ a: [vec4f], _ b: [vec4f], _ display_diff: Bool) {
    fatalError()
}
