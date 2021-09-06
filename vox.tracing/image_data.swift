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
    public var width: Int = 0
    public var height: Int = 0
    public var linear: Bool = false
    public var pixels: [vec4f] = []

    // pixel access
    subscript(ij: vec2i) -> vec4f {
        get {
            pixels[ij.y * width + ij.x]
        }
        set {
            pixels[ij.y * width + ij.x] = newValue
        }
    }
}

// image creation
func make_image(_ width: Int, _ height: Int, _ linear: Bool) -> image_data {
    image_data(width: width, height: height, linear: linear,
            pixels: [vec4f](repeating: vec4f(), count: width * height))
}

// equality
func ==(_ a: image_data, _ b: image_data) -> Bool {
    a.width == b.width && a.height == b.height && a.linear == b.linear &&
            a.pixels == b.pixels
}

func !=(_ a: image_data, _ b: image_data) -> Bool {
    a.width != b.width || a.height != b.height || a.linear != b.linear ||
            a.pixels != b.pixels
}

// swap
func swap(_ a: inout image_data, _ b: inout image_data) {
    swap(&a.width, &b.width)
    swap(&a.height, &b.height)
    swap(&a.linear, &b.linear)
    swap(&a.pixels, &b.pixels)
}

// pixel access
@inlinable
func get_pixel(_ image: image_data, _ i: Int, _ j: Int) -> vec4f {
    image.pixels[j * image.width + i]
}

@inlinable
func set_pixel(_ image: inout image_data, _ i: Int, _ j: Int, _ pixel: vec4f) {
    image.pixels[j * image.width + i] = pixel
}

// conversions
func convert_image(_ image: image_data, _ linear: Bool) -> image_data {
    if (image.linear == linear) {
        return image
    }
    var result = make_image(image.width, image.height, linear)
    convert_image(&result, image)
    return result
}

func convert_image(_ result: inout image_data, _ image: image_data) {
    if (image.width != result.width || image.height != result.height) {
        fatalError("image have to be the same size")
    }
    if (image.linear == result.linear) {
        result.pixels = image.pixels
    } else {
        for idx in 0..<image.pixels.count {
            result.pixels[idx] = image.linear ? rgb_to_srgb(image.pixels[idx])
                    : srgb_to_rgb(image.pixels[idx])
        }
    }
}

// Lookup pixel for evaluation
func lookup_image(_ image: image_data, _  i: Int, _  j: Int, _  as_linear: Bool) -> vec4f {
    if (as_linear && !image.linear) {
        return srgb_to_rgb(image.pixels[j * image.width + i])
    } else {
        return image.pixels[j * image.width + i]
    }
}

// Evaluates an image at a point `uv`.
func eval_image(_ image: image_data, _ uv: vec2f,
                _ as_linear: Bool = false, _ no_interpolation: Bool = false,
                _ clamp_to_edge: Bool = false) -> vec4f {
    if (image.width == 0 || image.height == 0) {
        return [0, 0, 0, 0]
    }

    // get image width/height
    let size = vec2i(image.width, image.height)

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
        return lookup_image(image, i, j, as_linear)
    } else {
        var result = lookup_image(image, i, j, as_linear) * (1 - u) * (1 - v)
        result += lookup_image(image, i, jj, as_linear) * (1 - u) * v
        result += lookup_image(image, ii, j, as_linear) * u * (1 - v)
        return result + lookup_image(image, ii, jj, as_linear) * u * v
    }
}

// Apply tone mapping returning a float or byte image.
func tonemap_image(_ image: image_data, _ exposure: Float, _ filmic: Bool = false) -> image_data {
    if (!image.linear) {
        return image
    }
    var result = make_image(image.width, image.height, false)
    for idx in 0..<image.width * image.height {
        result.pixels[idx] = tonemap(image.pixels[idx], exposure, filmic, true)
    }
    return result
}

// Apply tone mapping. If the input image is an ldr, does nothing.
func tonemap_image(_ result: inout image_data, _ image: image_data, _ exposure: Float,
                   _ filmic: Bool = false) {
    if (image.width != result.width || image.height != result.height) {
        fatalError("image should be the same size")
    }
    if (result.linear) {
        fatalError("ldr expected")
    }
    if (image.linear) {
        for idx in 0..<image.pixels.count {
            result.pixels[idx] = tonemap(image.pixels[idx], exposure, filmic)
        }
    } else {
        let scale = vec4f(pow(2, exposure), pow(2, exposure), pow(2, exposure), 1)
        for idx in 0..<image.pixels.count {
            result.pixels[idx] = image.pixels[idx] * scale
        }
    }
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
    for j in 0..<region.height {
        for i in 0..<region.width {
            image.pixels[(j + y) * image.width + (i + x)] = region.pixels[j * region.width + i]
        }
    }
}

func get_region(_ region: inout image_data, _ image: image_data,
                _ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    if (region.width != width || region.height != height) {
        region = make_image(width, height, image.linear)
    }
    for j in 0..<height {
        for i in 0..<width {
            region.pixels[j * region.width + i] = image.pixels[(j + y) * image.width + (i + x)]
        }
    }
}

// Compute the difference between two images.
func image_difference(_ image1: image_data, _ image2: image_data, _ display: Bool) -> image_data {
    // check sizes
    if (image1.width != image2.width || image1.height != image2.height) {
        fatalError("image sizes are different")
    }

    // check types
    if (image1.linear != image2.linear) {
        fatalError("image types are different")
    }

    // compute diff
    var difference = make_image(image1.width, image1.height, image1.linear)
    for idx in 0..<difference.pixels.count {
        let diff = abs(image1.pixels[idx] - image2.pixels[idx])
        difference.pixels[idx] = display ? vec4f(max(diff), max(diff), max(diff), 1) : diff
    }
    return difference
}

// Composite two images together.
func composite_image(_ image_a: image_data, _ image_b: image_data) -> image_data {
    if (image_a.width != image_b.width || image_a.height != image_b.height) {
        fatalError("image should be the same size")
    }
    if (image_a.linear != image_b.linear) {
        fatalError("image should be of the same type")
    }
    var result = make_image(image_a.width, image_a.height, image_a.linear)
    for idx in 0..<result.pixels.count {
        result.pixels[idx] = composite(image_a.pixels[idx], image_b.pixels[idx])
    }
    return result
}

// Composite two images together.
func composite_image(_ result: inout image_data, _ image_a: image_data, _ image_b: image_data) {
    if (image_a.width != image_b.width || image_a.height != image_b.height) {
        fatalError("image should be the same size")
    }
    if (image_a.linear != image_b.linear) {
        fatalError("image should be of the same type")
    }
    if (image_a.width != result.width || image_a.height != result.height) {
        fatalError("image should be the same size")
    }
    if (image_a.linear != result.linear) {
        fatalError("image should be of the same type")
    }
    for idx in 0..<result.pixels.count {
        result.pixels[idx] = composite(image_a.pixels[idx], image_b.pixels[idx])
    }
}

// Apply color grading from a linear or srgb color to an srgb color.
func colorgradeb(_ color: vec4f, _ linear: Bool, _ params: colorgrade_params) -> vec4f {
    var rgb = xyz(color)
    let alpha = color.w
    if (linear) {
        if (params.exposure != 0) {
            rgb *= exp2(params.exposure)
        }
        if (params.tint != vec3f(1, 1, 1)) {
            rgb *= params.tint
        }
        if (params.lincontrast != 0.5) {
            rgb = lincontrast(rgb, params.lincontrast, 0.18)
        }
        if (params.logcontrast != 0.5) {
            rgb = logcontrast(rgb, params.logcontrast, 0.18)
        }
        if (params.linsaturation != 0.5) {
            rgb = saturate(rgb, params.linsaturation)
        }
        if (params.filmic) {
            rgb = tonemap_filmic(rgb)
        }
        if (params.srgb) {
            rgb = rgb_to_srgb(rgb)
        }
    }
    if (params.contrast != 0.5) {
        rgb = contrast(rgb, params.contrast)
    }
    if (params.saturation != 0.5) {
        rgb = saturate(rgb, params.saturation)
    }
    if (params.shadows != 0.5 || params.midtones != 0.5 ||
            params.highlights != 0.5 || params.shadows_color != vec3f(1, 1, 1) ||
            params.midtones_color != vec3f(1, 1, 1) ||
            params.highlights_color != vec3f(1, 1, 1)) {
        var lift = params.shadows_color
        var gamma = params.midtones_color
        var gain = params.highlights_color
        lift = lift - mean(lift) + params.shadows - 0.5
        gain = gain - mean(gain) + params.highlights + 0.5
        let grey = gamma - mean(gamma) + params.midtones
        gamma = log((0.5 - lift) / (gain - lift)) / log(grey)
        // apply_image
        let lerp_value = clamp(pow(rgb, 1 / gamma), 0, 1)
        rgb = gain * lerp_value + lift * (1 - lerp_value)
    }
    return vec4f(rgb.x, rgb.y, rgb.z, alpha)
}

// Color grade an hsr or ldr image to an ldr image.
func colorgrade_image(_ image: image_data, _ params: colorgrade_params) -> image_data {
    var result = make_image(image.width, image.height, false)
    for idx in 0..<image.pixels.count {
        result.pixels[idx] = colorgrade(image.pixels[idx], image.linear, params)
    }
    return result
}

// Color grade an hsr or ldr image to an ldr image.
// Uses multithreading for speed.
func colorgrade_image(_ result: inout image_data, _ image: image_data, _ params: colorgrade_params) {
    if (image.width != result.width || image.height != result.height) {
        fatalError("image should be the same size")
    }
    if (result.linear) {
        fatalError("non linear expected")
    }
    for idx in 0..<image.pixels.count {
        result.pixels[idx] = colorgrade(image.pixels[idx], image.linear, params)
    }
}


// Color grade an hsr or ldr image to an ldr image.
// Uses multithreading for speed.
func colorgrade_image_mt(_ result: inout image_data, _ image: image_data, _ params: colorgrade_params) {
    fatalError()
}


// determine white balance colors
func compute_white_balance(_ image: image_data) -> vec4f {
    var rgb = vec3f(0, 0, 0)
    for idx in 0..<image.pixels.count {
        rgb += xyz(image.pixels[idx])
    }
    if (rgb == vec3f(0, 0, 0)) {
        return [0, 0, 0, 1]
    }
    rgb /= max(rgb)
    return [rgb.x, rgb.y, rgb.z, 1]
}
