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
    fatalError()
}

// Schlick approximation of the Fresnel term.
@inlinable
func fresnel_schlick(_ specular: vec3f, _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

// Compute the fresnel term for dielectrics.
@inlinable
func fresnel_dielectric(_ eta: Float, _ normal: vec3f, _ outgoing: vec3f) -> Float {
    fatalError()
}

// Compute the fresnel term for metals.
@inlinable
func fresnel_conductor(_ eta: vec3f, _ etak: vec3f,
                       _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
}

// Convert eta to reflectivity
@inlinable
func eta_to_reflectivity(_ eta: vec3f) -> vec3f {
    fatalError()
}

// Convert reflectivity to  eta.
@inlinable
func reflectivity_to_eta(_ reflectivity: vec3f) -> vec3f {
    fatalError()
}

// Convert conductor eta to reflectivity.
@inlinable
func eta_to_reflectivity(_ eta: vec3f, _ etak: vec3f) -> vec3f {
    fatalError()
}

// Convert eta to edge tint parametrization.
@inlinable
func eta_to_edgetint(_ eta: vec3f, _ etak: vec3f) -> (vec3f, vec3f) {
    fatalError()
}

// Convert reflectivity and edge tint to eta.
@inlinable
func edgetint_to_eta(_ reflectivity: vec3f, _ edgetint: vec3f) -> (vec3f, vec3f) {
    fatalError()
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
    fatalError()
}

// Evaluates the microfacet shadowing.
@inlinable
func microfacet_shadowing(_ roughness: Float, _ normal: vec3f,
                          _ halfway: vec3f, _ outgoing: vec3f, _ incoming: vec3f,
                          _ ggx: Bool = true) -> Float {
    fatalError()
}

// Samples a microfacet distribution.
@inlinable
func sample_microfacet(_ roughness: Float, _ normal: vec3f, _ rn: vec2f, _ ggx: Bool = true) -> vec3f {
    fatalError()
}

// Pdf for microfacet distribution sampling.
@inlinable
func sample_microfacet_pdf(_ roughness: Float, _ normal: vec3f,
                           _ halfway: vec3f, _ ggx: Bool = true) -> Float {
    fatalError()
}

// Samples a microfacet distribution with the distribution of visible normals.
@inlinable
func sample_microfacet(_ roughness: Float, _ normal: vec3f,
                       _ outgoing: vec3f, _ rn: vec2f, _ ggx: Bool = true) -> vec3f {
    fatalError()
}

// Pdf for microfacet distribution sampling with the distribution of visible
// normals.
@inlinable
func sample_microfacet_pdf(_ roughness: Float, _ normal: vec3f,
                           _ halfway: vec3f, _ outgoing: vec3f, _ ggx: Bool = true) -> Float {
    fatalError()
}

// Microfacet energy compensation (E(cos(w)))
@inlinable
func microfacet_cosintegral(_ roughness: Float, _ normal: vec3f, _ outgoing: vec3f) -> Float {
    fatalError()
}

// Approximate microfacet compensation for metals with Schlick's Fresnel
@inlinable
func microfacet_compensation(_ color: vec3f, _ roughness: Float,
                             _ normal: vec3f, _ outgoing: vec3f) -> vec3f {
    fatalError()
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
