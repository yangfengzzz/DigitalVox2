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

func vector_memory<T>(_ values: [T]) -> Int {
    if (values.isEmpty) {
        return 0
    }
    return values.count * MemoryLayout<T>.stride
}

func compute_memory(_ scene: scene_data) -> Int {
    var memory = 0
    memory += vector_memory(scene.cameras)
    memory += vector_memory(scene.instances)
    memory += vector_memory(scene.materials)
    memory += vector_memory(scene.shapes)
    memory += vector_memory(scene.textures)
    memory += vector_memory(scene.environments)
    memory += vector_memory(scene.camera_names)
    memory += vector_memory(scene.instance_names)
    memory += vector_memory(scene.material_names)
    memory += vector_memory(scene.shape_names)
    memory += vector_memory(scene.texture_names)
    memory += vector_memory(scene.environment_names)
    for shape in scene.shapes {
        memory += vector_memory(shape.points)
        memory += vector_memory(shape.lines)
        memory += vector_memory(shape.triangles)
        memory += vector_memory(shape.quads)
        memory += vector_memory(shape.positions)
        memory += vector_memory(shape.normals)
        memory += vector_memory(shape.texcoords)
        memory += vector_memory(shape.colors)
        memory += vector_memory(shape.triangles)
    }
    for subdiv in scene.subdivs {
        memory += vector_memory(subdiv.quadspos)
        memory += vector_memory(subdiv.quadsnorm)
        memory += vector_memory(subdiv.quadstexcoord)
        memory += vector_memory(subdiv.positions)
        memory += vector_memory(subdiv.normals)
        memory += vector_memory(subdiv.texcoords)
    }
    for texture in scene.textures {
        memory += vector_memory(texture.pixelsb)
        memory += vector_memory(texture.pixelsf)
    }
    return memory
}

func accumulate<T>(_ values: [T], _ function: (T) -> Int) -> Int {
    var sum = 0
    for value in values {
        sum += function(value)
    }
    return sum
}

// Return scene statistics as list of strings.
func scene_stats(_ scene: scene_data, _ verbose: Bool = false) -> [String] {

    let format = { (num: Int) -> String in
        var num = num
        var str = String()
        while (num > 0) {
            str = String(num % 1000) + (str.isEmpty ? "" : ",") + str
            num /= 1000
        }
        if (str.isEmpty) {
            str = "0"
        }
        while (str.count < 20) {
            str = " " + str
        }
        return str
    }

    let format3 = { (num: vec3f) -> String in
        var str = String(num.x) + " " + String(num.y) + " " + String(num.z)
        while (str.count < 48) {
            str = " " + str
        }
        return str
    }

    let bbox = compute_bounds(scene)

    var stats: [String] = []
    stats.append("cameras:      " + format(scene.cameras.count))
    stats.append("instances:    " + format(scene.instances.count))
    stats.append("materials:    " + format(scene.materials.count))
    stats.append("shapes:       " + format(scene.shapes.count))
    stats.append("subdivs:      " + format(scene.subdivs.count))
    stats.append("environments: " + format(scene.environments.count))
    stats.append("textures:     " + format(scene.textures.count))
    stats.append("memory:       " + format(compute_memory(scene)))
    stats.append(
            "points:       " + format(accumulate(scene.shapes) { shape in
                shape.points.count
            }))
    stats.append(
            "lines:        " + format(accumulate(scene.shapes) { shape in
                shape.lines.count
            }))
    stats.append("triangles:    " +
            format(accumulate(scene.shapes) { shape in
                shape.triangles.count
            }))
    stats.append(
            "quads:        " + format(accumulate(scene.shapes) { shape in
                shape.quads.count
            }))
    stats.append("fvquads:      " +
            format(accumulate(scene.subdivs) { subdiv in
                subdiv.quadspos.count
            }))
    stats.append("texels4b:     " +
            format(accumulate(scene.textures) { texture in
                texture.pixelsb.count
            }))
    stats.append("texels4f:     " +
            format(accumulate(scene.textures) { texture in
                texture.pixelsf.count
            }))
    stats.append("center:       " + format3(center(bbox)))
    stats.append("size:         " + format3(size(bbox)))

    return stats

}

// Return validation errors as list of strings.
func scene_validation(_ scene: scene_data, _ notextures: Bool = false) -> [String] {
    var errs: [String] = []
    let check_names = { (names: [String], base: String) in
        var used: [String: Int] = [:]
        used.reserveCapacity(names.count)
        for name in names {
            used[name]! += 1
        }
        for (name, used) in used {
            if (name.isEmpty) {
                errs.append("empty " + base + " name")
            } else if (used > 1) {
                errs.append("duplicated " + base + " name " + name)
            }
        }
    }
    let check_empty_textures = { (scene: scene_data) in
        for idx in 0..<scene.textures.count {
            let texture = scene.textures[idx]
            if (texture.pixelsf.isEmpty && texture.pixelsb.isEmpty) {
                errs.append("empty texture " + scene.texture_names[idx])
            }
        }
    }

    check_names(scene.camera_names, "camera")
    check_names(scene.shape_names, "shape")
    check_names(scene.material_names, "material")
    check_names(scene.instance_names, "instance")
    check_names(scene.texture_names, "texture")
    check_names(scene.environment_names, "environment")
    if (!notextures) {
        check_empty_textures(scene)
    }

    return errs
}

// -----------------------------------------------------------------------------
//MARK:- SCENE TESSELATION
// -----------------------------------------------------------------------------
func tesselate_subdiv(_ shape: inout shape_data, _ subdiv_: inout subdiv_data, _ scene: scene_data) {
    var subdiv = subdiv_

    if (subdiv.subdivisions > 0) {
        if (subdiv.catmullclark) {
            for _ in 0..<subdiv.subdivisions {
                (subdiv.quadstexcoord, subdiv.texcoords) =
                        subdivide_catmullclark(
                                subdiv.quadstexcoord, subdiv.texcoords, true)
                (subdiv.quadsnorm, subdiv.normals) = subdivide_catmullclark(
                        subdiv.quadsnorm, subdiv.normals, true)
                (subdiv.quadspos, subdiv.positions) = subdivide_catmullclark(
                        subdiv.quadspos, subdiv.positions)
            }
        } else {
            for _ in 0..<subdiv.subdivisions {
                (subdiv.quadstexcoord, subdiv.texcoords) = subdivide_quads(
                        subdiv.quadstexcoord, subdiv.texcoords)
                (subdiv.quadsnorm, subdiv.normals) = subdivide_quads(
                        subdiv.quadsnorm, subdiv.normals)
                (subdiv.quadspos, subdiv.positions) = subdivide_quads(
                        subdiv.quadspos, subdiv.positions)
            }
        }
        if (subdiv.smooth) {
            subdiv.normals = quads_normals(subdiv.quadspos, subdiv.positions)
            subdiv.quadsnorm = subdiv.quadspos
        } else {
            subdiv.normals = []
            subdiv.quadsnorm = []
        }
    }

    if (subdiv.displacement != 0 && subdiv.displacement_tex != invalidid) {
        if (subdiv.texcoords.isEmpty) {
            fatalError("missing texture coordinates")
        }
        // facevarying case
        var offset = [Float](repeating: 0, count: subdiv.positions.count)
        var count = [Int](repeating: 0, count: subdiv.positions.count)
        for fid in 0..<subdiv.quadspos.count {
            let qpos = subdiv.quadspos[fid]
            let qtxt = subdiv.quadstexcoord[fid]
            for i in 0..<4 {
                let displacement_tex = scene.textures[subdiv.displacement_tex]
                var disp = mean(
                        eval_texture(displacement_tex, subdiv.texcoords[qtxt[i]], false))
                if (!displacement_tex.pixelsb.isEmpty) {
                    disp -= 0.5
                }
                offset[qpos[i]] += subdiv.displacement * disp
                count[qpos[i]] += 1
            }
        }
        let normals = quads_normals(subdiv.quadspos, subdiv.positions)
        for vid in 0..<subdiv.positions.count {
            subdiv.positions[vid] += normals[vid] * offset[vid] / Float(count[vid])
        }
        if (subdiv.smooth || !subdiv.normals.isEmpty) {
            subdiv.quadsnorm = subdiv.quadspos
            subdiv.normals = quads_normals(subdiv.quadspos, subdiv.positions)
        }
    }

    shape = shape_data()
    split_facevarying(&shape.quads, &shape.positions, &shape.normals,
            &shape.texcoords, subdiv.quadspos, subdiv.quadsnorm, subdiv.quadstexcoord,
            subdiv.positions, subdiv.normals, subdiv.texcoords)
}

// Apply subdivision and displacement rules.
func tesselate_subdivs(_ scene: inout scene_data) {
    // tesselate shapes
    scene.subdivs = scene.subdivs.map({ subdiv in
        var subdiv = subdiv
        tesselate_subdiv(&scene.shapes[subdiv.shape], &subdiv, scene)
        return subdiv
    })
}

// -----------------------------------------------------------------------------
//MARK:- EXAMPLE SCENES
// -----------------------------------------------------------------------------
// Make Cornell Box scene
func make_cornellbox() -> scene_data {
    var scene = scene_data()

    var camera = camera_data()
    camera.frame = frame3f([1, 0, 0], [0, 1, 0], [0, 0, 1], [0, 1, 3.9])
    camera.lens = 0.035
    camera.aperture = 0.0
    camera.focus = 3.9
    camera.film = 0.024
    camera.aspect = 1
    scene.cameras.append(camera)

    var floor_shape = shape_data()
    floor_shape.positions = [[-1, 0, 1], [1, 0, 1], [1, 0, -1], [-1, 0, -1]]
    floor_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(floor_shape)
    var floor_material = material_data()
    floor_material.color = [0.725, 0.71, 0.68]
    scene.materials.append(floor_material)
    var floor_instance = instance_data()
    floor_instance.shape = scene.shapes.count - 1
    floor_instance.material = scene.materials.count - 1
    scene.instances.append(floor_instance)

    var ceiling_shape = shape_data()
    ceiling_shape.positions = [[-1, 2, 1], [-1, 2, -1], [1, 2, -1], [1, 2, 1]]
    ceiling_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(ceiling_shape)
    var ceiling_material = material_data()
    ceiling_material.color = [0.725, 0.71, 0.68]
    scene.materials.append(ceiling_material)
    var ceiling_instance = instance_data()
    ceiling_instance.shape = scene.shapes.count - 1
    ceiling_instance.material = scene.materials.count - 1
    scene.instances.append(ceiling_instance)

    var backwall_shape = shape_data()
    backwall_shape.positions = [[-1, 0, -1], [1, 0, -1], [1, 2, -1], [-1, 2, -1]]
    backwall_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(backwall_shape)
    var backwall_material = material_data()
    backwall_material.color = [0.725, 0.71, 0.68]
    scene.materials.append(backwall_material)
    var backwall_instance = instance_data()
    backwall_instance.shape = scene.shapes.count - 1
    backwall_instance.material = scene.materials.count - 1
    scene.instances.append(backwall_instance)

    var rightwall_shape = shape_data()
    rightwall_shape.positions = [[1, 0, -1], [1, 0, 1], [1, 2, 1], [1, 2, -1]]
    rightwall_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(rightwall_shape)
    var rightwall_material = material_data()
    rightwall_material.color = [0.14, 0.45, 0.091]
    scene.materials.append(rightwall_material)
    var rightwall_instance = instance_data()
    rightwall_instance.shape = scene.shapes.count - 1
    rightwall_instance.material = scene.materials.count - 1
    scene.instances.append(rightwall_instance)

    var leftwall_shape = shape_data()
    leftwall_shape.positions = [[-1, 0, 1], [-1, 0, -1], [-1, 2, -1], [-1, 2, 1]]
    leftwall_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(leftwall_shape)
    var leftwall_material = material_data()
    leftwall_material.color = [0.63, 0.065, 0.05]
    scene.materials.append(leftwall_material)
    var leftwall_instance = instance_data()
    leftwall_instance.shape = scene.shapes.count - 1
    leftwall_instance.material = scene.materials.count - 1
    scene.instances.append(leftwall_instance)

    var shortbox_shape = shape_data()
    shortbox_shape.positions = [[0.53, 0.6, 0.75], [0.7, 0.6, 0.17],
                                [0.13, 0.6, 0.0], [-0.05, 0.6, 0.57], [-0.05, 0.0, 0.57],
                                [-0.05, 0.6, 0.57], [0.13, 0.6, 0.0], [0.13, 0.0, 0.0],
                                [0.53, 0.0, 0.75], [0.53, 0.6, 0.75], [-0.05, 0.6, 0.57],
                                [-0.05, 0.0, 0.57], [0.7, 0.0, 0.17], [0.7, 0.6, 0.17],
                                [0.53, 0.6, 0.75], [0.53, 0.0, 0.75], [0.13, 0.0, 0.0],
                                [0.13, 0.6, 0.0], [0.7, 0.6, 0.17], [0.7, 0.0, 0.17],
                                [0.53, 0.0, 0.75], [0.7, 0.0, 0.17], [0.13, 0.0, 0.0],
                                [-0.05, 0.0, 0.57]]
    shortbox_shape.triangles = [[0, 1, 2], [2, 3, 0], [4, 5, 6], [6, 7, 4],
                                [8, 9, 10], [10, 11, 8], [12, 13, 14], [14, 15, 12], [16, 17, 18],
                                [18, 19, 16], [20, 21, 22], [22, 23, 20]]
    scene.shapes.append(shortbox_shape)
    var shortbox_material = material_data()
    shortbox_material.color = [0.725, 0.71, 0.68]
    scene.materials.append(shortbox_material)
    var shortbox_instance = instance_data()
    shortbox_instance.shape = scene.shapes.count - 1
    shortbox_instance.material = scene.materials.count - 1
    scene.instances.append(shortbox_instance)

    var tallbox_shape = shape_data()
    tallbox_shape.positions = [[-0.53, 1.2, 0.09], [0.04, 1.2, -0.09],
                               [-0.14, 1.2, -0.67], [-0.71, 1.2, -0.49], [-0.53, 0.0, 0.09],
                               [-0.53, 1.2, 0.09], [-0.71, 1.2, -0.49], [-0.71, 0.0, -0.49],
                               [-0.71, 0.0, -0.49], [-0.71, 1.2, -0.49], [-0.14, 1.2, -0.67],
                               [-0.14, 0.0, -0.67], [-0.14, 0.0, -0.67], [-0.14, 1.2, -0.67],
                               [0.04, 1.2, -0.09], [0.04, 0.0, -0.09], [0.04, 0.0, -0.09],
                               [0.04, 1.2, -0.09], [-0.53, 1.2, 0.09], [-0.53, 0.0, 0.09],
                               [-0.53, 0.0, 0.09], [0.04, 0.0, -0.09], [-0.14, 0.0, -0.67],
                               [-0.71, 0.0, -0.49]]
    tallbox_shape.triangles = [[0, 1, 2], [2, 3, 0], [4, 5, 6], [6, 7, 4],
                               [8, 9, 10], [10, 11, 8], [12, 13, 14], [14, 15, 12], [16, 17, 18],
                               [18, 19, 16], [20, 21, 22], [22, 23, 20]]
    scene.shapes.append(tallbox_shape)
    var tallbox_material = material_data()
    tallbox_material.color = [0.725, 0.71, 0.68]
    scene.materials.append(tallbox_material)
    var tallbox_instance = instance_data()
    tallbox_instance.shape = scene.shapes.count - 1
    tallbox_instance.material = scene.materials.count - 1
    scene.instances.append(tallbox_instance)

    var light_shape = shape_data()
    light_shape.positions = [[-0.25, 1.99, 0.25], [-0.25, 1.99, -0.25],
                             [0.25, 1.99, -0.25], [0.25, 1.99, 0.25]]
    light_shape.triangles = [[0, 1, 2], [2, 3, 0]]
    scene.shapes.append(light_shape)
    var light_material = material_data()
    light_material.emission = [17, 12, 4]
    scene.materials.append(light_material)
    var light_instance = instance_data()
    light_instance.shape = scene.shapes.count - 1
    light_instance.material = scene.materials.count - 1
    scene.instances.append(light_instance)

    return scene
}
