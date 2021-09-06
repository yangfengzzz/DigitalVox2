//
//  image_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Image data as array of float or byte pixels. Images can be stored in linear
// or non linear color space.
public struct image_data {
    // image data
    var width: Int = 0
    var height: Int = 0
    var linear: Bool = false
    var pixels: [vec4f] = []

    // pixel access
    subscript(i: vec2i) -> vec4f {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}

// image creation
func make_image(_ width: Int, _ height: Int, _ linear: Bool) -> image_data {
    fatalError()
}

// equality
func ==(_ a: image_data, _ b: image_data) -> Bool {
    fatalError()
}

func !=(_ a: image_data, _ b: image_data) -> Bool {
    fatalError()
}

// swap
func swap(_ a: inout image_data, _ b: inout image_data) {
    fatalError()
}

// pixel access
@inlinable
func get_pixel(_ image: image_data, _ i: Int, _ j: Int) -> vec4f {
    fatalError()
}

@inlinable
func set_pixel(_ image: inout image_data, _ i: Int, _ j: Int, _ pixel: vec4f) {
    fatalError()
}

// conversions
func convert_image(_ image: image_data, _ linear: Bool) -> image_data {
    fatalError()
}

func convert_image(_ result: inout image_data, _ image: image_data) {
    fatalError()
}


// Evaluates an image at a point `uv`.
func eval_image(_ image: image_data, _ uv: vec2f,
                _ as_linear: Bool = false, _ no_interpolation: Bool = false,
                _ clamp_to_edge: Bool = false) -> vec4f {
    fatalError()
}

// Apply tone mapping returning a float or byte image.
func tonemap_image(_ image: image_data, _ exposure: Float, _ filmic: Bool = false) -> image_data {
    fatalError()
}

// Apply tone mapping. If the input image is an ldr, does nothing.
func tonemap_image(_ ldr: inout image_data, _ image: image_data, _ exposure: Float,
                   _ filmic: Bool = false) {
    fatalError()
}

// Apply tone mapping using multithreading for speed.
func tonemap_image_mt(_ ldr: inout image_data, _ image: image_data, _ exposure: Float,
                      _ filmic: Bool = false) {
    fatalError()
}


// Resize an image.
func resize_image(_ image: image_data, _ width: Int, _ height: Int) -> image_data {
    fatalError()
}

// set/get region
func set_region(_ image: inout image_data, _ region: image_data, _ x: Int, _ y: Int) {
    fatalError()
}

func get_region(_ region: inout image_data, _ image: image_data,
                _ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    fatalError()
}


// Compute the difference between two images.
func image_difference(_ image_a: image_data, _ image_b: image_data, _ display_diff: Bool) -> image_data {
    fatalError()
}

// Composite two images together.
func composite_image(_ image_a: image_data, _ image_b: image_data) -> image_data {
    fatalError()
}

// Composite two images together.
func composite_image(_ result: inout image_data, _ image_a: image_data, _ image_b: image_data) {
    fatalError()
}


// Composite two images together.
func composite_image(_ result: inout image_data, _ images: [image_data]) {
    fatalError()
}


// Color grade an hsr or ldr image to an ldr image.
func colorgrade_image(_ image: image_data, _ params: colorgrade_params) -> image_data {
    fatalError()
}

// Color grade an hsr or ldr image to an ldr image.
// Uses multithreading for speed.
func colorgrade_image(_ result: inout image_data, _ image: image_data, _ params: colorgrade_params) {
    fatalError()
}


// Color grade an hsr or ldr image to an ldr image.
// Uses multithreading for speed.
func colorgrade_image_mt(_ result: inout image_data, _ image: image_data, _ params: colorgrade_params) {
    fatalError()
}


// determine white balance colors
func compute_white_balance(_ image: image_data) -> vec4f {
    fatalError()
}
