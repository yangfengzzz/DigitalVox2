//
//  material_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

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
                   _ shape_color: vec4f = [1, 1, 1, 1]) -> material_point {
    fatalError()
}

// check if a material is a delta
func is_delta(_ material: material_data) -> Bool {
    fatalError()
}

func is_delta(_ material: material_point) -> Bool {
    fatalError()
}

// check if a material has a volume
func is_volumetric(_ material: material_data) -> Bool {
    fatalError()
}

func is_volumetric(_ material: material_point) -> Bool {
    fatalError()
}
