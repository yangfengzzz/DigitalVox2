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
func transform_ray(_ a: mat4f, _ b: ray3f) -> ray3f {
    ray3f(transform_point(a, b.o), transform_vector(a, b.d), b.tmin, b.tmax)
}

@inlinable
func transform_ray(_ a: frame3f, _ b: ray3f) -> ray3f {
    ray3f(transform_point(a, b.o), transform_vector(a, b.d), b.tmin, b.tmax)
}

// Transforms bounding boxes by matrices.
@inlinable
func transform_bbox(_ a: mat4f, _ b: bbox3f) -> bbox3f {
    let corners = [vec3f(b.min.x, b.min.y, b.min.z), vec3f(b.min.x, b.min.y, b.max.z),
                   vec3f(b.min.x, b.max.y, b.min.z), vec3f(b.min.x, b.max.y, b.max.z),
                   vec3f(b.max.x, b.min.y, b.min.z), vec3f(b.max.x, b.min.y, b.max.z),
                   vec3f(b.max.x, b.max.y, b.min.z), vec3f(b.max.x, b.max.y, b.max.z)]
    var xformed = bbox3f()
    for corner in corners {
        xformed = merge(xformed, transform_point(a, corner))
    }
    return xformed
}

@inlinable
func transform_bbox(_ a: frame3f, _ b: bbox3f) -> bbox3f {
    let corners = [vec3f(b.min.x, b.min.y, b.min.z), vec3f(b.min.x, b.min.y, b.max.z),
                   vec3f(b.min.x, b.max.y, b.min.z), vec3f(b.min.x, b.max.y, b.max.z),
                   vec3f(b.max.x, b.min.y, b.min.z), vec3f(b.max.x, b.min.y, b.max.z),
                   vec3f(b.max.x, b.max.y, b.min.z), vec3f(b.max.x, b.max.y, b.max.z)]
    var xformed = bbox3f()
    for corner in corners {
        xformed = merge(xformed, transform_point(a, corner))
    }
    return xformed
}

// -----------------------------------------------------------------------------
// PRIMITIVE BOUNDS
// -----------------------------------------------------------------------------
// Primitive bounds.
@inlinable
func point_bounds(_ p: vec3f) -> bbox3f {
    bbox3f(p, p)
}

@inlinable
func point_bounds(_ p: vec3f, _ r: Float) -> bbox3f {
    bbox3f(min(p - r, p + r), max(p - r, p + r))
}

@inlinable
func line_bounds(_ p0: vec3f, _ p1: vec3f) -> bbox3f {
    bbox3f(min(p0, p1), max(p0, p1))
}

@inlinable
func line_bounds(_ p0: vec3f, _ p1: vec3f, _ r0: Float, _ r1: Float) -> bbox3f {
    bbox3f(min(p0 - r0, p1 - r1), max(p0 + r0, p1 + r1))
}

@inlinable
func triangle_bounds(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> bbox3f {
    bbox3f(min(p0, min(p1, p2)), max(p0, max(p1, p2)))
}

@inlinable
func quad_bounds(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f) -> bbox3f {
    bbox3f(min(p0, min(p1, min(p2, p3))), max(p0, max(p1, max(p2, p3))))
}

@inlinable
func sphere_bounds(_ p: vec3f, _ r: Float) -> bbox3f {
    bbox3f(p - r, p + r)
}

@inlinable
func capsule_bounds(_ p0: vec3f, _ p1: vec3f, _ r0: Float, _ r1: Float) -> bbox3f {
    bbox3f(min(p0 - r0, p1 - r1), max(p0 + r0, p1 + r1))
}

// -----------------------------------------------------------------------------
// GEOMETRY UTILITIES
// -----------------------------------------------------------------------------
// Line properties.
@inlinable
func line_point(_ p0: vec3f, _ p1: vec3f, _ u: Float) -> vec3f {
    fatalError()
}

@inlinable
func line_tangent(_ p0: vec3f, _ p1: vec3f) -> vec3f {
    normalize(p1 - p0)
}

@inlinable
func line_length(_ p0: vec3f, _ p1: vec3f) -> Float {
    length(p1 - p0)
}

// Triangle properties.
@inlinable
func triangle_point(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func triangle_normal(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> vec3f {
    normalize(cross(p1 - p0, p2 - p0))
}

@inlinable
func triangle_area(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> Float {
    length(cross(p1 - p0, p2 - p0)) / 2
}

// Quad properties.
@inlinable
func quad_point(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func quad_normal(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f) -> vec3f {
    normalize(triangle_normal(p0, p1, p3) + triangle_normal(p2, p3, p1))
}

@inlinable
func quad_area(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f) -> Float {
    triangle_area(p0, p1, p3) + triangle_area(p2, p3, p1)
}

// Triangle tangent and bitangent from uv
@inlinable
func triangle_tangents_from_uv(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f,
                               _ uv0: vec2f, _ uv1: vec2f, _ uv2: vec2f) -> (vec3f, vec3f) {
    fatalError()
}

// Quad tangent and bitangent from uv. Note that we pass a current_uv since
// internally we may want to split the quad in two and we need to known where
// to do it. If not interested in the split, just pass zero2f here.
@inlinable
func quad_tangents_from_uv(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                           _ uv0: vec2f, _ uv1: vec2f, _ uv2: vec2f, _ uv3: vec2f,
                           _ current_uv: vec2f) -> (vec3f, vec3f) {
    fatalError()
}

// Interpolates values over a line parameterized from a to b by u. Same as lerp.
@inlinable
func interpolate_line<T>(_ p0: T, _ p1: T, _ u: Float) -> T {
    fatalError()
}

// Interpolates values over a triangle parameterized by u and v along the
// (p1-p0) and (p2-p0) directions. Same as barycentric interpolation.
@inlinable
func interpolate_triangle<T>(_ p0: T, _ p1: T, _ p2: T, _ uv: vec2f) -> T {
    fatalError()
}

// Interpolates values over a quad parameterized by u and v along the
// (p1-p0) and (p2-p1) directions. Same as bilinear interpolation.
@inlinable
func interpolate_quad<T>(_ p0: T, _ p1: T, _ p2: T, _ p3: T, _ uv: vec2f) -> T {
    fatalError()
}

// Interpolates values along a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier<T>(_ p0: T, _ p1: T, _ p2: T, _ p3: T, _ u: Float) -> T {
    fatalError()
}

// Computes the derivative of a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier_derivative<T>(_ p0: T, _ p1: T, _ p2: T, _ p3: T, _ u: Float) -> T {
    fatalError()
}

// Interpolated line properties.
@inlinable
func line_tangent(_ t0: vec3f, _ t1: vec3f, _ u: Float) -> vec3f {
    fatalError()
}

// Interpolated triangle properties.
@inlinable
func triangle_normal(_ n0: vec3f, _ n1: vec3f, _ n2: vec3f, _ uv: vec2f) -> vec3f {
    fatalError()
}

// Interpolated quad properties.
@inlinable
func quad_point(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f, _ uv: vec2f) -> vec3f {
    fatalError()
}

@inlinable
func quad_normal(_ n0: vec3f, _ n1: vec3f, _ n2: vec3f, _ n3: vec3f, _ uv: vec2f) -> vec3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// USER INTERFACE UTILITIES
// -----------------------------------------------------------------------------
// Generate a ray from a camera
@inlinable
func camera_ray(_ frame: frame3f, _ lens: Float, _ film: vec2f, _ image_uv: vec2f) -> ray3f {
    fatalError()
}

// Generate a ray from a camera
@inlinable
func camera_ray(_ frame: frame3f, _ lens: Float, _ aspect: Float, _ film: Float, _ image_uv: vec2f) -> ray3f {
    fatalError()
}

// -----------------------------------------------------------------------------
// RAY-PRIMITIVE INTERSECTION FUNCTIONS
// -----------------------------------------------------------------------------
// Intersect a ray with a point (approximate)
@inlinable
func intersect_point(_ ray: ray3f, _ p: vec3f, _ r: Float,
                     _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a line
@inlinable
func intersect_line(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ r0: Float, _ r1: Float,
                    _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a triangle
@inlinable
func intersect_triangle(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f,
                        _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a quad.
@inlinable
func intersect_quad(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                    _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(_ ray: ray3f, _ bbox: bbox3f) -> Bool {
    fatalError()
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(_ ray: ray3f, _ ray_dinv: vec3f, _ bbox: bbox3f) -> Bool {
    fatalError()
}

// -----------------------------------------------------------------------------
// POINT-PRIMITIVE DISTANCE FUNCTIONS
// -----------------------------------------------------------------------------
// Check if a point overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_point(_ pos: vec3f, _ dist_max: Float, _ p: vec3f,
                   _ r: Float, _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Compute the closest line uv to a give position pos.
@inlinable
func closest_uv_line(_ pos: vec3f, _ p0: vec3f, _ p1: vec3f) -> Float {
    fatalError()
}

// Check if a line overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_line(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f,
                  _ r0: Float, _ r1: Float, _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Compute the closest triangle uv to a give position pos.
@inlinable
func closest_uv_triangle(_ pos: vec3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> vec2f {
    fatalError()
}

// Check if a triangle overlaps a position pos within a maximum distance
// dist_max.
@inlinable
func overlap_triangle(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f,
                      _ r0: Float, _ r1: Float, _ r2: Float,
                      _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Check if a quad overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_quad(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                  _ r0: Float, _ r1: Float, _ r2: Float, _ r3: Float,
                  _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    fatalError()
}

// Check if a bbox overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_bbox(_ pos: vec3f, _ dist_max: Float, b_ box: bbox3f) -> Bool {
    fatalError()
}

// Check if two bbox overlap.
@inlinable
func overlap_bbox(_ bbox1: bbox3f, _ bbox2: bbox3f) -> Bool {
    fatalError()
}
