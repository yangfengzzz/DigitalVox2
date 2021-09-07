//
//  instance_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Instance.
struct instance_data {
    // instance data
    var frame: frame3f = identity3x4f
    var shape: Int = invalidid
    var material: Int = invalidid
}

// Evaluate instance properties
func eval_position(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> vec3f {
    let shape = scene.shapes[instance.shape]
    if (!shape.triangles.isEmpty) {
        let t = shape.triangles[element]
        return transform_point(
                instance.frame, interpolate_triangle(shape.positions[t.x],
                shape.positions[t.y], shape.positions[t.z], uv))
    } else if (!shape.quads.isEmpty) {
        let q = shape.quads[element]
        return transform_point(instance.frame,
                interpolate_quad(shape.positions[q.x], shape.positions[q.y],
                        shape.positions[q.z], shape.positions[q.w], uv))
    } else if (!shape.lines.isEmpty) {
        let l = shape.lines[element]
        return transform_point(instance.frame,
                interpolate_line(shape.positions[l.x], shape.positions[l.y], uv.x))
    } else if (!shape.points.isEmpty) {
        return transform_point(
                instance.frame, shape.positions[shape.points[element]])
    } else {
        return [0, 0, 0]
    }
}

func eval_element_normal(_ scene: scene_data, _ instance: instance_data,
                         _ element: Int) -> vec3f {
    let shape = scene.shapes[instance.shape]
    if (!shape.triangles.isEmpty) {
        let t = shape.triangles[element]
        return transform_normal(
                instance.frame, triangle_normal(shape.positions[t.x],
                shape.positions[t.y], shape.positions[t.z]))
    } else if (!shape.quads.isEmpty) {
        let q = shape.quads[element]
        return transform_normal(
                instance.frame, quad_normal(shape.positions[q.x], shape.positions[q.y],
                shape.positions[q.z], shape.positions[q.w]))
    } else if (!shape.lines.isEmpty) {
        let l = shape.lines[element]
        return transform_normal(instance.frame,
                line_tangent(shape.positions[l.x], shape.positions[l.y]))
    } else if (!shape.points.isEmpty) {
        return [0, 0, 1]
    } else {
        return [0, 0, 0]
    }
}

func eval_normal(_ scene: scene_data, _ instance: instance_data,
                 _ element: Int, _ uv: vec2f) -> vec3f {
    let shape = scene.shapes[instance.shape]
    if (shape.normals.isEmpty) {
        return eval_element_normal(scene, instance, element)
    }
    if (!shape.triangles.isEmpty) {
        let t = shape.triangles[element]
        return transform_normal(
                instance.frame, normalize(interpolate_triangle(shape.normals[t.x],
                shape.normals[t.y], shape.normals[t.z], uv)))
    } else if (!shape.quads.isEmpty) {
        let q = shape.quads[element]
        return transform_normal(instance.frame,
                normalize(interpolate_quad(shape.normals[q.x], shape.normals[q.y],
                        shape.normals[q.z], shape.normals[q.w], uv)))
    } else if (!shape.lines.isEmpty) {
        let l = shape.lines[element]
        return transform_normal(instance.frame,
                normalize(
                        interpolate_line(shape.normals[l.x], shape.normals[l.y], uv.x)))
    } else if (!shape.points.isEmpty) {
        return transform_normal(
                instance.frame, normalize(shape.normals[shape.points[element]]))
    } else {
        return [0, 0, 0]
    }
}

func eval_texcoord(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> vec2f {
    let shape = scene.shapes[instance.shape]
    if (shape.texcoords.isEmpty) {
        return uv
    }
    if (!shape.triangles.isEmpty) {
        let t = shape.triangles[element]
        return interpolate_triangle(
                shape.texcoords[t.x], shape.texcoords[t.y], shape.texcoords[t.z], uv)
    } else if (!shape.quads.isEmpty) {
        let q = shape.quads[element]
        return interpolate_quad(shape.texcoords[q.x], shape.texcoords[q.y],
                shape.texcoords[q.z], shape.texcoords[q.w], uv)
    } else if (!shape.lines.isEmpty) {
        let l = shape.lines[element]
        return interpolate_line(shape.texcoords[l.x], shape.texcoords[l.y], uv.x)
    } else if (!shape.points.isEmpty) {
        return shape.texcoords[shape.points[element]]
    } else {
        return zero2f
    }
}

func eval_element_tangents(_ scene: scene_data, _ instance: instance_data,
                           _ element: Int) -> (vec3f, vec3f) {
    let shape = scene.shapes[instance.shape]
    if (!shape.triangles.isEmpty && !shape.texcoords.isEmpty) {
        let t = shape.triangles[element]
        let (tu, tv) = triangle_tangents_from_uv(shape.positions[t.x],
                shape.positions[t.y], shape.positions[t.z], shape.texcoords[t.x],
                shape.texcoords[t.y], shape.texcoords[t.z])
        return (transform_direction(instance.frame, tu),
                transform_direction(instance.frame, tv))
    } else if (!shape.quads.isEmpty && !shape.texcoords.isEmpty) {
        let q = shape.quads[element]
        let (tu, tv) = quad_tangents_from_uv(shape.positions[q.x],
                shape.positions[q.y], shape.positions[q.z], shape.positions[q.w],
                shape.texcoords[q.x], shape.texcoords[q.y], shape.texcoords[q.z],
                shape.texcoords[q.w], [0, 0])
        return (transform_direction(instance.frame, tu),
                transform_direction(instance.frame, tv))
    } else {
        return (vec3f(), vec3f())
    }
}

func eval_normalmap(_ scene: scene_data, _ instance: instance_data,
                    _ element: Int, _ uv: vec2f) -> vec3f {
    let shape = scene.shapes[instance.shape]
    let material = scene.materials[instance.material]
    // apply normal mapping
    var normal = eval_normal(scene, instance, element, uv)
    let texcoord = eval_texcoord(scene, instance, element, uv)
    if (material.normal_tex != invalidid &&
            (!shape.triangles.isEmpty || !shape.quads.isEmpty)) {
        let normal_tex = scene.textures[material.normal_tex]
        var normalmap = -1 + 2 * xyz(eval_texture(normal_tex, texcoord, false))
        let (tu, tv) = eval_element_tangents(scene, instance, element)
        var frame = frame3f(tu, tv, normal, [0, 0, 0])
        frame.x = orthonormalize(frame.x, frame.z)
        frame.y = normalize(cross(frame.z, frame.x))
        let flip_v = dot(frame.y, tv) < 0
        normalmap.y *= flip_v ? 1 : -1  // flip vertical axis
        normal = transform_normal(frame, normalmap)
    }
    return normal
}

func eval_shading_position(_ scene: scene_data, _ instance: instance_data,
                           _ element: Int, _ uv: vec2f, _ outgoing: vec3f) -> vec3f {
    let shape = scene.shapes[instance.shape]
    if (!shape.triangles.isEmpty || !shape.quads.isEmpty) {
        return eval_position(scene, instance, element, uv)
    } else if (!shape.lines.isEmpty) {
        return eval_position(scene, instance, element, uv)
    } else if (!shape.points.isEmpty) {
        return eval_position(shape, element, uv)
    } else {
        return [0, 0, 0]
    }
}

func eval_shading_normal(_ scene: scene_data, _ instance: instance_data,
                         _ element: Int, _ uv: vec2f, _ outgoing: vec3f) -> vec3f {
    let shape = scene.shapes[instance.shape]
    let material = scene.materials[instance.material]
    if (!shape.triangles.isEmpty || !shape.quads.isEmpty) {
        var normal = eval_normal(scene, instance, element, uv)
        if (material.normal_tex != invalidid) {
            normal = eval_normalmap(scene, instance, element, uv)
        }
        if (material.type == .refractive) {
            return normal
        }
        return dot(normal, outgoing) >= 0 ? normal : -normal
    } else if (!shape.lines.isEmpty) {
        let normal = eval_normal(scene, instance, element, uv)
        return orthonormalize(outgoing, normal)
    } else if (!shape.points.isEmpty) {
        // HACK: sphere
        if (true) {
            return transform_direction(instance.frame,
                    vec3f(cos(2 * Float.pi * uv.x) * sin(Float.pi * uv.y),
                            sin(2 * Float.pi * uv.x) * sin(Float.pi * uv.y), cos(Float.pi * uv.y)))
        } else {

        }
    } else {
        return [0, 0, 0]
    }
}

func eval_color(_ scene: scene_data, _ instance: instance_data,
                _ element: Int, _ uv: vec2f) -> vec4f {
    let shape = scene.shapes[instance.shape]
    if (shape.colors.isEmpty) {
        return [1, 1, 1, 1]
    }
    if (!shape.triangles.isEmpty) {
        let t = shape.triangles[element]
        return interpolate_triangle(
                shape.colors[t.x], shape.colors[t.y], shape.colors[t.z], uv)
    } else if (!shape.quads.isEmpty) {
        let q = shape.quads[element]
        return interpolate_quad(shape.colors[q.x], shape.colors[q.y],
                shape.colors[q.z], shape.colors[q.w], uv)
    } else if (!shape.lines.isEmpty) {
        let l = shape.lines[element]
        return interpolate_line(shape.colors[l.x], shape.colors[l.y], uv.x)
    } else if (!shape.points.isEmpty) {
        return shape.colors[shape.points[element]]
    } else {
        return [0, 0, 0, 0]
    }
}

// Eval material to obtain emission, brdf and opacity.
func eval_material(_ scene: scene_data, _ instance: instance_data,
                   _ element: Int, _ uv: vec2f) -> material_point {
    let material = scene.materials[instance.material]
    let texcoord = eval_texcoord(scene, instance, element, uv)

    // evaluate textures
    let emission_tex = eval_texture(
            scene, material.emission_tex, texcoord, true)
    let color_shp = eval_color(scene, instance, element, uv)
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
    } else if (material.type == .volumetric) {
        point.roughness = 0
    } else {
        if (point.roughness < min_roughness) {
            point.roughness = 0
        }
    }

    return point
}

// check if a material has a volume
func is_volumetric(_ scene: scene_data, _ instance: instance_data) -> Bool {
    is_volumetric(scene.materials[instance.material])
}
