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
func make_rect(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
               _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_bulged_rect(_ steps: vec2i = [1, 1],
                      _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                      _ radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a plane in the xz plane.
func make_recty(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
                _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_bulged_recty(_ steps: vec2i = [1, 1],
                       _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                       _ radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a box.
func make_box(_ steps: vec3i = [1, 1, 1],
              _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

func make_rounded_box(_ steps: vec3i = [1, 1, 1],
                      _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1],
                      _ radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a quad stack
func make_rect_stack(_ steps: vec3i = [1, 1, 1],
                     _ scale: vec3f = [1, 1, 1], _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a floor.
func make_floor(_ steps: vec2i = [1, 1],
                _ scale: vec2f = [10, 10], _ uvscale: vec2f = [10, 10]) -> shape_data {
    fatalError()
}

func make_bent_floor(_ steps: vec2i = [1, 1],
                     _ scale: vec2f = [10, 10], _ uvscale: vec2f = [10, 10],
                     _ bent: Float = 0.5) -> shape_data {
    fatalError()
}

// Make a sphere.
func make_sphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Make a sphere.
func make_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                   _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

func make_uvspherey(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                    _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a sphere with slipped caps.
func make_capped_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                          _ uvscale: vec2f = [1, 1], _ height: Float = 0.3) -> shape_data {
    fatalError()
}

func make_capped_uvspherey(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                           _ uvscale: vec2f = [1, 1], _ height: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a disk
func make_disk(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Make a bulged disk
func make_bulged_disk(
        _ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1, _ height: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a uv disk
func make_uvdisk(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                 _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a uv cylinder
func make_uvcylinder(_ steps: vec3i = [32, 32, 32],
                     _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

// Make a rounded uv cylinder
func make_rounded_uvcylinder(_ steps: vec3i = [32, 32, 32],
                             _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1],
                             _ radius: Float = 0.3) -> shape_data {
    fatalError()
}

// Make a facevarying rect
func make_fvrect(_ steps: vec2i = [1, 1],
                 _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1]) -> shape_data {
    fatalError()
}

// Make a facevarying box
func make_fvbox(_ steps: vec3i = [1, 1, 1],
                _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    fatalError()
}

// Make a facevarying sphere
func make_fvsphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    fatalError()
}

// Generate lines set along a quad. Returns lines, pos, norm, texcoord, radius.
func make_lines(_ steps: vec2i = [4, 65536],
                _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                _ radius: vec2f = [0.001, 0.001]) -> shape_data {
    fatalError()
}

// Make a point primitive. Returns points, pos, norm, texcoord, radius.
func make_point(_ radius: Float = 0.001) -> shape_data {
    fatalError()
}

// Make a point set on a grid. Returns points, pos, norm, texcoord, radius.
func make_points(_ num: Int = 65536, _ uvscale: Float = 1, _ radius: Float = 0.001) -> shape_data {
    fatalError()
}

func make_points(_ steps: vec2i = [256, 256],
                 _ size: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                 _ radius: vec2f = [0.001, 0.001]) -> shape_data {
    fatalError()
}

// Make random points in a cube. Returns points, pos, norm, texcoord, radius.
func make_random_points(_ num: Int = 65536, _ size: vec3f = [1, 1, 1],
                        _ uvscale: Float = 1, _ radius: Float = 0.001, _ seed: UInt64 = 17) -> shape_data {
    fatalError()
}

// Predefined meshes
func make_monkey(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quad(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quady(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_cube(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_fvcube(_ scale: Float = 1, _ subdivisions: Int = 0) -> fvshape_data {
    fatalError()
}

func make_geosphere(_ scale: Float = 1, _  subdivisions: Int = 0) -> shape_data {
    fatalError()
}

// Make a hair ball around a shape.
// length: minimum and maximum length
// rad: minimum and maximum radius from base to tip
// noise: noise added to hair (strength/scale)
// clump: clump added to hair (strength/number)
// rotation: rotation added to hair (angle/strength)
func make_hair(_ shape: shape_data, _ steps: vec2i = [8, 65536],
               _ length: vec2f = [0.1, 0.1], _ radius: vec2f = [0.001, 0.001],
               _ noise: vec2f = [0, 10], _ clump: vec2f = [0, 128],
               _ rotation: vec2f = [0, 0], _ seed: Int = 7) -> shape_data {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(_ shape: shape_data, _  steps: vec2i = [8, 65536],
                _ length: vec2f = [0.1, 0.1], _ radius: vec2f = [0.001, 0.001],
                _ noise: Float = 0, _ gravity: Float = 0.001, _ seed: Int = 7) -> shape_data {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res.
func points_to_spheres(_ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func polyline_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(_ lines: [vec2i], _ positions: [vec3f],
                        _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(_ size: vec2i, _ height: [Float]) -> shape_data {
    fatalError()
}

func make_heightfield(_ size: vec2i, _ color: [vec4f]) -> shape_data {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF PER_VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Compute per-vertex normals/tangents for lines/triangles/quads.
func lines_tangents(_ lines: [vec2i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func triangles_normals(_ triangles: [vec3i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func quads_normals(_ quads: [vec4i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

// Update normals and tangents
func lines_tangents(_ tangents: inout [vec3f], _ lines: [vec2i], _ positions: [vec3f]) {
    fatalError()
}

func triangles_normals(_ normals: inout [vec3f], _ triangles: [vec3i], _ positions: [vec3f]) {
    fatalError()
}

func quads_normals(_ normals: inout [vec3f], _ quads: [vec4i], _ positions: [vec3f]) {
    fatalError()
}

// Compute per-vertex tangent space for triangle meshes.
// Tangent space is defined by a four component vector.
// The first three components are the tangent with respect to the u texcoord.
// The fourth component is the sign of the tangent wrt the v texcoord.
// Tangent frame is useful in normal mapping.
func triangle_tangent_spaces(_ triangles: [vec3i], _ positions: [vec3f],
                             _ normals: [vec3f], _ texcoords: [vec2f]) -> [vec4f] {
    fatalError()
}

// Apply skinning to vertex position and normals.
func skin_vertices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Apply skinning as specified in Khronos glTF.
func skin_matrices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Update skinning
func skin_vertices(_ skinned_positions: inout [vec3f], _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) {
    fatalError()
}

func skin_matrices(_ skinned_positions: inout [vec3f],
                   _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Flip vertex normals
func flip_normals(_ normals: [vec3f]) -> [vec3f] {
    fatalError()
}

// Flip face orientation
func flip_triangles(_ triangles: [vec3i]) -> [vec3i] {
    fatalError()
}

func flip_quads(_ quads: [vec4i]) -> [vec4i] {
    fatalError()
}

// Align vertex positions. Alignment is 0: none, 1: min, 2: max, 3: center.
func align_vertices(_ positions: [vec3f], _ alignment: vec3i) -> [vec3f] {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE ELEMENT CONVERSION AND GROUPING
// -----------------------------------------------------------------------------
// Convert quads to triangles
func quads_to_triangles(_ quads: [vec4i]) -> [vec3i] {
    fatalError()
}

// Convert triangles to quads by creating degenerate quads
func triangles_to_quads(_ triangles: [vec3i]) -> [vec4i] {
    fatalError()
}

// Convert beziers to lines using 3 lines for each bezier.
func bezier_to_lines(_ lines: [vec2i]) -> [vec4i] {
    fatalError()
}

// Convert face-varying data to single primitives. Returns the quads indices
// and filled vectors for pos, norm and texcoord.
func split_facevarying(_ split_quads: inout [vec4i], _ split_positions: inout [vec3f], _ split_normals: inout [vec3f],
                       _ split_texcoords: inout [vec2f], _ quadspos: [vec4i],
                       _ quadsnorm: [vec4i], _ quadstexcoord: [vec4i],
                       _ positions: [vec3f], _ normals: [vec3f],
                       _ texcoords: [vec2f]) {
    fatalError()
}

// Weld vertices within a threshold.
func weld_vertices(_ positions: [vec3f], _ threshold: Float) -> ([vec3f], [Int]) {
    fatalError()
}

func weld_triangles(_ triangles: [vec3i], _ positions: [vec3f], _ threshold: Float) -> ([vec3i], [vec3f]) {
    fatalError()
}

func weld_quads(_ quads: [vec4i], _ positions: [vec3f], _ threshold: Float) -> ([vec4i], [vec3f]) {
    fatalError()
}

// Merge shape elements
func merge_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                 _ tangents: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ merge_lines: [vec2i], _ merge_positions: [vec3f],
                 _ merge_tangents: [vec3f],
                 _ merge_texturecoords: [vec2f],
                 _ merge_radius: [Float]) {
    fatalError()
}

func merge_triangles(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout[vec2f],
                     _ merge_triangles: [vec2i], _ merge_positions: [vec3f],
                     _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    fatalError()
}

func merge_quads(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                 _ merge_quads: [vec4i], _ merge_positions: [vec3f],
                 _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SUBDIVISION
// -----------------------------------------------------------------------------
// Subdivide lines by splitting each line in half.
func subdivide_lines(_ lines: [vec2i], _ vertex: [Float]) -> ([vec2i], [Float]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec2f]) -> ([vec2i], [vec2f]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec3f]) -> ([vec2i], [vec3f]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec4f]) -> ([vec2i], [vec4f]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
func subdivide_triangles(_ triangles: [vec3i], _ vertex: [Float]) -> ([vec3i], [Float]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec2f]) -> ([vec3i], [vec2f]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec3f]) -> ([vec3i], [vec3f]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec4f]) -> ([vec3i], [vec4f]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
func subdivide_quads(_ quads: [vec4i], _ vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
func subdivide_beziers(_ beziers: [vec4i], _ vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide quads using Catmull-Clark subdivision rules.
func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [Float],
                            _ lock_boundary: Bool = false) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec2f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec3f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec4f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide lines by splitting each line in half.
@inlinable func subdivide_lines<T>(_ lines: [vec2i], _ vertices: [T], _ level: Int) -> ([vec2i], [T]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
@inlinable func subdivide_triangles<T>(_ triangles: [vec3i], _ vertices: [T], _ level: Int) -> ([vec3i], [T]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
@inlinable func subdivide_quads<T>(_ quads: [vec4i], _ vertices: [T], _ level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
@inlinable func subdivide_beziers<T>(_ beziers: [vec4i], _ vertices: [T], _ level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide quads using Carmull-Clark subdivision rules.
@inlinable func subdivide_catmullclark<T>(_ quads: [vec4i], _ vertices: [T], _ level: Int,
                                          _ lock_boundary: Bool = false) -> ([vec4i], [T]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SAMPLING
// -----------------------------------------------------------------------------
// Pick a point in a point set uniformly.
func sample_points(_ npoints: Int, _ re: Float) -> Int {
    fatalError()
}

func sample_points(_ cdf: [Float], _ re: Float) -> Int {
    fatalError()
}

func sample_points_cdf(_ npoints: Int) -> [Float] {
    fatalError()
}

func sample_points_cdf(_ cdf: inout [Float], _ npoints: Int) {
    fatalError()
}

// Pick a point on lines uniformly.
func sample_lines(_ cdf: [Float], _ re: Float, _ ru: Float) -> (Int, Float) {
    fatalError()
}

func sample_lines_cdf(_ lines: [vec2i], _ positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_lines_cdf(_ cdf: inout [Float], _ lines: [vec2i], _ positions: [vec3f]) {
    fatalError()
}

// Pick a point on a triangle mesh uniformly.
func sample_triangles(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_triangles_cdf(_ triangles: [vec3i], _  positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_triangles_cdf(_ cdf: inout [Float], _ triangles: [vec3i], _ positions: [vec3f]) {
    fatalError()
}

// Pick a point on a quad mesh uniformly.
func sample_quads(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_quads_cdf(_ quads: [vec4i], _ positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_quads_cdf(_ cdf: inout [Float], _ quads: [vec4i], _ positions: [vec3f]) {
    fatalError()
}

// Samples a set of points over a triangle/quad mesh uniformly. Returns pos,
// norm and texcoord of the sampled points.
func sample_triangles(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                      _ triangles: [vec3i], _ positions: [vec3f], _ normals: [vec3f],
                      _ texcoords: [vec2f], _ npoints: Int, _ seed: Int = 7) {
    fatalError()
}

func sample_quads(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                  _ quads: [vec4i], _ positions: [vec3f], _ normals: [vec3f],
                  _ texcoords: [vec2f], _ npoints: Int, _ seed: Int = 7) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE EXAMPLES
// -----------------------------------------------------------------------------
// Make a quad.
func make_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
               _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bulged_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                      _ scale: vec2f, _ uvscale: vec2f, _ height: Float) {
    fatalError()
}

// Make a quad.
func make_recty(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bulged_recty(_ quads: inout [vec4i], _ positions: inout [vec3f],
                       _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                       _ scale: vec2f, _ uvscale: vec2f, _ height: Float) {
    fatalError()
}

// Make a cube.
func make_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
              _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
              _ scale: vec3f, uvscale: vec3f) {
    fatalError()
}

func make_rounded_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                      _ scale: vec3f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}

func make_rect_stack(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec3f, _ uvscale: vec2f) {
    fatalError()
}

func make_floor(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bent_floor(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                     _ scale: vec2f, _ uvscale: vec2f, _ radius: Float) {
    fatalError()
}

// Generate a sphere
func make_sphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                 _ uvscale: Float) {
    fatalError()
}

// Generate a uvsphere
func make_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                   _ scale: Float, uvscale: vec2f) {
    fatalError()
}

func make_capped_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                          _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                          _ scale: Float, uvscale: vec2f, cap: Float) {
    fatalError()
}

func make_uvspherey(_ quads: inout [vec4i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                    _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}

func make_capped_uvspherey(_ quads: inout [vec4i], _ positions: inout [vec3f],
                           _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                           _ scale: Float, _ uvscale: vec2f, _ cap: Float) {
    fatalError()
}

// Generate a disk
func make_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
               _ uvscale: Float) {
    fatalError()
}

func make_bulged_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                      _ uvscale: Float, _ height: Float) {
    fatalError()
}

// Generate a uvdisk
func make_uvdisk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}

// Generate a uvcylinder
func make_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec2f, _ uvscale: vec3f) {
    fatalError()
}

// Generate a uvcylinder
func make_rounded_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                             _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                             _ scale: vec2f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}

// Generate lines set along a quad.
func make_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                _ rad: vec2f) {
    fatalError()
}

// Generate a point at the origin.
func make_point(_ points: inout [Int], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ point_radius: Float) {
    fatalError()
}

// Generate a point set with points placed at the origin with texcoords
// varying along u.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ num: Int, _ uvscale: Float, _ point_radius: Float) {
    fatalError()
}

// Generate a point set along a quad.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                 _ rad: vec2f) {
    fatalError()
}

// Generate a point set.
func make_random_points(_ points: inout [Int], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                        _ num: Int, size: vec3f, _ uvscale: Float, _ point_radius: Float,
                        _ seed: UInt64) {
    fatalError()
}

// Make a bezier circle. Returns bezier, pos.
func make_bezier_circle(_ beziers: inout [vec4i], _ positions: inout [vec3f], _ size: Float) {
    fatalError()
}

// Make fvquad
func make_fvrect(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ size: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_fvbox(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                _ size: vec3f, _ uvscale: vec3f) {
    fatalError()
}

func make_fvsphere(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                   _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ size: Float,
                   _ uvscale: Float) {
    fatalError()
}

// Predefined meshes
func make_monkey(_ quads: inout [vec4i], _ positions: inout [vec3f], _ scale: Float,
                 _ subdivisions: Int) {
    fatalError()
}

func make_quad(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}

func make_quady(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
                _ subdivisions: Int) {
    fatalError()
}

func make_cube(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}

func make_fvcube(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
                 _ subdivisions: Int) {
    fatalError()
}

func make_geosphere(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ scale: Float, _ subdivisions: Int) {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res and without texcoords and normals.
func points_to_spheres(_ quads: inout [vec4i], _ positions: inout [vec3f],
                       _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                       _ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) {
    fatalError()
}

func polyline_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                           _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                           _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ lines: [vec2i], _ vertices: [vec3f], _ steps: Int = 4,
                        _ scale: Float = 0.01) {
    fatalError()
}

// Make a hair ball around a shape
func make_hair(_ lines: inout [vec2i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
               _ striangles: [vec3i], _ squads: [vec4i],
               _ spos: [vec3f], _ snorm: [vec3f],
               _ stexcoord: [vec2f], _ steps: vec2i, _  len: vec2f,
               _ rad: vec2f, _ noise: vec2f, _ clump: vec2f,
               _ rotation: vec2f, _ seed: Int) {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(_ lines: inout [vec2i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ striangles: [vec3i], _ squads: [vec4i],
                _ spos: [vec3f], _  snorm: [vec3f],
                _ stexcoord: [vec2f], _  steps: vec2i, _  len: vec2f,
                _ rad: vec2f, _  noise: Float, _  gravity: Float, _  seed: Int) {
    fatalError()
}

// Thickens a shape by copy9ing the shape content, rescaling it and flipping
// its normals. Note that this is very much not robust and only useful for
// trivial cases.
func make_shell(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ thickness: Float) {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ height: [Float]) {
    fatalError()
}

func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ color: [vec4f]) {
    fatalError()
}
