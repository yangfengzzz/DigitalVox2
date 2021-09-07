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
    var shape_bbox: [bbox3f] = []
    var bbox = invalidb3f
    for shape in scene.shapes {
        var sbvh = bbox3f()
        for p in shape.positions {
            sbvh = merge(sbvh, p)
        }
        shape_bbox.append(sbvh)
    }
    for instance in scene.instances {
        let sbvh = shape_bbox[instance.shape]
        bbox = merge(bbox, transform_bbox(instance.frame, sbvh))
    }
    return bbox
}

// add missing elements
func add_camera(_ scene: inout scene_data) {
    scene.camera_names.append("camera")
    var camera = camera_data()
    camera.orthographic = false
    camera.film = 0.036
    camera.aspect = 16.0 / 9
    camera.aperture = 0
    camera.lens = 0.050
    let bbox = compute_bounds(scene)
    let center = (bbox.max + bbox.min) / 2
    let bbox_radius = length(bbox.max - bbox.min) / 2
    let camera_dir = vec3f(0, 0, 1)
    var camera_dist = bbox_radius * camera.lens / (camera.film / camera.aspect)
    camera_dist *= 2.0  // correction for tracer camera implementation
    let from = camera_dir * camera_dist + center
    let to = center
    let up = vec3f(0, 1, 0)
    camera.frame = lookat_frame(from, to, up)
    camera.focus = length(from - to)
    scene.cameras.append(camera)
}

func add_sky(_ scene: inout scene_data, _ sun_angle: Float = Float.pi / 4) {
    scene.texture_names.append("sky")
    let texture = image_to_texture(make_sunsky(1024, 512, sun_angle))
    scene.environment_names.append("sky")
    var environment = environment_data()
    environment.emission = [1, 1, 1]
    environment.emission_tex = scene.textures.count - 1
    scene.textures.append(texture)
    scene.environments.append(environment)
}

// get named camera or default if name is empty
func find_camera(_ scene: scene_data, _ name: String) -> Int {
    if (scene.cameras.isEmpty) {
        return invalidid
    }
    if (scene.camera_names.isEmpty) {
        return 0
    }
    for idx in 0..<scene.camera_names.count {
        if (scene.camera_names[idx] == name) {
            return idx
        }
    }
    for idx in 0..<scene.camera_names.count {
        if (scene.camera_names[idx] == "default") {
            return idx
        }
    }
    for idx in 0..<scene.camera_names.count {
        if (scene.camera_names[idx] == "camera") {
            return idx
        }
    }
    for idx in 0..<scene.camera_names.count {
        if (scene.camera_names[idx] == "camera0") {
            return idx
        }
    }
    for idx in 0..<scene.camera_names.count {
        if (scene.camera_names[idx] == "camera1") {
            return idx
        }
    }
    return 0
}

// create a scene from a shape
func make_shape_scene(_ shape: shape_data, _ addsky: Bool = false) -> scene_data {
    // scene
    var scene = scene_data()
    // shape
    scene.shape_names.append("shape")
    scene.shapes.append(shape)
    // material
    scene.material_names.append("material")
    var shape_material = material_data()
    shape_material.type = .glossy
    shape_material.color = [0.5, 1.0, 0.5]
    shape_material.roughness = 0.2
    scene.materials.append(shape_material)
    // instance
    scene.instance_names.append("instance")
    var shape_instance = instance_data()
    shape_instance.shape = 0
    shape_instance.material = 0
    scene.instances.append(shape_instance)
    // camera
    add_camera(&scene)
    // environment
    if (addsky) {
        add_sky(&scene)
    }
    // done
    return scene
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
