//
//  geometry.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// -----------------------------------------------------------------------------
// TRANSFORMS
// -----------------------------------------------------------------------------

// Transforms rays.
@inlinable
func transform_ray(a: mat4f, b: ray3f) -> ray3f {
    fatalError()
}

@inlinable
func transform_ray(a: frame3f, b: ray3f) -> ray3f {
    fatalError()
}

// Transforms bounding boxes by matrices.
@inlinable
func transform_bbox(a: mat4f, b: bbox3f) -> bbox3f {
    fatalError()
}

@inlinable
func transform_bbox(a: frame3f, b: bbox3f) -> bbox3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// PRIMITIVE BOUNDS
// -----------------------------------------------------------------------------
// Primitive bounds.
@inlinable
func point_bounds(p: vec3f) -> bbox3f {
    fatalError()
}

@inlinable
func point_bounds(p: vec3f, r: Float) -> bbox3f {
    fatalError()
}

@inlinable
func line_bounds(p0: vec3f, p1: vec3f) -> bbox3f {
    fatalError()
}

@inlinable
func line_bounds(p0: vec3f, p1: vec3f, r0: Float, r1: Float) -> bbox3f {
    fatalError()
}

@inlinable
func triangle_bounds(p0: vec3f, p1: vec3f, p2: vec3f) -> bbox3f {
    fatalError()
}

@inlinable
func quad_bounds(p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f) -> bbox3f {
    fatalError()
}

@inlinable
func sphere_bounds(p: vec3f, r: Float) -> bbox3f {
    fatalError()
}

@inlinable
func capsule_bounds(p0: vec3f, p1: vec3f, r0: Float, r1: Float) -> bbox3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// GEOMETRY UTILITIES
// -----------------------------------------------------------------------------
// Line properties.
@inlinable
func line_point(p0: vec3f, p1: vec3f, u: Float) -> vec3f {
    fatalError()
}

@inlinable
func line_tangent(p0: vec3f, p1: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func line_length(p0: vec3f, p1: vec3f) -> Float {
    fatalError()
}

// Triangle properties.
@inlinable
func triangle_point(p0: vec3f, p1: vec3f, p2: vec3f, uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func triangle_normal(p0: vec3f, p1: vec3f, p2: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func triangle_area(p0: vec3f, p1: vec3f, p2: vec3f) -> Float {
    fatalError()
}

// Quad properties.
@inlinable
func quad_point(p0: vec3f, p1: vec3f, p2: vec3f, uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func quad_normal(p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f) -> vec3f {
    fatalError()
}

@inlinable
func quad_area(p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f) -> Float {
    fatalError()
}

// Triangle tangent and bitangent from uv
@inlinable
func triangle_tangents_from_uv(p0: vec3f, p1: vec3f, p2: vec3f, uv0: vec2f, uv1: vec2f, uv2: vec2f) -> (vec3f, vec3f) {
    fatalError()
}

// Quad tangent and bitangent from uv. Note that we pass a current_uv since
// internally we may want to split the quad in two and we need to known where
// to do it. If not interested in the split, just pass zero2f here.
@inlinable
func quad_tangents_from_uv(p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f,
                           uv0: vec2f, uv1: vec2f, uv2: vec2f, uv3: vec2f, current_uv: vec2f) -> (vec3f, vec3f) {
    fatalError()
}

// Interpolates values over a line parameterized from a to b by u. Same as lerp.
@inlinable
func interpolate_line<T>(p0: T, p1: T, u: Float) -> T {
    fatalError()
}

// Interpolates values over a triangle parameterized by u and v along the
// (p1-p0) and (p2-p0) directions. Same as barycentric interpolation.
@inlinable
func interpolate_triangle<T>(p0: T, p1: T, p2: T, uv: vec2f) -> T {
    fatalError()
}

// Interpolates values over a quad parameterized by u and v along the
// (p1-p0) and (p2-p1) directions. Same as bilinear interpolation.
@inlinable
func interpolate_quad<T>(p0: T, p1: T, p2: T, p3: T, uv: vec2f) -> T {
    fatalError()
}

// Interpolates values along a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier<T>(p0: T, p1: T, p2: T, p3: T, u: Float) -> T {
    fatalError()
}

// Computes the derivative of a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier_derivative<T>(p0: T, p1: T, p2: T, p3: T, u: Float) -> T {
    fatalError()
}

// Interpolated line properties.
@inlinable
func line_tangent(t0: vec3f, t1: vec3f, u: Float) -> vec3f {
    fatalError()
}

// Interpolated triangle properties.
@inlinable
func triangle_normal(n0: vec3f, n1: vec3f, n2: vec3f, uv: vec2f) -> vec3f {
    fatalError()
}

// Interpolated quad properties.
@inlinable
func quad_point(p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f, uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func quad_normal(n0: vec3f, n1: vec3f, n2: vec3f, n3: vec3f, uv: vec2f) -> vec3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// USER INTERFACE UTILITIES
// -----------------------------------------------------------------------------
// Generate a ray from a camera
@inlinable
func camera_ray(frame: frame3f, lens: Float, film: vec2f, image_uv: vec2f) -> ray3f {
    fatalError()
}

// Generate a ray from a camera
@inlinable
func camera_ray(frame: frame3f, lens: Float, aspect: Float, film: Float, image_uv: vec2f) -> ray3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// RAY-PRIMITIVE INTERSECTION FUNCTIONS
// -----------------------------------------------------------------------------
// Intersect a ray with a point (approximate)
@inlinable
func intersect_point(ray: ray3f, p: vec3f, r: Float, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a line
@inlinable
func intersect_line(ray: ray3f, p0: vec3f, p1: vec3f, r0: Float, r1: Float, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a triangle
@inlinable
func intersect_triangle(ray: ray3f, p0: vec3f, p1: vec3f, p2: vec3f, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a quad.
@inlinable
func intersect_quad(ray: ray3f, p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(ray: ray3f, bbox: bbox3f) -> Bool {
    fatalError()
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(ray: ray3f, ray_dinv: vec3f, bbox: bbox3f) -> Bool {
    fatalError()
}

// -----------------------------------------------------------------------------
// POINT-PRIMITIVE DISTANCE FUNCTIONS
// -----------------------------------------------------------------------------
// Check if a point overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_point(pos: vec3f, dist_max: Float, p: vec3f,
                   r: Float, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Compute the closest line uv to a give position pos.
@inlinable
func closest_uv_line(pos: vec3f, p0: vec3f, p1: vec3f) -> Float {
    fatalError()
}

// Check if a line overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_line(pos: vec3f, dist_max: Float, p0: vec3f, p1: vec3f,
                  r0: Float, r1: Float, uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Compute the closest triangle uv to a give position pos.
@inlinable
func closest_uv_triangle(pos: vec3f, p0: vec3f, p1: vec3f, p2: vec3f) -> vec2f {
    fatalError()
}

// Check if a triangle overlaps a position pos within a maximum distance
// dist_max.
@inlinable
func overlap_triangle(pos: vec3f, dist_max: Float, p0: vec3f, p1: vec3f, p2: vec3f,
                      r0: Float, r1: Float, r2: Float,
                      uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Check if a quad overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_quad(pos: vec3f, dist_max: Float, p0: vec3f, p1: vec3f, p2: vec3f, p3: vec3f,
                  r0: Float, r1: Float, r2: Float, r3: Float,
                  uv: inout vec2f, dist: inout Float) -> Bool {
    fatalError()
}

// Check if a bbox overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_bbox(pos: vec3f, dist_max: Float, bbox: bbox3f) -> Bool {
    fatalError()
}

// Check if two bbox overlap.
@inlinable
func overlap_bbox(bbox1: bbox3f, bbox2: bbox3f) -> Bool {
    fatalError()
}
