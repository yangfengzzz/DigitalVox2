//
//  material_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// constant values
let min_roughness: Float = 0.03 * 0.03

// Material type
enum material_type {
    case matte
    case glossy
    case reflective
    case transparent
    case refractive
    case subsurface
    case volumetric
    case gltfpbr
}

// Enum labels
let material_type_names = ["matte", "glossy", "reflective", "transparent",
                           "refractive", "subsurface", "volumetric", "gltfpbr"]

// Material for surfaces, lines and triangles.
// For surfaces, uses a microfacet model with thin sheet transmission.
// The model is based on OBJ, but contains glTF compatibility.
// For the documentation on the values, please see the OBJ format.
struct material_data {
    // material
    var type: material_type = .matte

    var emission: vec3f = [0, 0, 0]
    var color: vec3f = [0, 0, 0]
    var roughness: Float = 0
    var metallic: Float = 0
    var ior: Float = 1.5
    var scattering: vec3f = [0, 0, 0]
    var scanisotropy: Float = 0
    var trdepth: Float = 0.01
    var opacity: Float = 1

    // textures
    var emission_tex: Int = invalidid
    var color_tex: Int = invalidid
    var roughness_tex: Int = invalidid
    var scattering_tex: Int = invalidid
    var normal_tex: Int = invalidid
}

// Material parameters evaluated at a point on the surface
struct material_point {
    var type: material_type = .gltfpbr
    var emission: vec3f = [0, 0, 0]
    var color: vec3f = [0, 0, 0]
    var opacity: Float = 1
    var roughness: Float = 0
    var metallic: Float = 0
    var ior: Float = 1
    var density: vec3f = [0, 0, 0]
    var scattering: vec3f = [0, 0, 0]
    var scanisotropy: Float = 0
    var trdepth: Float = 0.01
}

// Eval material to obtain emission, brdf and opacity.
func eval_material(_ scene: scene_data, _ material: material_data, _ texcoord: vec2f,
                   _ color_shp: vec4f = [1, 1, 1, 1]) -> material_point {
    // evaluate textures
    let emission_tex = eval_texture(
            scene, material.emission_tex, texcoord, true)
    let color_tex = eval_texture(scene, material.color_tex, texcoord, true)
    let roughness_tex = eval_texture(
            scene, material.roughness_tex, texcoord, false)
    let scattering_tex = eval_texture(
            scene, material.scattering_tex, texcoord, true)

    // material point
    var point = material_point()
    point.type = material.type
    point.emission = material.emission * xyz(emission_tex)
    point.color = material.color * xyz(color_tex) * xyz(color_shp)
    point.opacity = material.opacity * color_tex.w * color_shp.w
    point.metallic = material.metallic * roughness_tex.z
    point.roughness = material.roughness * roughness_tex.y
    point.roughness = point.roughness * point.roughness
    point.ior = material.ior
    point.scattering = material.scattering * xyz(scattering_tex)
    point.scanisotropy = material.scanisotropy
    point.trdepth = material.trdepth

    // volume density
    if (material.type == .refractive ||
            material.type == .volumetric ||
            material.type == .subsurface) {
        point.density = -log(clamp(point.color, 0.0001, 1.0)) / point.trdepth
    } else {
        point.density = [0, 0, 0]
    }

    // fix roughness
    if (point.type == .matte ||
            point.type == .gltfpbr ||
            point.type == .glossy) {
        point.roughness = simd_clamp(point.roughness, min_roughness, 1.0)
    }

    return point
}

// check if a material is a delta
func is_delta(_ material: material_data) -> Bool {
    (material.type == .reflective &&
            material.roughness == 0) ||
            (material.type == .refractive &&
                    material.roughness == 0) ||
            (material.type == .transparent &&
                    material.roughness == 0) ||
            (material.type == .volumetric)
}

func is_delta(_ material: material_point) -> Bool {
    (material.type == .reflective &&
            material.roughness == 0) ||
            (material.type == .refractive &&
                    material.roughness == 0) ||
            (material.type == .transparent &&
                    material.roughness == 0) ||
            (material.type == .volumetric)
}

// check if a material has a volume
func is_volumetric(_ material: material_data) -> Bool {
    material.type == .refractive ||
            material.type == .volumetric ||
            material.type == .subsurface
}

func is_volumetric(_ material: material_point) -> Bool {
    material.type == .refractive ||
            material.type == .volumetric ||
            material.type == .subsurface
}
