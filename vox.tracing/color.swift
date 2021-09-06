//
//  color.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// -----------------------------------------------------------------------------
//MARK:- COLOR OPERATIONS
// -----------------------------------------------------------------------------
// Conversion between flots and bytes
@inlinable
func float_to_byte(_ a: vec4f) -> vec4b {
    [UInt8(simd_clamp(a.x * 256, 0, 255)),
     UInt8(simd_clamp(a.y * 256, 0, 255)),
     UInt8(simd_clamp(a.z * 256, 0, 255)),
     UInt8(simd_clamp(a.w * 256, 0, 255))]
}

@inlinable
func byte_to_float(_ a: vec4b) -> vec4f {
    [Float(a.x) / 255.0, Float(a.y) / 255.0, Float(a.z) / 255.0, Float(a.w) / 255.0]
}

@inlinable
func float_to_byte(_ a: Float) -> UInt8 {
    UInt8(simd_clamp(a * 256, 0, 255))
}

@inlinable
func byte_to_float(_ a: UInt8) -> Float {
    Float(a) / 255.0
}

// Luminance
@inlinable
func luminance(_ a: vec3f) -> Float {
    0.2126 * a.x + 0.7152 * a.y + 0.0722 * a.z
}

// sRGB non-linear curve
@inlinable
func srgb_to_rgb(_ srgb: Float) -> Float {
    (srgb <= 0.04045) ? srgb / 12.92 : pow((srgb + 0.055) / (1.0 + 0.055), 2.4)
}

@inlinable
func rgb_to_srgb(_ rgb: Float) -> Float {
    (rgb <= 0.0031308) ? 12.92 * rgb : (1 + 0.055) * pow(rgb, 1 / 2.4) - 0.055
}

@inlinable
func srgb_to_rgb(_ srgb: vec3f) -> vec3f {
    [srgb_to_rgb(srgb.x), srgb_to_rgb(srgb.y), srgb_to_rgb(srgb.z)]
}

@inlinable
func srgb_to_rgb(_ srgb: vec4f) -> vec4f {
    [srgb_to_rgb(srgb.x), srgb_to_rgb(srgb.y), srgb_to_rgb(srgb.z), srgb.w]
}

@inlinable
func rgb_to_srgb(_ rgb: vec3f) -> vec3f {
    [rgb_to_srgb(rgb.x), rgb_to_srgb(rgb.y), rgb_to_srgb(rgb.z)]
}

@inlinable
func rgb_to_srgb(_ rgb: vec4f) -> vec4f {
    [rgb_to_srgb(rgb.x), rgb_to_srgb(rgb.y), rgb_to_srgb(rgb.z), rgb.w]
}

// Conversion between number of channels.
@inlinable
func rgb_to_rgba(_ rgb: vec3f) -> vec4f {
    [rgb.x, rgb.y, rgb.z, 1]
}

@inlinable
func rgba_to_rgb(_ rgba: vec4f) -> vec3f {
    xyz(rgba)
}

// Apply contrast. Grey should be 0.18 for linear and 0.5 for gamma.
@inlinable
func lincontrast(_ rgb: vec3f, _ contrast: Float, _ grey: Float) -> vec3f {
    max([0, 0, 0], grey + (rgb - grey) * (contrast * 2))
}

// Apply contrast in log2. Grey should be 0.18 for linear and 0.5 for gamma.
@inlinable
func logcontrast(_ rgb: vec3f, _ logcontrast: Float, _ grey: Float) -> vec3f {
    let epsilon: Float = 0.0001
    let log_grey = log2(grey)
    let log_ldr = log2(rgb + epsilon)
    let adjusted = log_grey + (log_ldr - log_grey) * (logcontrast * 2)
    return max([0, 0, 0], exp2(adjusted) - epsilon)
}

// Apply an s-shaped contrast.
@inlinable
func contrast(_ rgb: vec3f, _ contrast: Float) -> vec3f {
    gain(rgb, 1 - contrast)
}

// Apply saturation.
@inlinable
func saturate(_ rgb: vec3f, _  saturation: Float,
              _ weights: vec3f = vec3f(0.333333, 0.333333, 0.333333)) -> vec3f {
    let grey = dot(weights, rgb)
    return max([0, 0, 0], grey + (rgb - grey) * (saturation * 2))
}

// Filmic tonemapping
@inlinable
func tonemap_filmic(_ hdr_: vec3f, _ accurate_fit: Bool = false) -> vec3f {
    if (!accurate_fit) {
        // https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
        let hdr = hdr_ * 0.6  // brings it back to ACES range
        let ldr = hdr * hdr * 2.51 + hdr * 0.03
        let div = hdr * hdr * 2.43 + hdr * 0.59
        return max([0, 0, 0], ldr / (div + 0.14))
    } else {
        // https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl
        // sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
        let ACESInputMat = transpose(mat3f(
                [0.59719, 0.35458, 0.04823],
                [0.07600, 0.90834, 0.01566],
                [0.02840, 0.13383, 0.83777]
        ))
        // ODT_SAT => XYZ => D60_2_D65 => sRGB
        let ACESOutputMat = transpose(mat3f(
                [1.60475, -0.53108, -0.07367],
                [-0.10208, 1.10813, -0.00605],
                [-0.00327, -0.07276, 1.07602]
        ))
        // RRT => ODT
        let RRTAndODTFit = { (v: vec3f) -> vec3f in
            let result = v * v + v * 0.0245786 - 0.000090537
            let div = v * v * 0.983729 + v * 0.4329510
            return result / (div + 0.238081)
        }

        let ldr = ACESOutputMat * RRTAndODTFit(ACESInputMat * hdr_)
        return max([0, 0, 0], ldr)
    }
}

// Apply tone mapping
@inlinable
func tonemap(_ hdr: vec3f, _ exposure: Float, _ filmic: Bool = false, _ srgb: Bool = true) -> vec3f {
    var rgb = hdr
    if (exposure != 0) {
        rgb *= exp2(exposure)
    }
    if (filmic) {
        rgb = tonemap_filmic(rgb)
    }
    if (srgb) {
        rgb = rgb_to_srgb(rgb)
    }
    return rgb
}

@inlinable
func tonemap(_ hdr: vec4f, _ exposure: Float, _ filmic: Bool = false, _ srgb: Bool = true) -> vec4f {
    let ldr = tonemap(xyz(hdr), exposure, filmic, srgb)
    return [ldr.x, ldr.y, ldr.z, hdr.w]
}

// Composite colors
@inlinable
func composite(_ a: vec4f, _ b: vec4f) -> vec4f {
    if (a.w == 0 && b.w == 0) {
        return [0, 0, 0, 0]
    }
    let cc = xyz(a) * a.w + xyz(b) * b.w * (1 - a.w)
    let ca = a.w + b.w * (1 - a.w)
    return [cc.x / ca, cc.y / ca, cc.z / ca, ca]
}

// Convert between CIE XYZ and RGB
@inlinable
func rgb_to_xyz(_ rgb: vec3f) -> vec3f {
    // https://en.wikipedia.org/wiki/SRGB
    let mat = mat3f(
            [0.4124, 0.2126, 0.0193],
            [0.3576, 0.7152, 0.1192],
            [0.1805, 0.0722, 0.9504]
    )
    return mat * rgb
}

@inlinable
func xyz_to_rgb(_ xyz: vec3f) -> vec3f {
    // https://en.wikipedia.org/wiki/SRGB
    let mat = mat3f(
            [3.2406, -0.9689, 0.0557],
            [-1.5372, 1.8758, -0.2040],
            [-0.4986, 0.0415, 1.0570]
    )
    return mat * xyz
}

// Convert between CIE XYZ and xyY
@inlinable
func xyz_to_xyY(_ xyz: vec3f) -> vec3f {
    if (xyz == vec3f(0, 0, 0)) {
        return [0, 0, 0]
    }
    return [xyz.x / (xyz.x + xyz.y + xyz.z), xyz.y / (xyz.x + xyz.y + xyz.z), xyz.y]
}

@inlinable
func xyY_to_xyz(_ xyY: vec3f) -> vec3f {
    if (xyY.y == 0) {
        return [0, 0, 0]
    }
    return [xyY.x * xyY.z / xyY.y, xyY.z, (1 - xyY.x - xyY.y) * xyY.z / xyY.y]
}

// Converts between HSV and RGB color spaces.
@inlinable
func hsv_to_rgb(_ hsv: vec3f) -> vec3f {
    // from Imgui.cpp
    var h = hsv.x, s = hsv.y, v = hsv.z
    if (hsv.y == 0) {
        return [v, v, v]
    }

    h = fmod(h, 1.0) / (60.0 / 360.0)
    let i = Int(h)
    let f = h - Float(i)
    let p = v * (1 - s)
    let q = v * (1 - s * f)
    let t = v * (1 - s * (1 - f))

    switch (i) {
    case 0: return [v, t, p]
    case 1: return [q, v, p]
    case 2: return [p, v, t]
    case 3: return [p, q, v]
    case 4: return [t, p, v]
    case 5: return [v, p, q]
    default: return [v, p, q]
    }
}

@inlinable
func rgb_to_hsv(_ rgb: vec3f) -> vec3f {
    // from Imgui.cpp
    var r = rgb.x, g = rgb.y, b = rgb.z
    var K: Float = 0.0
    if (g < b) {
        swap(&g, &b)
        K = -1
    }
    if (r < g) {
        swap(&r, &g)
        K = -2 / 6.0 - K
    }

    let chroma = r - (g < b ? g : b)
    return [abs(K + (g - b) / (6 * chroma + 1e-20)), chroma / (r + 1e-20), r]
}

// Approximate color of blackbody radiation from wavelength in nm.
@inlinable
func blackbody_to_rgb(_ temperature: Float) -> vec3f {
    // clamp to valid range
    let t = simd_clamp(temperature, 1667.0, 25000.0) / 1000.0
    // compute x
    var x: Float = 0.0
    if (temperature < 4000.0) {
        x = -0.2661239 * 1 / (t * t * t) - 0.2343589 * 1 / (t * t) +
                0.8776956 * (1 / t) + 0.179910
    } else {
        x = -3.0258469 * 1 / (t * t * t) + 2.1070379 * 1 / (t * t) +
                0.2226347 * (1 / t) + 0.240390
    }
    // compute y
    var y: Float = 0.0
    if (temperature < 2222.0) {
        y = -1.1063814 * (x * x * x) - 1.34811020 * (x * x) + 2.18555832 * x -
                0.20219683
    } else if (temperature < 4000.0) {
        y = -0.9549476 * (x * x * x) - 1.37418593 * (x * x) + 2.09137015 * x -
                0.16748867
    } else {
        y = +3.0817580 * (x * x * x) - 5.87338670 * (x * x) + 3.75112997 * x -
                0.37001483
    }
    return xyz_to_rgb(xyY_to_xyz([x, y, 1]))
}

// Colormap type
public enum colormap_type {
    case viridis
    case plasma
    case magma
    case inferno
}

@inlinable
func colormap_viridis(_ t: Float) -> vec3f {
    // https://www.shadertoy.com/view/WlfXRN
    let c0 = vec3f(
            0.2777273272234177, 0.005407344544966578, 0.3340998053353061)
    let c1 = vec3f(
            0.1050930431085774, 1.404613529898575, 1.384590162594685)
    let c2 = vec3f(
            -0.3308618287255563, 0.214847559468213, 0.09509516302823659)
    let c3 = vec3f(
            -4.634230498983486, -5.799100973351585, -19.33244095627987)
    let c4 = vec3f(
            6.228269936347081, 14.17993336680509, 56.69055260068105)
    let c5 = vec3f(
            4.776384997670288, -13.74514537774601, -65.35303263337234)
    let c6 = vec3f(
            -5.435455855934631, 4.645852612178535, 26.3124352495832)
    return c0 + t * (c1 + t * (c2 + t * (c3 + t * (c4 + t * (c5 + t * c6)))))
}

@inlinable
func colormap_plasma(_ t: Float) -> vec3f {
    // https://www.shadertoy.com/view/WlfXRN
    let c0 = vec3f(
            0.05873234392399702, 0.02333670892565664, 0.5433401826748754)
    let c1 = vec3f(
            2.176514634195958, 0.2383834171260182, 0.7539604599784036)
    let c2 = vec3f(
            -2.689460476458034, -7.455851135738909, 3.110799939717086)
    let c3 = vec3f(
            6.130348345893603, 42.3461881477227, -28.51885465332158)
    let c4 = vec3f(
            -11.10743619062271, -82.66631109428045, 60.13984767418263)
    let c5 = vec3f(
            10.02306557647065, 71.41361770095349, -54.07218655560067)
    let c6 = vec3f(
            -3.658713842777788, -22.93153465461149, 18.19190778539828)
    return c0 + t * (c1 + t * (c2 + t * (c3 + t * (c4 + t * (c5 + t * c6)))))
}

@inlinable
func colormap_magma(_ t: Float) -> vec3f {
    // https://www.shadertoy.com/view/WlfXRN
    let c0 = vec3f(
            -0.002136485053939582, -0.000749655052795221, -0.005386127855323933)
    let c1 = vec3f(
            0.2516605407371642, 0.6775232436837668, 2.494026599312351)
    let c2 = vec3f(
            8.353717279216625, -3.577719514958484, 0.3144679030132573)
    let c3 = vec3f(
            -27.66873308576866, 14.26473078096533, -13.64921318813922)
    let c4 = vec3f(
            52.17613981234068, -27.94360607168351, 12.94416944238394)
    let c5 = vec3f(
            -50.76852536473588, 29.04658282127291, 4.23415299384598)
    let c6 = vec3f(
            18.65570506591883, -11.48977351997711, -5.601961508734096)
    return c0 + t * (c1 + t * (c2 + t * (c3 + t * (c4 + t * (c5 + t * c6)))))
}

@inlinable
func colormap_inferno(_ t: Float) -> vec3f {
    // https://www.shadertoy.com/view/WlfXRN
    c0 = vec3f(
            0.0002189403691192265, 0.001651004631001012, -0.01948089843709184)
    let c1 = vec3f(
            0.1065134194856116, 0.5639564367884091, 3.932712388889277)
    let c2 = vec3f(
            11.60249308247187, -3.972853965665698, -15.9423941062914)
    let c3 = vec3f(
            -41.70399613139459, 17.43639888205313, 44.35414519872813)
    let c4 = vec3f(
            77.162935699427, -33.40235894210092, -81.80730925738993)
    let c5 = vec3f(
            -71.31942824499214, 32.62606426397723, 73.20951985803202)
    let c6 = vec3f(
            25.13112622477341, -12.24266895238567, -23.07032500287172)
    return c0 + t * (c1 + t * (c2 + t * (c3 + t * (c4 + t * (c5 + t * c6)))))
}


// Colormaps from [0,1] to color
@inlinable
func colormap(_ t: Float, _ type: colormap_type = .viridis) -> vec3f {
    let t = simd_clamp(t, 0.0, 1.0)
    switch (type) {
    case .viridis: return colormap_viridis(t)
    case .magma: return colormap_magma(t)
    case .inferno: return colormap_inferno(t)
    case .plasma: return colormap_plasma(t)
    }
    return [0, 0, 0]
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
func color_to_xyz(_ col: vec3f, _ from: color_space) -> vec3f {
    fatalError()
}

@inlinable
func xyz_to_color(_ xyz: vec3f, _ to: color_space) -> vec3f {
    fatalError()
}

// Conversion between rgb color spaces
@inlinable
func convert_color(_ col: vec3f, _ from: color_space, _ to: color_space) -> vec3f {
    fatalError()
}
