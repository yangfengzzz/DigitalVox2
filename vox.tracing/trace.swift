//
//  trace.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// -----------------------------------------------------------------------------
//MARK:- RENDERING API
// -----------------------------------------------------------------------------
// Type of tracing algorithm
enum trace_sampler_type {
    case path        // path tracing
    case pathdirect  // path tracing with direct
    case pathmis     // path tracing with mis
    case naive       // naive path tracing
    case eyelight    // eyelight rendering
    case eyelightao  // eyelight with ambient occlusion
    case furnace     // furnace test
    case falsecolor  // false color rendering
}

// Type of false color visualization
enum trace_falsecolor_type {
    case position
    case normal
    case frontfacing
    case gnormal
    case gfrontfacing
    case texcoord
    case mtype
    case color
    case emission
    case roughness
    case opacity
    case metallic
    case delta
    case instance
    case shape
    case material
    case element
    case highlight
}

// Default trace seed
let trace_default_seed: UInt64 = 961748941

// Options for trace functions
struct trace_params {
    var camera: Int = 0
    var resolution: Int = 1280
    var sampler: trace_sampler_type = .path
    var falsecolor: trace_falsecolor_type = .color
    var samples: Int = 512
    var bounces: Int = 8
    var clamp: Float = 10
    var nocaustics: Bool = false
    var envhidden: Bool = false
    var tentfilter: Bool = false
    var seed: UInt64 = trace_default_seed
    var embreebvh: Bool = false
    var highqualitybvh: Bool = false
    var noparallel: Bool = false
    var pratio: Int = 8
    var exposure: Float = 0
    var filmic: Bool = false
    var denoise: Bool = false
    var batch: Int = 1
}

let trace_sampler_names = ["path", "pathdirect", "pathmis", "naive",
                           "eyelight", "eyelightao", "furnace", "falsecolor"]

let trace_falsecolor_names = ["position", "normal", "frontfacing", "gnormal", "gfrontfacing",
                              "texcoord", "mtype", "color", "emission", "roughness", "opacity",
                              "metallic", "delta", "instance", "shape", "material", "element", "highlight"]

// Progress report callback
typealias image_callback = (Int, Int) -> Void

// Progressively computes an image.
func trace_image(_ scene: scene_data, _ params: trace_params) -> image_data {
    fatalError()
}

// -----------------------------------------------------------------------------
//MARK:- LOWER-LEVEL RENDERING API
// -----------------------------------------------------------------------------

// Scene lights used during rendering. These are created automatically.
struct trace_light {
    var instance: Int = invalidid
    var environment: Int = invalidid
    var elements_cdf: [Float] = []
}

// Scene lights
struct trace_lights {
    var lights: [trace_light] = []
}

// Check is a sampler requires lights
func is_sampler_lit(params: trace_params) -> Bool {
    fatalError()
}

// Trace state
struct trace_state {
    var width: Int = 0
    var height: Int = 0
    var samples: Int = 0
    var image: [vec4f] = []
    var albedo: [vec3f] = []
    var normal: [vec3f] = []
    var hits: [Int] = []
}

// Initialize state.
func make_state(_ scene: scene_data, _ params: trace_params) -> trace_state {
    fatalError()
}

// Initialize lights.
func make_lights(_ scene: scene_data, _ params: trace_params) -> trace_lights {
    fatalError()
}

// Build the bvh acceleration structure.
func make_bvh(_ scene: scene_data, _ params: trace_params) -> bvh_data {
    fatalError()
}

// Progressively computes an image.
func trace_samples(_ state: inout trace_state, _ scene: scene_data,
                   _ bvh: bvh_data, _ lights: trace_lights,
                   _ params: trace_params) {
    fatalError()
}

func trace_sample(_ state: inout trace_state, _ scene: scene_data,
                  _ bvh: bvh_data, _ lights: trace_lights, _ i: Int, _ j: Int,
                  _ params: trace_params) {
    fatalError()
}

// Get resulting render
func get_render(_ state: trace_state) -> image_data {
    fatalError()
}

func get_render(_ render: inout image_data, _ state: trace_state) {
    fatalError()
}

// Get denoised result
func get_denoised(_ state: trace_state) -> image_data {
    fatalError()
}

func get_denoised(_ render: inout image_data, _ state: trace_state) {
    fatalError()
}

// Get denoising buffers
func get_albedo(_ state: trace_state) -> image_data {
    fatalError()
}

func get_albedo(_ albedo: inout image_data, _ state: trace_state) {
    fatalError()
}

func get_normal(_ state: trace_state) -> image_data {
    fatalError()
}

func get_normal(_ normal: inout image_data, _ state: trace_state) {
    fatalError()
}

// Denoise image
func denoise_render(_ render: image_data, _ albedo: image_data,
                    _ normal: image_data) -> image_data {
    fatalError()
}

func denoise_render(_ denoised: inout image_data, _ render: image_data,
                    _ albedo: image_data, _ normal: image_data) {
    fatalError()
}
