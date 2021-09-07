//
//  scene.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Handles to refer to scene elements
let invalidid: Int = -1

// Scene comprised an array of objects whose memory is owned by the scene.
// All members are optional,Scene objects (camera, instances, environments)
// have transforms defined internally. A scene can optionally contain a
// node hierarchy where each node might point to a camera, instance or
// environment. In that case, the element transforms are computed from
// the hierarchy. Animation is also optional, with keyframe data that
// updates node transformations only if defined.
struct scene_data {
    // scene elements
    var cameras: [camera_data] = []
    var instances: [instance_data] = []
    var environments: [environment_data] = []
    var shapes: [shape_data] = []
    var textures: [texture_data] = []
    var materials: [material_data] = []
    var subdivs: [subdiv_data] = []

    // names (this will be cleanup significantly later)
    var camera_names: [String] = []
    var texture_names: [String] = []
    var material_names: [String] = []
    var shape_names: [String] = []
    var instance_names: [String] = []
    var environment_names: [String] = []
    var subdiv_names: [String] = []

    // copyright info preserve in IO
    var copyright: String = ""
}

// -----------------------------------------------------------------------------
//MARK:- SCENE UTILITIES
// -----------------------------------------------------------------------------
// compute scene bounds
func compute_bounds(_ scene: scene_data) -> bbox3f {
    fatalError()
}

// add missing elements
func add_camera(_ scene: scene_data) {
    fatalError()
}

func add_sky(_ scene: scene_data, _ sun_angle: Float = Float.pi / 4) {
    fatalError()
}

// get named camera or default if name is empty
func find_camera(_ scene: scene_data, _ name: String) -> Int {
    fatalError()
}

// create a scene from a shape
func make_shape_scene(_ shape: shape_data, _ add_sky: Bool = false) -> scene_data {
    fatalError()
}

// Return scene statistics as list of strings.
func scene_stats(_ scene: scene_data, _ verbose: Bool = false) -> [String] {
    fatalError()
}

// Return validation errors as list of strings.
func scene_validation(_ scene: scene_data, _ notextures: Bool = false) -> [String] {
    fatalError()
}

// -----------------------------------------------------------------------------
//MARK:- SCENE TESSELATION
// -----------------------------------------------------------------------------
// Apply subdivision and displacement rules.
func tesselate_subdivs(_ scene: inout scene_data) {
    fatalError()
}

// -----------------------------------------------------------------------------
//MARK:- EXAMPLE SCENES
// -----------------------------------------------------------------------------
// Make Cornell Box scene
func make_cornellbox() -> scene_data {
    fatalError()
}
