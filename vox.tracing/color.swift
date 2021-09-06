//
//  color.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// -----------------------------------------------------------------------------
// COLOR OPERATIONS
// -----------------------------------------------------------------------------
// Conversion between flots and bytes
@inlinable
func float_to_byte(a: vec4f) -> vec4b {
    fatalError()
}

@inlinable
func byte_to_float(a: vec4b) -> vec4f {
    fatalError()
}

@inlinable
func float_to_byte(a: Float) -> UInt8 {
    fatalError()
}

@inlinable
func byte_to_float(a: UInt8) -> Float {
    fatalError()
}

// Luminance
@inlinable
func luminance(a: vec3f) -> Float {
    fatalError()
}

// sRGB non-linear curve
@inlinable
func srgb_to_rgb(srgb: Float) -> Float {
    fatalError()
}

@inlinable
func rgb_to_srgb(rgb: Float) -> Float {
    fatalError()
}

@inlinable
func srgb_to_rgb(srgb: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func srgb_to_rgb(srgb: vec4f) -> vec4f {
    fatalError()
}

@inlinable
func rgb_to_srgb(rgb: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func rgb_to_srgb(rgb: vec4f) -> vec4f {
    fatalError()
}

// Conversion between number of channels.
@inlinable
func rgb_to_rgba(rgb: vec3f) -> vec4f {
    fatalError()
}

@inlinable
func rgba_to_rgb(rgba: vec4f) -> vec3f {
    fatalError()
}

// Apply contrast. Grey should be 0.18 for linear and 0.5 for gamma.
@inlinable
func lincontrast(rgb: vec3f, contrast: Float, grey: Float) -> vec3f {
    fatalError()
}

// Apply contrast in log2. Grey should be 0.18 for linear and 0.5 for gamma.
@inlinable
func logcontrast(rgb: vec3f, logcontrast: Float, grey: Float) -> vec3f {
    fatalError()
}

// Apply an s-shaped contrast.
@inlinable
func contrast(rgb: vec3f, contrast: Float) -> vec3f {
    fatalError()
}

// Apply saturation.
@inlinable
func saturate(rgb: vec3f, saturation: Float,
              weights: vec3f = vec3f(0.333333, 0.333333, 0.333333)) -> vec3f {
    fatalError()
}

// Apply tone mapping
@inlinable
func tonemap(hdr: vec3f, exposure: Float, filmic: Bool = false, srgb: Bool = true) -> vec3f {
    fatalError()
}

@inlinable
func tonemap(hdr: vec4f, exposure: Float, filmic: Bool = false, srgb: Bool = true) -> vec4f {
    fatalError()
}

// Composite colors
@inlinable
func composite(a: vec4f, b: vec4f) -> vec4f {
    fatalError()
}

// Convert between CIE XYZ and RGB
@inlinable
func rgb_to_xyz(rgb: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func xyz_to_rgb(xyz: vec3f) -> vec3f {
    fatalError()
}

// Convert between CIE XYZ and xyY
@inlinable
func xyz_to_xyY(xyz: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func xyY_to_xyz(xyY: vec3f) -> vec3f {
    fatalError()
}

// Converts between HSV and RGB color spaces.
@inlinable
func hsv_to_rgb(hsv: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func rgb_to_hsv(rgb: vec3f) -> vec3f {
    fatalError()
}

// Approximate color of blackbody radiation from wavelength in nm.
@inlinable
func blackbody_to_rgb(temperature: Float) -> vec3f {
    fatalError()
}

// Colormap type
public enum colormap_type {
    case viridis
    case plasma
    case magma
    case inferno
}

// Colormaps from [0,1] to color
@inlinable
func colormap(t: Float, type: colormap_type = .viridis) -> vec3f {
    fatalError()
}

// -----------------------------------------------------------------------------
//MARK:- COLOR GRADING
// -----------------------------------------------------------------------------
// minimal color grading
public struct colorgrade_params {
    var exposure: Float = 0
    var tint: vec3f = [1, 1, 1]
    var lincontrast: Float = 0.5
    var logcontrast: Float = 0.5
    var linsaturation: Float = 0.5
    var filmic: Bool = false
    var srgb: Bool = true
    var contrast: Float = 0.5
    var saturation: Float = 0.5
    var shadows: Float = 0.5
    var midtones: Float = 0.5
    var highlights: Float = 0.5
    var shadows_color: vec3f = [1, 1, 1]
    var midtones_color: vec3f = [1, 1, 1]
    var highlights_color: vec3f = [1, 1, 1]
}

// Apply color grading from a linear or srgb color to an srgb color.
@inlinable
func colorgrade(_ color: vec3f, _ linear: Bool, _ params: colorgrade_params) -> vec3f {
    fatalError()
}

@inlinable
func colorgrade(_ color: vec4f, _ linear: Bool, _ params: colorgrade_params) -> vec4f {
    fatalError()
}

// -----------------------------------------------------------------------------
//MARK:- COLOR SPACE CONVERSION
// -----------------------------------------------------------------------------
// RGB color spaces
public enum color_space {
    case rgb         // default linear space (srgb linear)
    case srgb        // srgb color space (non-linear)
    case adobe       // Adobe rgb color space (non-linear)
    case prophoto    // ProPhoto Kodak rgb color space (non-linear)
    case rec709      // hdtv color space (non-linear)
    case rec2020     // uhtv color space (non-linear)
    case rec2100pq   // hdr color space with perceptual quantizer (non-linear)
    case rec2100hlg  // hdr color space with hybrid log gamma (non-linear)
    case aces2065    // ACES storage format (linear)
    case acescg      // ACES CG computation (linear)
    case acescc      // ACES color correction (non-linear)
    case acescct     // ACES color correction 2 (non-linear)
    case p3dci       // P3 DCI (non-linear)
    case p3d60       // P3 variation for D60 (non-linear)
    case p3d65       // P3 variation for D65 (non-linear)
    case p3display   // Apple display P3
}

// Conversion between rgb color spaces
@inlinable
func color_to_xyz(col: vec3f, from: color_space) -> vec3f {
    fatalError()
}

@inlinable
func xyz_to_color(xyz: vec3f, to: color_space) -> vec3f {
    fatalError()
}

// Conversion between rgb color spaces
@inlinable
func convert_color(col: vec3f, from: color_space, to: color_space) -> vec3f {
    fatalError()
}
