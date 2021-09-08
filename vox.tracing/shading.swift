//
//  shading.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Check if on the same side of the hemisphere
@inlinable
func same_hemisphere(_ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Bool {
    dot(normal, outgoing) * dot(normal, incoming) >= 0
}

//MARK:- Fresnel
// Schlick approximation of the Fresnel term.
@inlinable
func fresnel_schlick(_ specular: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    if (specular == vec3f(0, 0, 0)) {
        return [0, 0, 0]
    }
    let cosine = dot(normal, outgoing)
    return specular + (1 - specular) * pow(simd_clamp(1 - abs(cosine), 0.0, 1.0), 5.0)
}

// Compute the fresnel term for dielectrics.
@inlinable
func fresnel_dielectric(_ eta: Float, _ normal: vec3f, _ outgoing: vec3f) -> Float {
    // Implementation from
    // https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
    let cosw = abs(dot(normal, outgoing))

    let sin2 = 1 - cosw * cosw
    let eta2 = eta * eta

    let cos2t = 1 - sin2 / eta2
    if (cos2t < 0) {
        return 1
    }  // tir

    let t0 = sqrt(cos2t)
    let t1 = eta * t0
    let t2 = eta * cosw

    let rs = (cosw - t1) / (cosw + t1)
    let rp = (t0 - t2) / (t0 + t2)

    return (rs * rs + rp * rp) / 2
}

// Compute the fresnel term for metals.
@inlinable
func fresnel_conductor(_ eta: vec3f, _ etak: vec3f,
                       _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    // Implementation from
    // https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
    var cosw = dot(normal, outgoing)
    if (cosw <= 0) {
        return [0, 0, 0]
    }

    cosw = simd_clamp(cosw, -1, 1)
    let cos2 = cosw * cosw
    let sin2 = simd_clamp(1 - cos2, 0, 1)
    let eta2 = eta * eta
    let etak2 = etak * etak

    let t0 = eta2 - etak2 - sin2
    let a2plusb2 = sqrt(t0 * t0 + 4 * eta2 * etak2)
    let t1 = a2plusb2 + cos2
    let a = sqrt((a2plusb2 + t0) / 2)
    let t2 = 2 * a * cosw
    let rs = (t1 - t2) / (t1 + t2)

    let t3 = cos2 * a2plusb2 + sin2 * sin2
    let t4 = t2 * sin2
    let rp = rs * (t3 - t4) / (t3 + t4)

    return (rp + rs) / 2
}

// Convert eta to reflectivity
@inlinable
func eta_to_reflectivity(_ eta: vec3f) -> vec3f {
    let numer = (eta - 1) * (eta - 1)
    let denom = (eta + 1) * (eta + 1)
    return numer / denom
}

// Convert reflectivity to  eta.
@inlinable
func reflectivity_to_eta(_ reflectivity_: vec3f) -> vec3f {
    let reflectivity = clamp(reflectivity_, 0.0, 0.99)
    return (1 + sqrt(reflectivity)) / (1 - sqrt(reflectivity))
}

// Convert conductor eta to reflectivity.
@inlinable
func eta_to_reflectivity(_ eta: vec3f, _ etak: vec3f) -> vec3f {
    var numer: vec3f = (eta - 1.0) * (eta - 1.0)
    numer += etak * etak
    var denom: vec3f = (eta + 1.0) * (eta + 1.0)
    denom += etak * etak
    return numer / denom
}

// Convert eta to edge tint parametrization.
@inlinable
func eta_to_edgetint(_ eta: vec3f, _ etak: vec3f) -> (vec3f, vec3f) {
    let reflectivity = eta_to_reflectivity(eta, etak)
    let numer = (1 + sqrt(reflectivity)) / (1 - sqrt(reflectivity)) - eta
    var denom = (1 + sqrt(reflectivity)) / (1 - sqrt(reflectivity))
    denom -= (1 - reflectivity) / (1 + reflectivity)
    let edgetint = numer / denom
    return (reflectivity, edgetint)
}

// Convert reflectivity and edge tint to eta.
@inlinable
func edgetint_to_eta(_ reflectivity: vec3f, _ edgetint: vec3f) -> (vec3f, vec3f) {
    let r = clamp(reflectivity, 0.0, 0.99)
    let g = edgetint

    let r_sqrt = sqrt(r)
    let n_min = (1 - r) / (1 + r)
    let n_max = (1 + r_sqrt) / (1 - r_sqrt)

    let n = lerp(n_max, n_min, g)
    var k2 = (n + 1) * (n + 1) * r
    k2 -= (n - 1) * (n - 1)
    k2 /= (1 - r)
    k2 = max(k2, 0.0)
    let k = sqrt(k2)
    return (n, k)
}

public let metal_ior_table: [(String, (vec3f, vec3f))] = [
    ("a-C", ([2.9440999183, 2.2271502925, 1.9681668794],
            [0.8874329109, 0.7993216383, 0.8152862927])),
    ("Ag", ([0.1552646489, 0.1167232965, 0.1383806959],
            [4.8283433224, 3.1222459278, 2.1469504455])),
    ("Al", ([1.6574599595, 0.8803689579, 0.5212287346],
            [9.2238691996, 6.2695232477, 4.8370012281])),
    ("AlAs", ([3.6051023902, 3.2329365777, 2.2175611545],
            [0.0006670247, -0.0004999400, 0.0074261204])),
    ("AlSb", ([-0.0485225705, 4.1427547893, 4.6697691348],
            [-0.0363741915, 0.0937665154, 1.3007390124])),
    ("Au", ([0.1431189557, 0.3749570432, 1.4424785571],
            [3.9831604247, 2.3857207478, 1.6032152899])),
    ("Be", ([4.1850592788, 3.1850604423, 2.7840913457],
            [3.8354398268, 3.0101260162, 2.8690088743])),
    ("Cr", ([4.3696828663, 2.9167024892, 1.6547005413],
            [5.2064337956, 4.2313645277, 3.7549467933])),
    ("CsI", ([2.1449030413, 1.7023164587, 1.6624194173],
            [0.0000000000, 0.0000000000, 0.0000000000])),
    ("Cu", ([0.2004376970, 0.9240334304, 1.1022119527],
            [3.9129485033, 2.4528477015, 2.1421879552])),
    ("Cu2O", ([3.5492833755, 2.9520622449, 2.7369202137],
            [0.1132179294, 0.1946659670, 0.6001681264])),
    ("CuO", ([3.2453822204, 2.4496293965, 2.1974114493],
            [0.5202739621, 0.5707372756, 0.7172250613])),
    ("d-C", ([2.7112524747, 2.3185812849, 2.2288565009],
            [0.0000000000, 0.0000000000, 0.0000000000])),
    ("Hg", ([2.3989314904, 1.4400254917, 0.9095512090],
            [6.3276269444, 4.3719414152, 3.4217899270])),
    ("HgTe", ([4.7795267752, 3.2309984581, 2.6600252401],
            [1.6319827058, 1.5808189339, 1.7295753852])),
    ("Ir", ([3.0864098394, 2.0821938440, 1.6178866805],
            [5.5921510077, 4.0671757150, 3.2672611269])),
    ("K", ([0.0640493070, 0.0464100621, 0.0381842017],
            [2.1042155920, 1.3489364357, 0.9132113889])),
    ("Li", ([0.2657871942, 0.1956102432, 0.2209198538],
            [3.5401743407, 2.3111306542, 1.6685930000])),
    ("MgO", ([2.0895885542, 1.6507224525, 1.5948759692],
            [0.0000000000, -0.0000000000, 0.0000000000])),
    ("Mo", ([4.4837010280, 3.5254578255, 2.7760769438],
            [4.1111307988, 3.4208716252, 3.1506031404])),
    ("Na", ([0.0602665320, 0.0561412435, 0.0619909494],
            [3.1792906496, 2.1124800781, 1.5790940266])),
    ("Nb", ([3.4201353595, 2.7901921379, 2.3955856658],
            [3.4413817900, 2.7376437930, 2.5799132708])),
    ("Ni", ([2.3672753521, 1.6633583302, 1.4670554172],
            [4.4988329911, 3.0501643957, 2.3454274399])),
    ("Rh", ([2.5857954933, 1.8601866068, 1.5544279524],
            [6.7822927110, 4.7029501026, 3.9760892461])),
    ("Se-e", ([5.7242724833, 4.1653992967, 4.0816099264],
            [0.8713747439, 1.1052845009, 1.5647788766])),
    ("Se", ([4.0592611085, 2.8426947380, 2.8207582835],
            [0.7543791750, 0.6385150558, 0.5215872029])),
    ("SiC", ([3.1723450205, 2.5259677964, 2.4793623897],
            [0.0000007284, -0.0000006859, 0.0000100150])),
    ("SnTe", ([4.5251865890, 1.9811525984, 1.2816819226],
            [0.0000000000, 0.0000000000, 0.0000000000])),
    ("Ta", ([2.0625846607, 2.3930915569, 2.6280684948],
            [2.4080467973, 1.7413705864, 1.9470377016])),
    ("Te-e", ([7.5090397678, 4.2964603080, 2.3698732430],
            [5.5842076830, 4.9476231084, 3.9975145063])),
    ("Te", ([7.3908396088, 4.4821028985, 2.6370708478],
            [3.2561412892, 3.5273908133, 3.2921683116])),
    ("ThF4", ([1.8307187117, 1.4422274283, 1.3876488528],
            [0.0000000000, 0.0000000000, 0.0000000000])),
    ("TiC", ([3.7004673762, 2.8374356509, 2.5823030278],
            [3.2656905818, 2.3515586388, 2.1727857800])),
    ("TiN", ([1.6484691607, 1.1504482522, 1.3797795097],
            [3.3684596226, 1.9434888540, 1.1020123347])),
    ("TiO2-e", ([3.1065574823, 2.5131551146, 2.5823844157],
            [0.0000289537, -0.0000251484, 0.0001775555])),
    ("TiO2", ([3.4566203131, 2.8017076558, 2.9051485020],
            [0.0001026662, -0.0000897534, 0.0006356902])),
    ("VC", ([3.6575665991, 2.7527298065, 2.5326814570],
            [3.0683516659, 2.1986687713, 1.9631816252])),
    ("VN", ([2.8656011588, 2.1191817791, 1.9400767149],
            [3.0323264950, 2.0561075580, 1.6162930914])),
    ("V", ([4.2775126218, 3.5131538236, 2.7611257461],
            [3.4911844504, 2.8893580874, 3.1116965117])),
    ("W", ([4.3707029924, 3.3002972445, 2.9982666528],
            [3.5006778591, 2.6048652781, 2.2731930614])),
]

// Get tabulated ior for conductors
@inlinable
func conductor_eta(_ name: String) -> (vec3f, vec3f) {
    for (ename, etas) in metal_ior_table {
        if (ename == name) {
            return etas
        }
    }
    return ([0, 0, 0], [0, 0, 0])

}

//MARK:- Microfacet
// Evaluates the microfacet distribution.
@inlinable
func microfacet_distribution(_ roughness: Float, _ normal: vec3f,
                             _ halfway: vec3f, _ ggx: Bool = true) -> Float {
    // https://google.github.io/filament/Filament.html#materialsystem/specularbrdf
    // http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    let cosine = dot(normal, halfway)
    if (cosine <= 0) {
        return 0
    }
    let roughness2 = roughness * roughness
    let cosine2 = cosine * cosine
    if (ggx) {
        return roughness2 / (Float.pi * (cosine2 * roughness2 + 1 - cosine2) *
                (cosine2 * roughness2 + 1 - cosine2))
    } else {
        return exp((cosine2 - 1) / (roughness2 * cosine2)) /
                (Float.pi * roughness2 * cosine2 * cosine2)
    }
}

// Evaluate the microfacet shadowing1
@inlinable
func microfacet_shadowing1(_ roughness: Float, _ normal: vec3f,
                           _ halfway: vec3f, _ direction: vec3f, _ ggx: Bool) -> Float {
    // https://google.github.io/filament/Filament.html#materialsystem/specularbrdf
    // http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    // https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#appendix-b-brdf-implementation
    let cosine = dot(normal, direction)
    let cosineh = dot(halfway, direction)
    if (cosine * cosineh <= 0) {
        return 0
    }
    let roughness2 = roughness * roughness
    let cosine2 = cosine * cosine
    if (ggx) {
        return 2 * abs(cosine) /
                (abs(cosine) + sqrt(cosine2 - roughness2 * cosine2 + roughness2))
    } else {
        let ci = abs(cosine) / (roughness * sqrt(1 - cosine2))
        return ci < 1.6 ? (3.535 * ci + 2.181 * ci * ci) /
                (1.0 + 2.276 * ci + 2.577 * ci * ci) : 1.0
    }
}

// Evaluates the microfacet shadowing.
@inlinable
func microfacet_shadowing(_ roughness: Float, _ normal: vec3f,
                          _ halfway: vec3f, _ outgoing: vec3f, _ incoming: vec3f,
                          _ ggx: Bool = true) -> Float {
    microfacet_shadowing1(roughness, normal, halfway, outgoing, ggx) *
            microfacet_shadowing1(roughness, normal, halfway, incoming, ggx)
}

// Samples a microfacet distribution.
@inlinable
func sample_microfacet(_ roughness: Float, _ normal: vec3f, _ rn: vec2f, _ ggx: Bool = true) -> vec3f {
    let phi = 2 * Float.pi * rn.x
    var theta: Float = 0.0
    if (ggx) {
        theta = atan(roughness * sqrt(rn.y / (1 - rn.y)))
    } else {
        let roughness2 = roughness * roughness
        theta = atan(sqrt(-roughness2 * log(1 - rn.y)))
    }
    let local_half_vector = vec3f(
            cos(phi) * sin(theta), sin(phi) * sin(theta), cos(theta))
    return transform_direction(basis_fromz(normal), local_half_vector)
}

// Pdf for microfacet distribution sampling.
@inlinable
func sample_microfacet_pdf(_ roughness: Float, _ normal: vec3f,
                           _ halfway: vec3f, _ ggx: Bool = true) -> Float {
    let cosine = dot(normal, halfway)
    if (cosine < 0) {
        return 0
    }
    return microfacet_distribution(roughness, normal, halfway, ggx) * cosine
}

// Samples a microfacet distribution with the distribution of visible normals.
@inlinable
func sample_microfacet(_ roughness: Float, _ normal: vec3f,
                       _ outgoing: vec3f, _ rn: vec2f, _ ggx: Bool = true) -> vec3f {
    // http://jcgt.org/published/0007/04/01/
    if (ggx) {
        // move to local coordinate system
        let basis = basis_fromz(normal)
        let Ve = transform_direction(transpose(basis), outgoing)
        let alpha_x = roughness, alpha_y = roughness
        // Section 3.2: transforming the view direction to the hemisphere
        // configuration
        let Vh = normalize(vec3f(alpha_x * Ve.x, alpha_y * Ve.y, Ve.z))
        // Section 4.1: orthonormal basis (with special case if cross product is
        // zero)
        let lensq = Vh.x * Vh.x + Vh.y * Vh.y
        let T1 = lensq > 0 ? vec3f(-Vh.y, Vh.x, 0) * (1 / sqrt(lensq))
                : vec3f(1, 0, 0)
        let T2 = simd_cross(Vh, T1)
        // Section 4.2: parameterization of the projected area
        let r = sqrt(rn.y), phi = 2 * Float.pi * rn.x
        let t1 = r * cos(phi)
        var t2 = r * sin(phi)
        let s = 0.5 * (1 + Vh.z)
        t2 = (1 - s) * sqrt(1 - t1 * t1) + s * t2
        // Section 4.3: reprojection onto hemisphere
        var Nh = t1 * T1 + t2 * T2
        Nh += sqrt(max(0.0, 1 - t1 * t1 - t2 * t2)) * Vh
        // Section 3.4: transforming the normal back to the ellipsoid configuration
        let Ne = normalize(vec3f(alpha_x * Nh.x, alpha_y * Nh.y, max(0.0, Nh.z)))
        // move to world coordinate
        let local_halfway = Ne
        return transform_direction(basis, local_halfway)
    } else {
        fatalError("not implemented yet")
    }
}

// Pdf for microfacet distribution sampling with the distribution of visible
// normals.
@inlinable
func sample_microfacet_pdf(_ roughness: Float, _ normal: vec3f,
                           _ halfway: vec3f, _ outgoing: vec3f, _ ggx: Bool = true) -> Float {
    // http://jcgt.org/published/0007/04/01/
    if (dot(normal, halfway) < 0) {
        return 0
    }
    if (dot(halfway, outgoing) < 0) {
        return 0
    }
    return microfacet_distribution(roughness, normal, halfway, ggx) *
            microfacet_shadowing1(roughness, normal, halfway, outgoing, ggx) *
            max(0.0, dot(halfway, outgoing)) / abs(dot(normal, outgoing))
}

// Microfacet energy compensation (E(cos(w)))
@inlinable
func microfacet_cosintegral(_ roughness: Float, _ normal: vec3f, _ outgoing: vec3f) -> Float {
    // https://blog.selfshadow.com/publications/s2017-shading-course/imageworks/s2017_pbs_imageworks_slides_v2.pdf
    let S: [Float] = [-0.170718, 4.07985, -11.5295, 18.4961, -9.23618]
    let T: [Float] = [0.0632331, 3.1434, -7.47567, 13.0482, -7.0401]
    let m = abs(dot(normal, outgoing))
    let r = roughness
    var s = S[0] * sqrt(m) + S[1] * r + S[2] * r * r
    s += S[3] * r * r * r
    s += S[4] * r * r * r * r
    var t = T[0] * m + T[1] * r + T[2] * r * r
    t += T[3] * r * r * r
    t += T[4] * r * r * r * r
    return 1 - pow(s, 6.0) * pow(m, 3.0 / 4.0) / (pow(t, 6.0) + pow(m, 2.0))
}

// Approximate microfacet compensation for metals with Schlick's Fresnel
@inlinable
func microfacet_compensation(_ color: vec3f, _ roughness: Float,
                             _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    // https://blog.selfshadow.com/publications/turquin/ms_comp_final.pdf
    let E = microfacet_cosintegral(sqrt(roughness), normal, outgoing)
    return 1 + color * (1 - E) / E
}

//MARK:- Matte
// Evaluates a diffuse BRDF lobe.
@inlinable
func eval_matte(_ color: vec3f, _ normal: vec3f,
                _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    return color / Float.pi * abs(dot(normal, incoming))
}

// Sample a diffuse BRDF lobe.
@inlinable
func sample_matte(_ color: vec3f, _ normal: vec3f,
                  _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return sample_hemisphere_cos(up_normal, rn)
}

// Pdf for diffuse BRDF lobe sampling.
@inlinable
func sample_matte_pdf(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return sample_hemisphere_cos_pdf(up_normal, incoming)
}

//MARK:- Glossy
// Evaluates a specular BRDF lobe.
@inlinable
func eval_glossy(_ color: vec3f, _ ior: Float, _ roughness: Float,
                 _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let F1 = fresnel_dielectric(ior, up_normal, outgoing)
    let halfway = normalize(incoming + outgoing)
    let F = fresnel_dielectric(ior, halfway, incoming)
    let D = microfacet_distribution(roughness, up_normal, halfway)
    let G = microfacet_shadowing(roughness, up_normal, halfway, outgoing, incoming)

    var result = vec3f(1, 1, 1) * F * D * G
    result /= 4 * dot(up_normal, outgoing) * dot(up_normal, incoming)
    result *= abs(dot(up_normal, incoming))
    return color * ((1 - F1) / Float.pi * abs(dot(up_normal, incoming))) + result
}

// Sample a specular BRDF lobe.
@inlinable
func sample_glossy(_ color: vec3f, _ ior: Float, _ roughness: Float,
                   _ normal: vec3f, _ outgoing: vec3f, rnl: Float, _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (rnl < fresnel_dielectric(ior, up_normal, outgoing)) {
        let halfway = sample_microfacet(roughness, up_normal, rn)
        let incoming = reflect(outgoing, halfway)
        if (!same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    } else {
        return sample_hemisphere_cos(up_normal, rn)
    }
}

// Pdf for specular BRDF lobe sampling.
@inlinable
func sample_glossy_pdf(_ color: vec3f, _ ior: Float, _ roughness: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(outgoing + incoming)
    let F = fresnel_dielectric(ior, up_normal, outgoing)
    return F * sample_microfacet_pdf(roughness, up_normal, halfway) /
            (4 * abs(dot(outgoing, halfway))) +
            (1 - F) * sample_hemisphere_cos_pdf(up_normal, incoming)
}

//MARK:- Reflective
// Evaluates a metal BRDF lobe.
@inlinable
func eval_reflective(_ color: vec3f, _ roughness: Float,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(incoming + outgoing)
    let F = fresnel_conductor(
            reflectivity_to_eta(color), [0, 0, 0], halfway, incoming)
    let D = microfacet_distribution(roughness, up_normal, halfway)
    let G = microfacet_shadowing(
            roughness, up_normal, halfway, outgoing, incoming)
    return F * D * G / (4 * dot(up_normal, outgoing) * dot(up_normal, incoming)) *
            abs(dot(up_normal, incoming))
}

// Sample a metal BRDF lobe.
@inlinable
func sample_reflective(_ color: vec3f, _ roughness: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = sample_microfacet(roughness, up_normal, rn)
    let incoming = reflect(outgoing, halfway)
    if (!same_hemisphere(up_normal, outgoing, incoming)) {
        return [0, 0, 0]
    }
    return incoming
}

// Pdf for metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ color: vec3f, _ roughness: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(outgoing + incoming)
    return sample_microfacet_pdf(roughness, up_normal, halfway) /
            (4 * abs(dot(outgoing, halfway)))
}

// Evaluate a delta metal BRDF lobe.
@inlinable
func eval_reflective(_ eta: vec3f, _ etak: vec3f, _ roughness: Float,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(incoming + outgoing)
    let F = fresnel_conductor(eta, etak, halfway, incoming)
    let D = microfacet_distribution(roughness, up_normal, halfway)
    let G = microfacet_shadowing(
            roughness, up_normal, halfway, outgoing, incoming)
    return F * D * G / (4 * dot(up_normal, outgoing) * dot(up_normal, incoming)) *
            abs(dot(up_normal, incoming))
}

// Sample a delta metal BRDF lobe.
@inlinable
func sample_reflective(_ eta: vec3f, _ etak: vec3f, _ roughness: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = sample_microfacet(roughness, up_normal, rn)
    return reflect(outgoing, halfway)
}

// Pdf for delta metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ eta: vec3f, _ etak: vec3f, _ roughness: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(outgoing + incoming)
    return sample_microfacet_pdf(roughness, up_normal, halfway) /
            (4 * abs(dot(outgoing, halfway)))
}

// Evaluate a delta metal BRDF lobe.
@inlinable
func eval_reflective(_ color: vec3f, _ normal: vec3f,
                     _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return fresnel_conductor(
            reflectivity_to_eta(color), [0, 0, 0], up_normal, outgoing)
}

// Sample a delta metal BRDF lobe.
@inlinable
func sample_reflective(_ color: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return reflect(outgoing, up_normal)
}

// Pdf for delta metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ color: vec3f, _ normal: vec3f,
                           _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    return 1
}

// Evaluate a delta metal BRDF lobe.
@inlinable
func eval_reflective(_ eta: vec3f, _ etak: vec3f,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return fresnel_conductor(eta, etak, up_normal, outgoing)
}

// Sample a delta metal BRDF lobe.
@inlinable
func sample_reflective(_ eta: vec3f, _ etak: vec3f,
                       _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return reflect(outgoing, up_normal)
}

// Pdf for delta metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ eta: vec3f, _ etak: vec3f,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    return 1
}

//MARK:- gltf pbr
// Evaluates a specular BRDF lobe.
@inlinable
func eval_gltfpbr(_ color: vec3f, _ ior: Float, _ roughness: Float,
                  _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f,
                  _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return [0, 0, 0]
    }
    let reflectivity = lerp(eta_to_reflectivity(vec3f(ior, ior, ior)), color, metallic)
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let F1 = fresnel_schlick(reflectivity, up_normal, outgoing)
    let halfway = normalize(incoming + outgoing)
    let F = fresnel_schlick(reflectivity, halfway, incoming)
    let D = microfacet_distribution(roughness, up_normal, halfway)
    let G = microfacet_shadowing(roughness, up_normal, halfway, outgoing, incoming)

    var result = F * D * G
    result /= 4 * dot(up_normal, outgoing) * dot(up_normal, incoming)
    result += abs(dot(up_normal, incoming))
    let result2 = (1 - F1) * ((1 - metallic) / Float.pi * abs(dot(up_normal, incoming)))
    return color * result2 + result
}

// Sample a specular BRDF lobe.
@inlinable
func sample_gltfpbr(_ color: vec3f, _ ior: Float, _ roughness: Float,
                    _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float,
                    _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let reflectivity = lerp(eta_to_reflectivity(vec3f(ior, ior, ior)), color, metallic)
    if (rnl < mean(fresnel_schlick(reflectivity, up_normal, outgoing))) {
        let halfway = sample_microfacet(roughness, up_normal, rn)
        let incoming = reflect(outgoing, halfway)
        if (!same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    } else {
        return sample_hemisphere_cos(up_normal, rn)
    }
}

// Pdf for specular BRDF lobe sampling.
@inlinable
func sample_gltfpbr_pdf(_ color: vec3f, _ ior: Float, _ roughness: Float,
                        _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f,
                        _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) <= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = normalize(outgoing + incoming)
    let reflectivity = lerp(eta_to_reflectivity(vec3f(ior, ior, ior)), color, metallic)
    let F = mean(fresnel_schlick(reflectivity, up_normal, outgoing))
    return F * sample_microfacet_pdf(roughness, up_normal, halfway) /
            (4 * abs(dot(outgoing, halfway))) +
            (1 - F) * sample_hemisphere_cos_pdf(up_normal, incoming)
}

//MARK:- Transparent
// Evaluates a transmission BRDF lobe.
@inlinable
func eval_transparent(_ color: vec3f, _ ior: Float, _ roughness: Float,
                      _ normal: vec3f, _ outgoing: vec3f, _  incoming: vec3f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        let halfway = normalize(incoming + outgoing)
        let F = fresnel_dielectric(ior, halfway, outgoing)
        let D = microfacet_distribution(roughness, up_normal, halfway)
        let G = microfacet_shadowing(roughness, up_normal, halfway, outgoing, incoming)
        return vec3f(1, 1, 1) * F * D * G /
                (4 * dot(up_normal, outgoing) * dot(up_normal, incoming)) *
                abs(dot(up_normal, incoming))
    } else {
        let reflected = reflect(-incoming, up_normal)
        let halfway = normalize(reflected + outgoing)
        let F = fresnel_dielectric(ior, halfway, outgoing)
        let D = microfacet_distribution(roughness, up_normal, halfway)
        let G = microfacet_shadowing(roughness, up_normal, halfway, outgoing, reflected)

        var result = color * (1 - F) * D * G
        result /= 4 * dot(up_normal, outgoing) * dot(up_normal, reflected)
        return result * (abs(dot(up_normal, reflected)))
    }
}

// Sample a transmission BRDF lobe.
@inlinable
func sample_transparent(_ ior: Float, _ roughness: Float, _ normal: vec3f,
                        _ outgoing: vec3f, _ rnl: Float, _ rn: vec2f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    let halfway = sample_microfacet(roughness, up_normal, rn)
    if (rnl < fresnel_dielectric(ior, halfway, outgoing)) {
        let incoming = reflect(outgoing, halfway)
        if (!same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    } else {
        let reflected = reflect(outgoing, halfway)
        let incoming = -reflect(reflected, up_normal)
        if (same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    }
}

// Pdf for transmission BRDF lobe sampling.
@inlinable
func sample_tranparent_pdf(_ color: vec3f, _ ior: Float,
                           _ roughness: Float, _ normal: vec3f, _ outgoing: vec3f,
                           _ incoming: vec3f) -> Float {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        let halfway = normalize(incoming + outgoing)
        return fresnel_dielectric(ior, halfway, outgoing) *
                sample_microfacet_pdf(roughness, up_normal, halfway) /
                (4 * abs(dot(outgoing, halfway)))
    } else {
        let reflected = reflect(-incoming, up_normal)
        let halfway = normalize(reflected + outgoing)
        let d = (1 - fresnel_dielectric(ior, halfway, outgoing)) *
                sample_microfacet_pdf(roughness, up_normal, halfway)
        return d / (4 * abs(dot(outgoing, halfway)))
    }
}

// Evaluate a delta transmission BRDF lobe.
@inlinable
func eval_transparent(_ color: vec3f, _ ior: Float,
                      _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return vec3f(1, 1, 1) * fresnel_dielectric(ior, up_normal, outgoing)
    } else {
        return color * (1 - fresnel_dielectric(ior, up_normal, outgoing))
    }
}

// Sample a delta transmission BRDF lobe.
@inlinable
func sample_transparent(_ color: vec3f, _ ior: Float,
                        _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float) -> vec3f {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (rnl < fresnel_dielectric(ior, up_normal, outgoing)) {
        return reflect(outgoing, up_normal)
    } else {
        return -outgoing
    }
}

// Pdf for delta transmission BRDF lobe sampling.
@inlinable
func sample_tranparent_pdf(_ color: vec3f, _ ior: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return fresnel_dielectric(ior, up_normal, outgoing)
    } else {
        return 1 - fresnel_dielectric(ior, up_normal, outgoing)
    }
}

//MARK:- Refractive
// Evaluates a refraction BRDF lobe.
@inlinable
func eval_refractive(_ color: vec3f, _ ior: Float, _ roughness: Float,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let rel_ior = entering ? ior : (1 / ior)
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        let halfway = normalize(incoming + outgoing)
        let F = fresnel_dielectric(rel_ior, halfway, outgoing)
        let D = microfacet_distribution(roughness, up_normal, halfway)
        let G = microfacet_shadowing(roughness, up_normal, halfway, outgoing, incoming)
        return vec3f(1, 1, 1) * F * D * G /
                abs(4 * dot(normal, outgoing) * dot(normal, incoming)) *
                abs(dot(normal, incoming))
    } else {
        let halfway = -normalize(rel_ior * incoming + outgoing) *
                (entering ? 1.0 : -1.0)
        let F = fresnel_dielectric(rel_ior, halfway, outgoing)
        let D = microfacet_distribution(roughness, up_normal, halfway)
        let G = microfacet_shadowing(
                roughness, up_normal, halfway, outgoing, incoming)

        // [Walter 2007] equation 21
        var result = vec3f(1, 1, 1)
        result *= abs((dot(outgoing, halfway) * dot(incoming, halfway)) / (dot(outgoing, normal) * dot(incoming, normal)))
        result *= (1 - F) * D * G
        result /= pow(rel_ior * dot(halfway, incoming) + dot(halfway, outgoing), 2)
        return result * abs(dot(normal, incoming))
    }
}

// Sample a refraction BRDF lobe.
@inlinable
func sample_refractive(_ ior: Float, _ roughness: Float, _ normal: vec3f,
                       _ outgoing: vec3f, _ rnl: Float, _ rn: vec2f) -> vec3f {
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let halfway = sample_microfacet(roughness, up_normal, rn)
    // auto halfway = sample_microfacet(roughness, up_normal, outgoing, rn)
    if (rnl < fresnel_dielectric(entering ? ior : (1 / ior), halfway, outgoing)) {
        let incoming = reflect(outgoing, halfway)
        if (!same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    } else {
        let incoming = refract(outgoing, halfway, entering ? (1 / ior) : ior)
        if (same_hemisphere(up_normal, outgoing, incoming)) {
            return [0, 0, 0]
        }
        return incoming
    }
}

// Pdf for refraction BRDF lobe sampling.
@inlinable
func sample_refractive_pdf(_ color: vec3f, _ ior: Float,
                           _ roughness: Float, _ normal: vec3f, _ outgoing: vec3f,
                           _ incoming: vec3f) -> Float {
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let rel_ior = entering ? ior : (1 / ior)
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        let halfway = normalize(incoming + outgoing)
        return fresnel_dielectric(rel_ior, halfway, outgoing) *
                sample_microfacet_pdf(roughness, up_normal, halfway) /
                //  sample_microfacet_pdf(roughness, up_normal, halfway, outgoing) /
                (4 * abs(dot(outgoing, halfway)))
    } else {
        let halfway = -normalize(rel_ior * incoming + outgoing) *
                (entering ? 1.0 : -1.0)
        // [Walter 2007] equation 17
        return (1 - fresnel_dielectric(rel_ior, halfway, outgoing)) *
                sample_microfacet_pdf(roughness, up_normal, halfway) *
                //  sample_microfacet_pdf(roughness, up_normal, halfway, outgoing) /
                abs(dot(halfway, incoming)) / // here we use incoming as from pbrt
                pow(rel_ior * dot(halfway, incoming) + dot(halfway, outgoing), 2)
    }
}

// Evaluate a delta refraction BRDF lobe.
@inlinable
func eval_refractive(_ color: vec3f, _ ior: Float, _ normal: vec3f,
                     _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (abs(ior - 1) < 1e-3) {
        return dot(normal, incoming) * dot(normal, outgoing) <= 0 ? vec3f(1, 1, 1)
                : vec3f(0, 0, 0)
    }
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let rel_ior = entering ? ior : (1 / ior)
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return vec3f(1, 1, 1) * fresnel_dielectric(rel_ior, up_normal, outgoing)
    } else {
        return vec3f(1, 1, 1) * (1 / (rel_ior * rel_ior)) *
                (1 - fresnel_dielectric(rel_ior, up_normal, outgoing))
    }
}

// Sample a delta refraction BRDF lobe.
@inlinable
func sample_refractive(_ color: vec3f, _ ior: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float) -> vec3f {
    if (abs(ior - 1) < 1e-3) {
        return -outgoing
    }
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let rel_ior = entering ? ior : (1 / ior)
    if (rnl < fresnel_dielectric(rel_ior, up_normal, outgoing)) {
        return reflect(outgoing, up_normal)
    } else {
        return refract(outgoing, up_normal, 1 / rel_ior)
    }
}

// Pdf for delta refraction BRDF lobe sampling.
@inlinable
func sample_refractive_pdf(_ color: vec3f, _ ior: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (abs(ior - 1) < 1e-3) {
        return dot(normal, incoming) * dot(normal, outgoing) < 0 ? 1.0 : 0.0
    }
    let entering = dot(normal, outgoing) >= 0
    let up_normal = entering ? normal : -normal
    let rel_ior = entering ? ior : (1 / ior)
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return fresnel_dielectric(rel_ior, up_normal, outgoing)
    } else {
        return (1 - fresnel_dielectric(rel_ior, up_normal, outgoing))
    }
}

//MARK:- Translucent
// Evaluate a translucent BRDF lobe.
@inlinable
func eval_translucent(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    // TODO (fabio): fix me
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return [0, 0, 0]
    }
    return color / Float.pi * abs(dot(normal, incoming))
}

// Pdf for translucency BRDF lobe sampling.
@inlinable
func sample_translucent_pdf(_ color: vec3f, _ normal: vec3f,
                            _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    // TODO (fabio): fix me
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return 0
    }
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return sample_hemisphere_cos_pdf(-up_normal, incoming)
}

// Sample a translucency BRDF lobe.
@inlinable
func sample_translucent(_ color: vec3f, _ normal: vec3f,
                        _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    // TODO (fabio): fix me
    let up_normal = dot(normal, outgoing) <= 0 ? -normal : normal
    return sample_hemisphere_cos(-up_normal, rn)
}

//MARK:- Passthrough
// Evaluate a passthrough BRDF lobe.
@inlinable
func eval_passthrough(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return vec3f(0, 0, 0)
    } else {
        return vec3f(1, 1, 1)
    }
}

// Sample a passthrough BRDF lobe.
@inlinable
func sample_passthrough(_ color: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    -outgoing
}

// Pdf for passthrough BRDF lobe sampling.
@inlinable
func sample_passthrough_pdf(_ color: vec3f, _ normal: vec3f,
                            _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    if (dot(normal, incoming) * dot(normal, outgoing) >= 0) {
        return 0
    } else {
        return 1
    }
}

//MARK:- Transmission
// Convert mean-free-path to transmission
@inlinable
func mfp_to_transmission(_ mfp: vec3f, _ depth: Float) -> vec3f {
    exp(-depth / mfp)
}

// Evaluate transmittance
@inlinable
func eval_transmittance(_ density: vec3f, _ distance: Float) -> vec3f {
    exp(-density * distance)
}

// Sample a distance proportionally to transmittance
@inlinable
func sample_transmittance(_ density: vec3f, _ max_distance: Float, _ rl: Float, _ rd: Float) -> Float {
    let channel = Int(simd_clamp(rl * 3, 0, 2))
    let distance = (density[channel] == 0) ? Float.greatestFiniteMagnitude
            : -log(1 - rd) / density[channel]
    return min(distance, max_distance)
}

// Pdf for distance sampling
@inlinable
func sample_transmittance_pdf(_ density: vec3f, _ distance: Float, _ max_distance: Float) -> Float {
    if (distance < max_distance) {
        return sum(density * exp(-density * distance)) / 3
    } else {
        return sum(exp(-density * max_distance)) / 3
    }
}

//MARK:- Phasefunction
// Evaluate phase function
@inlinable
func eval_phasefunction(_ anisotropy: Float, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    let cosine = -dot(outgoing, incoming)
    let denom = 1 + anisotropy * anisotropy - 2 * anisotropy * cosine
    return (1 - anisotropy * anisotropy) / (4 * Float.pi * denom * sqrt(denom))
}

// Sample phase function
@inlinable
func sample_phasefunction(_ anisotropy: Float, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    var cos_theta: Float = 0.0
    if (abs(anisotropy) < 1e-3) {
        cos_theta = 1 - 2 * rn.y
    } else {
        let square = (1 - anisotropy * anisotropy) /
                (1 + anisotropy - 2 * anisotropy * rn.y)
        cos_theta = (1 + anisotropy * anisotropy - square * square) /
                (2 * anisotropy)
    }

    let sin_theta = sqrt(max(0.0, 1 - cos_theta * cos_theta))
    let phi = 2 * Float.pi * rn.x
    let local_incoming = vec3f(
            sin_theta * cos(phi), sin_theta * sin(phi), cos_theta)
    return basis_fromz(-outgoing) * local_incoming
}

// Pdf for phase function sampling
@inlinable
func sample_phasefunction_pdf(_ anisotropy: Float, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    eval_phasefunction(anisotropy, outgoing, incoming)
}
