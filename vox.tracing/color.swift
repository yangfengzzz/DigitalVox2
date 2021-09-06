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

    var result = c5 + t * c6
    result = c4 + t * result
    result = c3 + t * result
    result = c2 + t * result
    result = c1 + t * result
    result = c0 + t * result
    return result
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

    var result = c5 + t * c6
    result = c4 + t * result
    result = c3 + t * result
    result = c2 + t * result
    result = c1 + t * result
    result = c0 + t * result
    return result
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

    var result = c5 + t * c6
    result = c4 + t * result
    result = c3 + t * result
    result = c2 + t * result
    result = c1 + t * result
    result = c0 + t * result
    return result
}

@inlinable
func colormap_inferno(_ t: Float) -> vec3f {
    // https://www.shadertoy.com/view/WlfXRN
    let c0 = vec3f(
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

    var result = c5 + t * c6
    result = c4 + t * result
    result = c3 + t * result
    result = c2 + t * result
    result = c1 + t * result
    result = c0 + t * result
    return result
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
}

// -----------------------------------------------------------------------------
//MARK:- COLOR GRADING
// -----------------------------------------------------------------------------
// minimal color grading
public struct colorgrade_params {
    public var exposure: Float = 0
    public var tint: vec3f = [1, 1, 1]
    public var lincontrast: Float = 0.5
    public var logcontrast: Float = 0.5
    public var linsaturation: Float = 0.5
    public var filmic: Bool = false
    public var srgb: Bool = true
    public var contrast: Float = 0.5
    public var saturation: Float = 0.5
    public var shadows: Float = 0.5
    public var midtones: Float = 0.5
    public var highlights: Float = 0.5
    public var shadows_color: vec3f = [1, 1, 1]
    public var midtones_color: vec3f = [1, 1, 1]
    public var highlights_color: vec3f = [1, 1, 1]
}

// Apply color grading from a linear or srgb color to an srgb color.
@inlinable
func colorgrade(_ rgb_: vec3f, _ linear: Bool, _ params: colorgrade_params) -> vec3f {
    var rgb = rgb_
    if (params.exposure != 0) {
        rgb *= exp2(params.exposure)
    }
    if (params.tint != vec3f(1, 1, 1)) {
        rgb *= params.tint
    }
    if (params.lincontrast != 0.5) {
        rgb = lincontrast(rgb, params.lincontrast, linear ? 0.18 : 0.5)
    }
    if (params.logcontrast != 0.5) {
        rgb = logcontrast(rgb, params.logcontrast, linear ? 0.18 : 0.5)
    }
    if (params.linsaturation != 0.5) {
        rgb = saturate(rgb, params.linsaturation)
    }
    if (params.filmic) {
        rgb = tonemap_filmic(rgb)
    }
    if (linear && params.srgb) {
        rgb = rgb_to_srgb(rgb)
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
    return rgb
}

@inlinable
func colorgrade(_ rgba: vec4f, _ linear: Bool, _ params: colorgrade_params) -> vec4f {
    let graded = colorgrade(xyz(rgba), linear, params)
    return [graded.x, graded.y, graded.z, rgba.w]
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

// RGB color space definition. Various predefined color spaces are listed below.
public struct color_space_params {
    // Curve type
    public enum curve_t {
        case linear
        case gamma
        case linear_gamma
        case aces_cc
        case aces_cct
        case pq
        case hlg
    }

    // primaries
    public var red_chromaticity: vec2f    // xy chromaticity of the red primary
    public var green_chromaticity: vec2f  // xy chromaticity of the green primary
    public var blue_chromaticity: vec2f   // xy chromaticity of the blue primary
    public var white_chromaticity: vec2f  // xy chromaticity of the white point
    public var rgb_to_xyz_mat: mat3f      // matrix from rgb to xyz
    public var xyz_to_rgb_mat: mat3f      // matrix from xyz to rgb
    // tone curve
    public var curve_type: curve_t
    public var curve_gamma: Float  // gamma for power curves
    public var curve_abcd: vec4f   // tone curve values for linear_gamma curves
}

// Compute the rgb -> xyz matrix from the color space definition
// Input: red, green, blue, white (x,y) chromoticities
// Algorithm from: SMPTE Recommended Practice RP 177-1993
// http://car.france3.mars.free.fr/HD/INA-%2026%20jan%2006/SMPTE%20normes%20et%20confs/rp177.pdf
@inlinable
func rgb_to_xyz_mat(_ rc: vec2f, _ gc: vec2f, _ bc: vec2f, _ wc: vec2f) -> mat3f {
    let rgb = mat3f(
            [rc.x, rc.y, 1 - rc.x - rc.y],
            [gc.x, gc.y, 1 - gc.x - gc.y],
            [bc.x, bc.y, 1 - bc.x - bc.y]
    )
    let w = vec3f(wc.x, wc.y, 1 - wc.x - wc.y)
    let c = inverse(rgb) * vec3f(w.x / w.y, 1, w.z / w.y)
    return mat3f(c.x * rgb.x, c.y * rgb.y, c.z * rgb.z)
}

// Construct an RGB color space. Predefined color spaces below
func get_color_scape_params(_ space: color_space) -> color_space_params {
    let make_linear_rgb_space = { (red: vec2f, green: vec2f, blue: vec2f, white: vec2f) -> color_space_params in
        color_space_params(red_chromaticity: red, green_chromaticity: green, blue_chromaticity: blue, white_chromaticity: white,
                rgb_to_xyz_mat: rgb_to_xyz_mat(red, green, blue, white), xyz_to_rgb_mat: inverse(rgb_to_xyz_mat(red, green, blue, white)),
                curve_type: .linear, curve_gamma: 0.0, curve_abcd: vec4f())
    }
    let make_gamma_rgb_space = { (red: vec2f, green: vec2f, blue: vec2f,
                                  white: vec2f, gamma: Float, curve_abcd: vec4f) -> color_space_params in
        color_space_params(red_chromaticity: red, green_chromaticity: green, blue_chromaticity: blue, white_chromaticity: white,
                rgb_to_xyz_mat: rgb_to_xyz_mat(red, green, blue, white), xyz_to_rgb_mat: inverse(rgb_to_xyz_mat(red, green, blue, white)),
                curve_type: curve_abcd == zero4f ? .gamma : .linear_gamma, curve_gamma: 0.0, curve_abcd: vec4f())
    }
    let make_other_rgb_space = { (red: vec2f, green: vec2f, blue: vec2f, white: vec2f, curve_type: color_space_params.curve_t) -> color_space_params in
        color_space_params(red_chromaticity: red, green_chromaticity: green, blue_chromaticity: blue, white_chromaticity: white,
                rgb_to_xyz_mat: rgb_to_xyz_mat(red, green, blue, white), xyz_to_rgb_mat: inverse(rgb_to_xyz_mat(red, green, blue, white)),
                curve_type: curve_type, curve_gamma: 0.0, curve_abcd: vec4f())
    }

    // color space parameters
    // https://en.wikipedia.org/wiki/Rec._709
    let rgb_params = make_linear_rgb_space([0.6400, 0.3300],
            [0.3000, 0.6000], [0.1500, 0.0600], [0.3127, 0.3290])
    // https://en.wikipedia.org/wiki/Rec._709
    let srgb_params = make_gamma_rgb_space([0.6400, 0.3300],
            [0.3000, 0.6000], [0.1500, 0.0600], [0.3127, 0.3290], 2.4,
            [1.055, 0.055, 12.92, 0.0031308])
    // https://en.wikipedia.org/wiki/Academy_Color_Encoding_System
    let aces2065_params = make_linear_rgb_space([0.7347, 0.2653],
            [0.0000, 1.0000], [0.0001, -0.0770], [0.32168, 0.33767])
    // https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
    let acescg_params = make_linear_rgb_space([0.7130, 0.2930],
            [0.1650, 0.8300], [0.1280, 0.0440], [0.32168, 0.33767])
    // https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
    let acescc_params = make_other_rgb_space([0.7130, 0.2930],
            [0.1650, 0.8300], [0.1280, 0.0440], [0.32168, 0.33767],
            .aces_cc)
    // https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
    let acescct_params = make_other_rgb_space([0.7130, 0.2930],
            [0.1650, 0.8300], [0.1280, 0.0440], [0.32168, 0.33767],
            .aces_cct)
    // https://en.wikipedia.org/wiki/Adobe_RGB_color_space
    let adobe_params = make_gamma_rgb_space([0.6400, 0.3300],
            [0.2100, 0.7100], [0.1500, 0.0600], [0.3127, 0.3290], 2.19921875, zero4f)
    // https://en.wikipedia.org/wiki/Rec._709
    let rec709_params = make_gamma_rgb_space([0.6400, 0.3300],
            [0.3000, 0.6000], [0.1500, 0.0600], [0.3127, 0.3290], 1 / 0.45,
            [1.099, 0.099, 4.500, 0.018])
    // https://en.wikipedia.org/wiki/Rec._2020
    let rec2020_params = make_gamma_rgb_space([0.7080, 0.2920],
            [0.1700, 0.7970], [0.1310, 0.0460], [0.3127, 0.3290], 1 / 0.45,
            [1.09929682680944, 0.09929682680944, 4.5, 0.018053968510807])
    // https://en.wikipedia.org/wiki/Rec._2020
    let rec2100pq_params = make_other_rgb_space([0.7080, 0.2920],
            [0.1700, 0.7970], [0.1310, 0.0460], [0.3127, 0.3290],
            .pq)
    // https://en.wikipedia.org/wiki/Rec._2020
    let rec2100hlg_params = make_other_rgb_space([0.7080, 0.2920],
            [0.1700, 0.7970], [0.1310, 0.0460], [0.3127, 0.3290],
            .hlg)
    // https://en.wikipedia.org/wiki/DCI-P3
    let p3dci_params = make_gamma_rgb_space([0.6800, 0.3200],
            [0.2650, 0.6900], [0.1500, 0.0600], [0.3140, 0.3510], 1.6, zero4f)
    // https://en.wikipedia.org/wiki/DCI-P3
    let p3d60_params = make_gamma_rgb_space([0.6800, 0.3200],
            [0.2650, 0.6900], [0.1500, 0.0600], [0.32168, 0.33767], 1.6, zero4f)
    // https://en.wikipedia.org/wiki/DCI-P3
    let p3d65_params = make_gamma_rgb_space([0.6800, 0.3200],
            [0.2650, 0.6900], [0.1500, 0.0600], [0.3127, 0.3290], 1.6, zero4f)
    // https://en.wikipedia.org/wiki/DCI-P3
    let p3display_params = make_gamma_rgb_space([0.6800, 0.3200],
            [0.2650, 0.6900], [0.1500, 0.0600], [0.3127, 0.3290], 2.4,
            [1.055, 0.055, 12.92, 0.0031308])
    // https://en.wikipedia.org/wiki/ProPhoto_RGB_color_space
    let prophoto_params = make_gamma_rgb_space([0.7347, 0.2653],
            [0.1596, 0.8404], [0.0366, 0.0001], [0.3457, 0.3585], 1.8,
            [1.0, 0.0, 16.0, 0.001953125])

    // return values
    switch (space) {
    case .rgb: return rgb_params
    case .srgb: return srgb_params
    case .adobe: return adobe_params
    case .prophoto: return prophoto_params
    case .rec709: return rec709_params
    case .rec2020: return rec2020_params
    case .rec2100pq: return rec2100pq_params
    case .rec2100hlg: return rec2100hlg_params
    case .aces2065: return aces2065_params
    case .acescg: return acescg_params
    case .acescc: return acescc_params
    case .acescct: return acescct_params
    case .p3dci: return p3dci_params
    case .p3d60: return p3d60_params
    case .p3d65: return p3d65_params
    case .p3display: return p3display_params
    }
}

// gamma to linear
@inlinable
func gamma_display_to_linear(_ x: Float, _ gamma: Float) -> Float {
    pow(x, gamma)
}

@inlinable
func gamma_linear_to_display(_ x: Float, _ gamma: Float) -> Float {
    pow(x, 1 / gamma)
}

// https://en.wikipedia.org/wiki/Rec._709
@inlinable
func gamma_display_to_linear(_ x: Float, _ gamma: Float, _ abcd: vec4f) -> Float {
    let a = abcd[0]
    let b = abcd[1]
    let c = abcd[2]
    let d = abcd[3]

    if (x < 1 / d) {
        return x / c
    } else {
        return pow((x + b) / a, gamma)
    }
}

@inlinable
func gamma_linear_to_display(_ x: Float, _ gamma: Float, _ abcd: vec4f) -> Float {
    let a = abcd[0]
    let b = abcd[1]
    let c = abcd[2]
    let d = abcd[3]

    if (x < d) {
        return x * c
    } else {
        return a * pow(x, 1 / gamma) - b
    }
}

// https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
@inlinable
func acescc_display_to_linear(_ x: Float) -> Float {
    if (x < -0.3013698630) {  // (9.72-15)/17.52
        return (exp2(x * 17.52 - 9.72) - exp2(-16.0)) * 2
    } else if (x < (log2(65504.0) + 9.72) / 17.52) {
        return exp2(x * 17.52 - 9.72)
    } else {  // (in >= (log2(65504)+9.72)/17.52)
        return 65504.0
    }
}

// https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
@inlinable
func acescct_display_to_linear(_ x: Float) -> Float {
    if (x < 0.155251141552511) {
        return (x - 0.0729055341958355) / 10.5402377416545
    } else {
        return exp2(x * 17.52 - 9.72)
    }
}

// https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
@inlinable
func acescc_linear_to_display(_ x: Float) -> Float {
    if (x <= 0) {
        return -0.3584474886  // =(log2( pow(2.,-16.))+9.72)/17.52
    } else if (x < exp2(-15.0)) {
        return (log2(exp2(-16.0) + x * 0.5) + 9.72) / 17.52
    } else {  // (in >= pow(2.,-15))
        return (log2(x) + 9.72) / 17.52
    }
}

// https://en.wikipedia.org/wiki/Academy_Color_Encoding_Systemx
@inlinable
func acescct_linear_to_display(_ x: Float) -> Float {
    if (x <= 0.0078125) {
        return 10.5402377416545 * x + 0.0729055341958355
    } else {
        return (log2(x) + 9.72) / 17.52
    }
}

// https://en.wikipedia.org/wiki/High-dynamic-range_video#Perceptual_Quantizer
// https://github.com/ampas/aces-dev/blob/master/transforms/ctl/lib/ACESlib.Utilities_Color.ctl
// In PQ, we assume that the linear luminance in [0,1] corresponds to
// [0,10000] cd m^2
@inlinable
func pq_display_to_linear(_ x: Float) -> Float {
    let Np = pow(x, 1 / 78.84375)
    var L = max(Np - 0.8359375, 0.0)
    L = L / (18.8515625 - 18.6875 * Np)
    L = pow(L, 1 / 0.1593017578125)
    return L
}

@inlinable
func pq_linear_to_display(_ x: Float) -> Float {
    pow((0.8359375 + 18.8515625 * pow(x, 0.1593017578125)) /
            (1 + 18.6875 * pow(x, 0.1593017578125)), 78.84375)
}

// https://en.wikipedia.org/wiki/High-dynamic-range_video#Perceptual_Quantizer
// In HLG, we assume that the linear luminance in [0,1] corresponds to
// [0,1000] cd m^2. Note that the version we report here is scaled in [0,1]
// range for nominal luminance. But HLG was initially defined in the [0,12]
// range where it maps 1 to 0.5 and 12 to 1. For use in HDR tonemapping that is
// likely a better range to use.
@inlinable
func hlg_display_to_linear(_ x: Float) -> Float {
    if (x < 0.5) {
        return 3 * 3 * x * x
    } else {
        return (exp((x - 0.55991073) / 0.17883277) + 0.28466892) / 12
    }
}

@inlinable
func hlg_linear_to_display(_ x: Float) -> Float {
    if (x < 1 / 12.0) {
        return sqrt(3 * x)
    } else {
        return 0.17883277 * log(12 * x - 0.28466892) + 0.55991073
    }
}

// Conversion between rgb color spaces
func color_to_xyz(_ col: vec3f, _ from: color_space) -> vec3f {
    let space = get_color_scape_params(from)
    var rgb = col
    if (space.curve_type == .linear) {
        // do nothing
    } else if (space.curve_type == .gamma) {
        rgb = [
            gamma_linear_to_display(rgb.x, space.curve_gamma),
            gamma_linear_to_display(rgb.y, space.curve_gamma),
            gamma_linear_to_display(rgb.z, space.curve_gamma)
        ]
    } else if (space.curve_type == .linear_gamma) {
        rgb = [
            gamma_linear_to_display(rgb.x, space.curve_gamma, space.curve_abcd),
            gamma_linear_to_display(rgb.y, space.curve_gamma, space.curve_abcd),
            gamma_linear_to_display(rgb.z, space.curve_gamma, space.curve_abcd)
        ]
    } else if (space.curve_type == .aces_cc) {
        rgb = [
            acescc_linear_to_display(rgb.x),
            acescc_linear_to_display(rgb.y),
            acescc_linear_to_display(rgb.z)
        ]
    } else if (space.curve_type == .aces_cct) {
        rgb = [
            acescct_linear_to_display(rgb.x),
            acescct_linear_to_display(rgb.y),
            acescct_linear_to_display(rgb.z)
        ]
    } else if (space.curve_type == .pq) {
        rgb = [
            pq_linear_to_display(rgb.x),
            pq_linear_to_display(rgb.y),
            pq_linear_to_display(rgb.z)
        ]
    } else if (space.curve_type == .hlg) {
        rgb = [
            hlg_linear_to_display(rgb.x),
            hlg_linear_to_display(rgb.y),
            hlg_linear_to_display(rgb.z)
        ]
    } else {
        fatalError("should not have gotten here")
    }
    return space.rgb_to_xyz_mat * rgb
}

func xyz_to_color(_ xyz: vec3f, _ to: color_space) -> vec3f {
    let space = get_color_scape_params(to)
    var rgb = space.xyz_to_rgb_mat * xyz
    if (space.curve_type == .linear) {
        // nothing
    } else if (space.curve_type == .gamma) {
        rgb = [
            gamma_display_to_linear(rgb.x, space.curve_gamma),
            gamma_display_to_linear(rgb.y, space.curve_gamma),
            gamma_display_to_linear(rgb.z, space.curve_gamma)
        ]
    } else if (space.curve_type == .linear_gamma) {
        rgb = [
            gamma_display_to_linear(rgb.x, space.curve_gamma, space.curve_abcd),
            gamma_display_to_linear(rgb.y, space.curve_gamma, space.curve_abcd),
            gamma_display_to_linear(rgb.z, space.curve_gamma, space.curve_abcd)
        ]
    } else if (space.curve_type == .aces_cc) {
        rgb = [
            acescc_display_to_linear(rgb.x),
            acescc_display_to_linear(rgb.y),
            acescc_display_to_linear(rgb.z)
        ]
    } else if (space.curve_type == .aces_cct) {
        rgb = [
            acescct_display_to_linear(rgb.x),
            acescct_display_to_linear(rgb.y),
            acescct_display_to_linear(rgb.z)
        ]
    } else if (space.curve_type == .pq) {
        rgb = [
            pq_display_to_linear(rgb.x),
            pq_display_to_linear(rgb.y),
            pq_display_to_linear(rgb.z)
        ]
    } else if (space.curve_type == .hlg) {
        rgb = [
            hlg_display_to_linear(rgb.x),
            hlg_display_to_linear(rgb.y),
            hlg_display_to_linear(rgb.z)
        ]
    } else {
        fatalError("should not have gotten here")
    }
    return rgb
}

// Conversion between rgb color spaces
@inlinable
func convert_color(_ col: vec3f, _ from: color_space, _ to: color_space) -> vec3f {
    if (from == to) {
        return col
    }
    return xyz_to_color(color_to_xyz(col, from), to)
}
