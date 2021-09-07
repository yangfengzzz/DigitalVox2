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

// Get tabulated ior for conductors
@inlinable
func conductor_eta(_ name: String) -> (vec3f, vec3f) {
    fatalError()
}

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

// Evaluates a diffuse BRDF lobe.
@inlinable
func eval_matte(_ color: vec3f, _ normal: vec3f,
                _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a diffuse BRDF lobe.
@inlinable
func sample_matte(_ color: vec3f, _ normal: vec3f,
                  _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for diffuse BRDF lobe sampling.
@inlinable
func sample_matte_pdf(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluates a specular BRDF lobe.
@inlinable
func eval_glossy(_ color: vec3f, _ ior: Float, _ roughness: Float,
                 _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a specular BRDF lobe.
@inlinable
func sample_glossy(_ color: vec3f, _ ior: Float, _ roughness: Float,
                   _ normal: vec3f, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for specular BRDF lobe sampling.
@inlinable
func sample_glossy_pdf(_ color: vec3f, _ ior: Float, _ roughness: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluates a metal BRDF lobe.
@inlinable
func eval_reflective(_ color: vec3f, _ roughness: Float,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a metal BRDF lobe.
@inlinable
func sample_reflective(_ color: vec3f, _ roughness: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ color: vec3f, _ roughness: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluate a delta metal BRDF lobe.
@inlinable
func eval_reflective(_ color: vec3f, _ normal: vec3f,
                     _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a delta metal BRDF lobe.
@inlinable
func sample_reflective(_ color: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

// Pdf for delta metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ color: vec3f, _ normal: vec3f,
                           _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluate a delta metal BRDF lobe.
@inlinable
func eval_reflective(_ eta: vec3f, _ etak: vec3f,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a delta metal BRDF lobe.
@inlinable
func sample_reflective(_ eta: vec3f, _ etak: vec3f,
                       _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

// Pdf for delta metal BRDF lobe sampling.
@inlinable
func sample_reflective_pdf(_ eta: vec3f, _ etak: vec3f,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluates a specular BRDF lobe.
@inlinable
func eval_gltfpbr(_ color: vec3f, _ ior: Float, _ roughness: Float,
                  _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f,
                  _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a specular BRDF lobe.
@inlinable
func sample_gltfpbr(_ color: vec3f, _ ior: Float, _ roughness: Float,
                    _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float,
                    _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for specular BRDF lobe sampling.
@inlinable
func sample_gltfpbr_pdf(_ color: vec3f, _ ior: Float, _ roughness: Float,
                        _ metallic: Float, _ normal: vec3f, _ outgoing: vec3f,
                        _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluates a transmission BRDF lobe.
@inlinable
func eval_transparent(_ color: vec3f, _ ior: Float, _ roughness: Float,
                      _ normal: vec3f, _ outgoing: vec3f, _  incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a transmission BRDF lobe.
@inlinable
func sample_transparent(_ ior: Float, _ roughness: Float, _ normal: vec3f,
                        _ outgoing: vec3f, _ rnl: Float, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for transmission BRDF lobe sampling.
@inlinable
func sample_tranparent_pdf(_ color: vec3f, _ ior: Float,
                           _ roughness: Float, _ normal: vec3f, _ outgoing: vec3f,
                           _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluate a delta transmission BRDF lobe.
@inlinable
func eval_transparent(_ color: vec3f, _ ior: Float,
                      _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a delta transmission BRDF lobe.
@inlinable
func sample_transparent(_ color: vec3f, _ ior: Float,
                        _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float) -> vec3f {
    fatalError()
}

// Pdf for delta transmission BRDF lobe sampling.
@inlinable
func sample_tranparent_pdf(_ color: vec3f, _ ior: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluates a refraction BRDF lobe.
@inlinable
func eval_refractive(_ color: vec3f, _ ior: Float, _ roughness: Float,
                     _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a refraction BRDF lobe.
@inlinable
func sample_refractive(_ ior: Float, _ roughness: Float, _ normal: vec3f,
                       _ outgoing: vec3f, _ rnl: Float, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for refraction BRDF lobe sampling.
@inlinable
func sample_refractive_pdf(_ color: vec3f, _ ior: Float,
                           _ roughness: Float, _ normal: vec3f, _ outgoing: vec3f,
                           _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluate a delta refraction BRDF lobe.
@inlinable
func eval_refractive(_ color: vec3f, _ ior: Float, _ normal: vec3f,
                     _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a delta refraction BRDF lobe.
@inlinable
func sample_refractive(_ color: vec3f, _ ior: Float,
                       _ normal: vec3f, _ outgoing: vec3f, _ rnl: Float) -> vec3f {
    fatalError()
}

// Pdf for delta refraction BRDF lobe sampling.
@inlinable
func sample_refractive_pdf(_ color: vec3f, _ ior: Float,
                           _ normal: vec3f, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Evaluate a translucent BRDF lobe.
@inlinable
func eval_translucent(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Pdf for translucency BRDF lobe sampling.
@inlinable
func sample_translucent_pdf(_ color: vec3f, _ normal: vec3f,
                            _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Sample a translucency BRDF lobe.
@inlinable
func sample_translucent(_ color: vec3f, _ normal: vec3f,
                        _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Evaluate a passthrough BRDF lobe.
@inlinable
func eval_passthrough(_ color: vec3f, _ normal: vec3f,
                      _ outgoing: vec3f, _ incoming: vec3f) -> vec3f {
    fatalError()
}

// Sample a passthrough BRDF lobe.
@inlinable
func sample_passthrough(_ color: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

// Pdf for passthrough BRDF lobe sampling.
@inlinable
func sample_passthrough_pdf(_ color: vec3f, _ normal: vec3f,
                            _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Convert mean-free-path to transmission
@inlinable
func mfp_to_transmission(_ mfp: vec3f, _ depth: Float) -> vec3f {
    fatalError()
}

// Evaluate transmittance
@inlinable
func eval_transmittance(_ density: vec3f, _ distance: Float) -> vec3f {
    fatalError()
}

// Sample a distance proportionally to transmittance
@inlinable
func sample_transmittance(_ density: vec3f, _ max_distance: Float, _ rl: Float, _ rd: Float) -> Float {
    fatalError()
}

// Pdf for distance sampling
@inlinable
func sample_transmittance_pdf(_ density: vec3f, _ distance: Float, _ max_distance: Float) -> Float {
    fatalError()
}

// Evaluate phase function
@inlinable
func eval_phasefunction(_ anisotropy: Float, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}

// Sample phase function
@inlinable
func sample_phasefunction(_ anisotropy: Float, _ outgoing: vec3f, _ rn: vec2f) -> vec3f {
    fatalError()
}

// Pdf for phase function sampling
@inlinable
func sample_phasefunction_pdf(_ anisotropy: Float, _ outgoing: vec3f, _ incoming: vec3f) -> Float {
    fatalError()
}
