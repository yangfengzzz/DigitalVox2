//
//  shape.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// -----------------------------------------------------------------------------
// EXAMPLE SHAPES
// -----------------------------------------------------------------------------

// Make a plane.
func make_rect(steps: vec2i = [1, 1], scale: vec2f = [1, 1],
               uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_bulged_rect(steps: vec2i = [1, 1],
                      scale: vec2f = [1, 1], uvscale: vec2f = [1, 1],
                      radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a plane in the xz plane.
func make_recty(steps: vec2i = [1, 1], scale: vec2f = [1, 1],
                uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_bulged_recty(steps: vec2i = [1, 1],
                       scale: vec2f = [1, 1], uvscale: vec2f = [1, 1],
                       radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a box.
func make_box(steps: vec3i = [1, 1, 1],
              scale: vec3f = [1, 1, 1], uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

func make_rounded_box(steps: vec3i = [1, 1, 1],
                      scale: vec3f = [1, 1, 1], uvscale: vec3f = [1, 1, 1],
                      radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a quad stack
func make_rect_stack(steps: vec3i = [1, 1, 1],
                     scale: vec3f = [1, 1, 1], uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a floor.
func make_floor(steps: vec2i = [1, 1],
                scale: vec2f = [10, 10], uvscale: vec2f = [10, 10]) -> shape_data {
    fatalError()
}

func make_bent_floor(steps: vec2i = [1, 1],
                     scale: vec2f = [10, 10], uvscale: vec2f = [10, 10],
                     bent: Float = 0.5) -> shape_data {
    fatalError()
}

// Make a sphere.
func make_sphere(steps: Int = 32, scale: Float = 1, uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Make a sphere.
func make_uvsphere(steps: vec2i = [32, 32], scale: Float = 1,
                   uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_uvspherey(steps: vec2i = [32, 32], scale: Float = 1,
                    uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a sphere with slipped caps.
func make_capped_uvsphere(steps: vec2i = [32, 32], scale: Float = 1,
                          uvscale: vec2f = [1, 1], height: Float = 0.3) -> shape_data {
    fatalError()
}

func make_capped_uvspherey(steps: vec2i = [32, 32], scale: Float = 1,
                           uvscale: vec2f = [1, 1], height: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a disk
func make_disk(steps: Int = 32, scale: Float = 1, uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Make a bulged disk
func make_bulged_disk(
        steps: Int = 32, scale: Float = 1, uvscale: Float = 1, height: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a uv disk
func make_uvdisk(steps: vec2i = [32, 32], scale: Float = 1,
                 uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a uv cylinder
func make_uvcylinder(steps: vec3i = [32, 32, 32],
                     scale: vec2f = [1, 1], uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

// Make a rounded uv cylinder
func make_rounded_uvcylinder(steps: vec3i = [32, 32, 32],
                             scale: vec2f = [1, 1], uvscale: vec3f = [1, 1, 1],
                             radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a facevarying rect
func make_fvrect(steps: vec2i = [1, 1],
                 scale: vec2f = [1, 1], uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a facevarying box
func make_fvbox(steps: vec3i = [1, 1, 1],
                scale: vec3f = [1, 1, 1], uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

// Make a facevarying sphere
func make_fvsphere(steps: Int = 32, scale: Float = 1, uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Generate lines set along a quad. Returns lines, pos, norm, texcoord, radius.
func make_lines(steps: vec2i = [4, 65536],
                scale: vec2f = [1, 1], uvscale: vec2f = [1, 1],
                radius: vec2f = [0.001, 0.001]) -> shape_data {
    fatalError()
}

// Make a point primitive. Returns points, pos, norm, texcoord, radius.
func make_point(radius: Float = 0.001) -> shape_data {
    fatalError()
}

// Make a point set on a grid. Returns points, pos, norm, texcoord, radius.
func make_points(
        num: Int = 65536, uvscale: Float = 1, radius: Float = 0.001) -> shape_data {
    fatalError()
}

func make_points(steps: vec2i = [256, 256],
                 size: vec2f = [1, 1], uvscale: vec2f = [1, 1],
                 radius: vec2f = [0.001, 0.001]) -> shape_data {
    fatalError()
}

// Make random points in a cube. Returns points, pos, norm, texcoord, radius.
func make_random_points(num: Int = 65536, size: vec3f = [1, 1, 1],
                        uvscale: Float = 1, radius: Float = 0.001, seed: UInt64 = 17) -> shape_data {
    fatalError()
}

// Predefined meshes
func make_monkey(scale: Float = 1, subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quad(scale: Float = 1, subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quady(scale: Float = 1, subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_cube(scale: Float = 1, subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_fvcube(scale: Float = 1, subdivisions: Int = 0) -> fvshape_data {
    fatalError()
}

func make_geosphere(scale: Float = 1, subdivisions: Int = 0) -> shape_data {
    fatalError()
}

// Make a hair ball around a shape.
// length: minimum and maximum length
// rad: minimum and maximum radius from base to tip
// noise: noise added to hair (strength/scale)
// clump: clump added to hair (strength/number)
// rotation: rotation added to hair (angle/strength)
func make_hair(shape: shape_data, steps: vec2i = [8, 65536],
               length: vec2f = [0.1, 0.1], radius: vec2f = [0.001, 0.001],
               noise: vec2f = [0, 10], clump: vec2f = [0, 128],
               rotation: vec2f = [0, 0], seed: Int = 7) -> shape_data {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(shape: shape_data, steps: vec2i = [8, 65536],
                length: vec2f = [0.1, 0.1], radius: vec2f = [0.001, 0.001],
                noise: Float = 0, gravity: Float = 0.001, seed: Int = 7) -> shape_data {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res.
func points_to_spheres(
        vertices: [vec3f], steps: Int = 2, scale: Float = 0.01) -> shape_data {
    fatalError()
}

func polyline_to_cylinders(
        vertices: [vec3f], steps: Int = 4, scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(
        vertices: [vec3f], steps: Int = 4, scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(lines: [vec2i], positions: [vec3f], steps: Int = 4, scale: Float = 0.01) -> shape_data {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(size: vec2i, height: [Float]) -> shape_data {
    fatalError()
}

func make_heightfield(size: vec2i, color: [vec4f]) -> shape_data {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF PER_VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Compute per-vertex normals/tangents for lines/triangles/quads.
func lines_tangents(lines: [vec2i], positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func triangles_normals(triangles: [vec3i], positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func quads_normals(quads: [vec4i], positions: [vec3f]) -> [vec3f] {
    fatalError()
}

// Update normals and tangents
func lines_tangents(tangents: inout [vec3f], lines: [vec2i], positions: [vec3f]) {
    fatalError()
}

func triangles_normals(normals: inout [vec3f], triangles: [vec3i], positions: [vec3f]) {
    fatalError()
}

func quads_normals(normals: inout [vec3f], quads: [vec4i], positions: [vec3f]) {
    fatalError()
}

// Compute per-vertex tangent space for triangle meshes.
// Tangent space is defined by a four component vector.
// The first three components are the tangent with respect to the u texcoord.
// The fourth component is the sign of the tangent wrt the v texcoord.
// Tangent frame is useful in normal mapping.
func triangle_tangent_spaces(triangles: [vec3i], positions: [vec3f], normals: [vec3f], texcoords: [vec2f]) -> [vec4f] {
    fatalError()
}

// Apply skinning to vertex position and normals.
func skin_vertices(positions: [vec3f], normals: [vec3f], weights: [vec4f], joints: [vec4i], xforms: [frame3f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Apply skinning as specified in Khronos glTF.
func skin_matrices(positions: [vec3f], normals: [vec3f], weights: [vec4f], joints: [vec4i], xforms: [mat4f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Update skinning
func skin_vertices(skinned_positions: inout [vec3f], skinned_normals: inout [vec3f], positions: [vec3f],
                   normals: [vec3f], weights: [vec4f],
                   joints: [vec4i], xforms: [frame3f]) {
    fatalError()
}

func skin_matrices(skinned_positions: inout [vec3f],
                   skinned_normals: inout [vec3f], positions: [vec3f],
                   normals: [vec3f], weights: [vec4f],
                   joints: [vec4i], xforms: [mat4f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Flip vertex normals
func flip_normals(normals: [vec3f]) -> [vec3f] {
    fatalError()
}

// Flip face orientation
func flip_triangles(triangles: [vec3i]) -> [vec3i] {
    fatalError()
}

func flip_quads(quads: [vec4i]) -> [vec4i] {
    fatalError()
}

// Align vertex positions. Alignment is 0: none, 1: min, 2: max, 3: center.
func align_vertices(positions: [vec3f], alignment: vec3i) -> [vec3f] {
    fatalError()
}
