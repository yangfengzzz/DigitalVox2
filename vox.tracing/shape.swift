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

func lines_to_cylinders(lines: [vec2i], positions: [vec3f],
                        steps: Int = 4, scale: Float = 0.01) -> shape_data {
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
func triangle_tangent_spaces(triangles: [vec3i], positions: [vec3f],
                             normals: [vec3f], texcoords: [vec2f]) -> [vec4f] {
    fatalError()
}

// Apply skinning to vertex position and normals.
func skin_vertices(positions: [vec3f], normals: [vec3f], weights: [vec4f],
                   joints: [vec4i], xforms: [frame3f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Apply skinning as specified in Khronos glTF.
func skin_matrices(positions: [vec3f], normals: [vec3f], weights: [vec4f],
                   joints: [vec4i], xforms: [mat4f]) -> ([vec3f], [vec3f]) {
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

// -----------------------------------------------------------------------------
// SHAPE ELEMENT CONVERSION AND GROUPING
// -----------------------------------------------------------------------------
// Convert quads to triangles
func quads_to_triangles(quads: [vec4i]) -> [vec3i] {
    fatalError()
}

// Convert triangles to quads by creating degenerate quads
func triangles_to_quads(triangles: [vec3i]) -> [vec4i] {
    fatalError()
}

// Convert beziers to lines using 3 lines for each bezier.
func bezier_to_lines(lines: [vec2i]) -> [vec4i] {
    fatalError()
}

// Convert face-varying data to single primitives. Returns the quads indices
// and filled vectors for pos, norm and texcoord.
func split_facevarying(split_quads: inout [vec4i], split_positions: inout [vec3f], split_normals: inout [vec3f],
                       split_texcoords: inout [vec2f], quadspos: [vec4i],
                       quadsnorm: [vec4i], quadstexcoord: [vec4i],
                       positions: [vec3f], normals: [vec3f],
                       texcoords: [vec2f]) {
    fatalError()
}

// Weld vertices within a threshold.
func weld_vertices(positions: [vec3f], threshold: Float) -> ([vec3f], [Int]) {
    fatalError()
}

func weld_triangles(triangles: [vec3i], positions: [vec3f], threshold: Float) -> ([vec3i], [vec3f]) {
    fatalError()
}

func weld_quads(quads: [vec4i], positions: [vec3f], threshold: Float) -> ([vec4i], [vec3f]) {
    fatalError()
}

// Merge shape elements
func merge_lines(lines: inout [vec2i], positions: inout [vec3f],
                 tangents: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                 merge_lines: [vec2i], merge_positions: [vec3f],
                 merge_tangents: [vec3f],
                 merge_texturecoords: [vec2f],
                 merge_radius: [Float]) {
    fatalError()
}

func merge_triangles(triangles: inout [vec3i], positions: inout [vec3f],
                     normals: inout [vec3f], texcoords: inout[vec2f],
                     merge_triangles: [vec2i], merge_positions: [vec3f],
                     merge_normals: [vec3f], merge_texturecoords: [vec2f]) {
    fatalError()
}

func merge_quads(quads: inout [vec4i], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f],
                 merge_quads: [vec4i], merge_positions: [vec3f],
                 merge_normals: [vec3f], merge_texturecoords: [vec2f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SUBDIVISION
// -----------------------------------------------------------------------------
// Subdivide lines by splitting each line in half.
func subdivide_lines(lines: [vec2i], vertex: [Float]) -> ([vec2i], [Float]) {
    fatalError()
}

func subdivide_lines(lines: [vec2i], vertex: [vec2f]) -> ([vec2i], [vec2f]) {
    fatalError()
}

func subdivide_lines(lines: [vec2i], vertex: [vec3f]) -> ([vec2i], [vec3f]) {
    fatalError()
}

func subdivide_lines(lines: [vec2i], vertex: [vec4f]) -> ([vec2i], [vec4f]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
func subdivide_triangles(triangles: [vec3i], vertex: [Float]) -> ([vec3i], [Float]) {
    fatalError()
}

func subdivide_triangles(triangles: [vec3i], vertex: [vec2f]) -> ([vec3i], [vec2f]) {
    fatalError()
}

func subdivide_triangles(triangles: [vec3i], vertex: [vec3f]) -> ([vec3i], [vec3f]) {
    fatalError()
}

func subdivide_triangles(triangles: [vec3i], vertex: [vec4f]) -> ([vec3i], [vec4f]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
func subdivide_quads(quads: [vec4i], vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_quads(quads: [vec4i], vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_quads(quads: [vec4i], vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_quads(quads: [vec4i], vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
func subdivide_beziers(beziers: [vec4i], vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_beziers(beziers: [vec4i], vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_beziers(beziers: [vec4i], vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_beziers(beziers: [vec4i], vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide quads using Catmull-Clark subdivision rules.
func subdivide_catmullclark(quads: [vec4i], vertex: [Float],
                            lock_boundary: Bool = false) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_catmullclark(quads: [vec4i], vertex: [vec2f],
                            lock_boundary: Bool = false) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_catmullclark(quads: [vec4i], vertex: [vec3f],
                            lock_boundary: Bool = false) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_catmullclark(quads: [vec4i], vertex: [vec4f],
                            lock_boundary: Bool = false) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide lines by splitting each line in half.
@inlinable func subdivide_lines<T>(lines: [vec2i], vertices: [T], level: Int) -> ([vec2i], [T]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
@inlinable func subdivide_triangles<T>(triangles: [vec3i], vertices: [T], level: Int) -> ([vec3i], [T]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
@inlinable func subdivide_quads<T>(quads: [vec4i], vertices: [T], level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
@inlinable func subdivide_beziers<T>(beziers: [vec4i], vertices: [T], level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide quads using Carmull-Clark subdivision rules.
@inlinable func subdivide_catmullclark<T>(quads: [vec4i], vertices: [T], level: Int,
                                          lock_boundary: Bool = false) -> ([vec4i], [T]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SAMPLING
// -----------------------------------------------------------------------------
// Pick a point in a point set uniformly.
func sample_points(npoints: Int, re: Float) -> Int {
    fatalError()
}

func sample_points(cdf: [Float], re: Float) -> Int {
    fatalError()
}

func sample_points_cdf(npoints: Int) -> [Float] {
    fatalError()
}

func sample_points_cdf(cdf: inout [Float], npoints: Int) {
    fatalError()
}

// Pick a point on lines uniformly.
func sample_lines(cdf: [Float], re: Float, ru: Float) -> (Int, Float) {
    fatalError()
}

func sample_lines_cdf(lines: [vec2i], positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_lines_cdf(cdf: inout [Float], lines: [vec2i], positions: [vec3f]) {
    fatalError()
}

// Pick a point on a triangle mesh uniformly.
func sample_triangles(cdf: [Float], re: Float, ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_triangles_cdf(triangles: [vec3i], positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_triangles_cdf(cdf: inout [Float], triangles: [vec3i], positions: [vec3f]) {
    fatalError()
}

// Pick a point on a quad mesh uniformly.
func sample_quads(cdf: [Float], re: Float, ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_quads_cdf(quads: [vec4i], positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_quads_cdf(cdf: inout [Float], quads: [vec4i], positions: [vec3f]) {
    fatalError()
}

// Samples a set of points over a triangle/quad mesh uniformly. Returns pos,
// norm and texcoord of the sampled points.
func sample_triangles(sampled_positions: inout [vec3f], sampled_normals: inout [vec3f], sampled_texcoords: inout [vec2f],
                      triangles: [vec3i], positions: [vec3f], normals: [vec3f], texcoords: [vec2f], npoints: Int, seed: Int = 7) {
    fatalError()
}

func sample_quads(sampled_positions: inout [vec3f], sampled_normals: inout [vec3f], sampled_texcoords: inout [vec2f],
                  quads: [vec4i], positions: [vec3f], normals: [vec3f], texcoords: [vec2f], npoints: Int, seed: Int = 7) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE EXAMPLES
// -----------------------------------------------------------------------------
// Make a quad.
func make_rect(quads: inout [vec4i], positions: inout [vec3f],
               normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
               scale: vec2f, uvscale: vec2f) {
    fatalError()
}

func make_bulged_rect(quads: inout [vec4i], positions: inout [vec3f],
                      normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                      scale: vec2f, uvscale: vec2f, height: Float) {
    fatalError()
}

// Make a quad.
func make_recty(quads: inout [vec4i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                scale: vec2f, uvscale: vec2f) {
    fatalError()
}

func make_bulged_recty(quads: inout [vec4i], positions: inout [vec3f],
                       normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                       scale: vec2f, uvscale: vec2f, height: Float) {
    fatalError()
}

// Make a cube.
func make_box(quads: inout [vec4i], positions: inout [vec3f],
              normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
              scale: vec3f, uvscale: vec3f) {
    fatalError()
}

func make_rounded_box(quads: inout [vec4i], positions: inout [vec3f],
                      normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
                      scale: vec3f, uvscale: vec3f, radius: Float) {
    fatalError()
}

func make_rect_stack(quads: inout [vec4i], positions: inout [vec3f],
                     normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
                     scale: vec3f, uvscale: vec2f) {
    fatalError()
}

func make_floor(quads: inout [vec4i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                scale: vec2f, uvscale: vec2f) {
    fatalError()
}

func make_bent_floor(quads: inout [vec4i], positions: inout [vec3f],
                     normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                     scale: vec2f, uvscale: vec2f, radius: Float) {
    fatalError()
}

// Generate a sphere
func make_sphere(quads: inout [vec4i], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], steps: Int, scale: Float,
                 uvscale: Float) {
    fatalError()
}

// Generate a uvsphere
func make_uvsphere(quads: inout [vec4i], positions: inout [vec3f],
                   normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                   scale: Float, uvscale: vec2f) {
    fatalError()
}

func make_capped_uvsphere(quads: inout [vec4i], positions: inout [vec3f],
                          normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                          scale: Float, uvscale: vec2f, cap: Float) {
    fatalError()
}

func make_uvspherey(quads: inout [vec4i], positions: inout [vec3f],
                    normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                    scale: Float, uvscale: vec2f) {
    fatalError()
}

func make_capped_uvspherey(quads: inout [vec4i], positions: inout [vec3f],
                           normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                           scale: Float, uvscale: vec2f, cap: Float) {
    fatalError()
}

// Generate a disk
func make_disk(quads: inout [vec4i], positions: inout [vec3f],
               normals: inout [vec3f], texcoords: inout [vec2f], steps: Int, scale: Float,
               uvscale: Float) {
    fatalError()
}

func make_bulged_disk(quads: inout [vec4i], positions: inout [vec3f],
                      normals: inout [vec3f], texcoords: inout [vec2f], steps: Int, scale: Float,
                      uvscale: Float, height: Float) {
    fatalError()
}

// Generate a uvdisk
func make_uvdisk(quads: inout [vec4i], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                 scale: Float, uvscale: vec2f) {
    fatalError()
}

// Generate a uvcylinder
func make_uvcylinder(quads: inout [vec4i], positions: inout [vec3f],
                     normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
                     scale: vec2f, uvscale: vec3f) {
    fatalError()
}

// Generate a uvcylinder
func make_rounded_uvcylinder(quads: inout [vec4i], positions: inout [vec3f],
                             normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
                             scale: vec2f, uvscale: vec3f, radius: Float) {
    fatalError()
}

// Generate lines set along a quad.
func make_lines(lines: inout [vec2i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                steps: vec2i, size: vec2f, uvscale: vec2f,
                rad: vec2f) {
    fatalError()
}

// Generate a point at the origin.
func make_point(points: inout [Int], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                point_radius: Float) {
    fatalError()
}

// Generate a point set with points placed at the origin with texcoords
// varying along u.
func make_points(points: inout [Int], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                 num: Int, uvscale: Float, point_radius: Float) {
    fatalError()
}

// Generate a point set along a quad.
func make_points(points: inout [Int], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                 steps: vec2i, size: vec2f, uvscale: vec2f,
                 rad: vec2f) {
    fatalError()
}

// Generate a point set.
func make_random_points(points: inout [Int], positions: inout [vec3f],
                        normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                        num: Int, size: vec3f, uvscale: Float, point_radius: Float,
                        seed: UInt64) {
    fatalError()
}

// Make a bezier circle. Returns bezier, pos.
func make_bezier_circle(beziers: inout [vec4i], positions: inout [vec3f], size: Float) {
    fatalError()
}

// Make fvquad
func make_fvrect(quadspos: inout [vec4i], quadsnorm: inout [vec4i],
                 quadstexcoord: inout [vec4i], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], steps: vec2i,
                 size: vec2f, uvscale: vec2f) {
    fatalError()
}

func make_fvbox(quadspos: inout [vec4i], quadsnorm: inout [vec4i],
                quadstexcoord: inout [vec4i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], steps: vec3i,
                size: vec3f, uvscale: vec3f) {
    fatalError()
}

func make_fvsphere(quadspos: inout [vec4i], quadsnorm: inout [vec4i],
                   quadstexcoord: inout [vec4i], positions: inout [vec3f],
                   normals: inout [vec3f], texcoords: inout [vec2f], steps: Int, size: Float,
                   uvscale: Float) {
    fatalError()
}

// Predefined meshes
func make_monkey(quads: inout [vec4i], positions: inout [vec3f], scale: Float,
                 subdivisions: Int) {
    fatalError()
}

func make_quad(quads: inout [vec4i], positions: inout [vec3f],
               normals: inout [vec3f], texcoords: inout [vec2f], scale: Float,
               subdivisions: Int) {
    fatalError()
}

func make_quady(quads: inout [vec4i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], scale: Float,
                subdivisions: Int) {
    fatalError()
}

func make_cube(quads: inout [vec4i], positions: inout [vec3f],
               normals: inout [vec3f], texcoords: inout [vec2f], scale: Float,
               subdivisions: Int) {
    fatalError()
}

func make_fvcube(quadspos: inout [vec4i], quadsnorm: inout [vec4i],
                 quads: inout [vec4i], positions: inout [vec3f],
                 normals: inout [vec3f], texcoords: inout [vec2f], scale: Float,
                 subdivisions: Int) {
    fatalError()
}

func make_geosphere(triangles: inout [vec3i], positions: inout [vec3f],
                    normals: inout [vec3f], scale: Float, subdivisions: Int) {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res and without texcoords and normals.
func points_to_spheres(quads: inout [vec4i], positions: inout [vec3f],
                       normals: inout [vec3f], texcoords: inout [vec2f],
                       vertices: [vec3f], steps: Int = 2, scale: Float = 0.01) {
    fatalError()
}

func polyline_to_cylinders(quads: inout [vec4i], positions: inout [vec3f],
                           normals: inout [vec3f], texcoords: inout [vec2f],
                           vertices: [vec3f], steps: Int = 4, scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(quads: inout [vec4i], positions: inout [vec3f],
                        normals: inout [vec3f], texcoords: inout [vec2f],
                        vertices: [vec3f], steps: Int = 4, scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(quads: inout [vec4i], positions: inout [vec3f],
                        normals: inout [vec3f], texcoords: inout [vec2f],
                        const lines: inout [vec2i], vertices: [vec3f], steps: Int = 4,
                        scale: Float = 0.01) {
    fatalError()
}

// Make a hair ball around a shape
func make_hair(lines: inout [vec2i], positions: inout [vec3f],
               normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
               striangles: [vec3i], squads: [vec4i],
               spos: [vec3f], snorm: [vec3f],
               stexcoord: [vec2f], steps: vec2i, len: vec2f,
               rad: vec2f, noise: vec2f, clump: vec2f,
               rotation: vec2f, seed: Int) {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(lines: inout [vec2i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], radius: inout [Float],
                striangles: [vec3i], squads: [vec4i],
                spos: [vec3f], snorm: [vec3f],
                stexcoord: [vec2f], steps: vec2i, len: vec2f,
                rad: vec2f, noise: Float, gravity: Float, seed: Int) {
    fatalError()
}

// Thickens a shape by copy9ing the shape content, rescaling it and flipping
// its normals. Note that this is very much not robust and only useful for
// trivial cases.
func make_shell(quads: inout [vec4i], positions: inout [vec3f],
                normals: inout [vec3f], texcoords: inout [vec2f], thickness: Float) {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(quads: inout [vec4i], positions: inout [vec3f],
                      normals: inout [vec3f], texcoords: inout [vec2f], size: vec2i,
                      height: [Float]) {
    fatalError()
}

func make_heightfield(quads: inout [vec4i], positions: inout [vec3f],
                      normals: inout [vec3f], texcoords: inout [vec2f], size: vec2i,
                      color: [vec4f]) {
    fatalError()
}
