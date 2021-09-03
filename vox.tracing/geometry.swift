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
    p0 * (1 - u) + p1 * u
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
    p0 * (1 - uv.x - uv.y) + p1 * uv.x + p2 * uv.y
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
    // Follows the definition in http://www.terathon.com/code/tangent.html and
    // https://gist.github.com/aras-p/2843984
    // normal points up from texture space
    let p = p1 - p0
    let q = p2 - p0
    let s = vec2f(uv1.x - uv0.x, uv2.x - uv0.x)
    let t = vec2f(uv1.y - uv0.y, uv2.y - uv0.y)
    let div = s.x * t.y - s.y * t.x

    if (div != 0) {
        let tu = vec3f(t.y * p.x - t.x * q.x, t.y * p.y - t.x * q.y, t.y * p.z - t.x * q.z) / div
        let tv = vec3f(s.x * q.x - s.y * p.x, s.x * q.y - s.y * p.y, s.x * q.z - s.y * p.z) / div
        return (tu, tv)
    } else {
        return ([1, 0, 0], [0, 1, 0])
    }
}

// Quad tangent and bitangent from uv. Note that we pass a current_uv since
// internally we may want to split the quad in two and we need to known where
// to do it. If not interested in the split, just pass zero2f here.
@inlinable
func quad_tangents_from_uv(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                           _ uv0: vec2f, _ uv1: vec2f, _ uv2: vec2f, _ uv3: vec2f,
                           _ current_uv: vec2f) -> (vec3f, vec3f) {
    if (current_uv.x + current_uv.y <= 1) {
        return triangle_tangents_from_uv(p0, p1, p3, uv0, uv1, uv3)
    } else {
        return triangle_tangents_from_uv(p2, p3, p1, uv2, uv3, uv1)
    }
}

// Interpolates values over a line parameterized from a to b by u. Same as lerp.
@inlinable
func interpolate_line(_ p0: vec2f, _ p1: vec2f, _ u: Float) -> vec2f {
    p0 * (1 - u) + p1 * u
}

@inlinable
func interpolate_line(_ p0: vec3f, _ p1: vec3f, _ u: Float) -> vec3f {
    p0 * (1 - u) + p1 * u
}

@inlinable
func interpolate_line(_ p0: vec4f, _ p1: vec4f, _ u: Float) -> vec4f {
    p0 * (1 - u) + p1 * u
}

// Interpolates values over a triangle parameterized by u and v along the
// (p1-p0) and (p2-p0) directions. Same as barycentric interpolation.
@inlinable
func interpolate_triangle(_ p0: vec2f, _ p1: vec2f, _ p2: vec2f, _ uv: vec2f) -> vec2f {
    p0 * (1 - uv.x - uv.y) + p1 * uv.x + p2 * uv.y
}

@inlinable
func interpolate_triangle(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ uv: vec2f) -> vec3f {
    p0 * (1 - uv.x - uv.y) + p1 * uv.x + p2 * uv.y
}

@inlinable
func interpolate_triangle(_ p0: vec4f, _ p1: vec4f, _ p2: vec4f, _ uv: vec2f) -> vec4f {
    p0 * (1 - uv.x - uv.y) + p1 * uv.x + p2 * uv.y
}

// Interpolates values over a quad parameterized by u and v along the
// (p1-p0) and (p2-p1) directions. Same as bilinear interpolation.
@inlinable
func interpolate_quad(_ p0: vec2f, _ p1: vec2f, _ p2: vec2f, _ p3: vec2f, _ uv: vec2f) -> vec2f {
    if (uv.x + uv.y <= 1) {
        return interpolate_triangle(p0, p1, p3, uv)
    } else {
        return interpolate_triangle(p2, p3, p1, 1 - uv)
    }
}

@inlinable
func interpolate_quad(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f, _ uv: vec2f) -> vec3f {
    if (uv.x + uv.y <= 1) {
        return interpolate_triangle(p0, p1, p3, uv)
    } else {
        return interpolate_triangle(p2, p3, p1, 1 - uv)
    }
}

@inlinable
func interpolate_quad(_ p0: vec4f, _ p1: vec4f, _ p2: vec4f, _ p3: vec4f, _ uv: vec2f) -> vec4f {
    if (uv.x + uv.y <= 1) {
        return interpolate_triangle(p0, p1, p3, uv)
    } else {
        return interpolate_triangle(p2, p3, p1, 1 - uv)
    }
}

// Interpolates values along a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier(_ p0: vec2f, _ p1: vec2f, _ p2: vec2f, _ p3: vec2f, _ u: Float) -> vec2f {
    var result = p0 * (1 - u) * (1 - u) * (1 - u)
    result += p1 * 3 * u * (1 - u) * (1 - u)
    result += p2 * 3 * u * u * (1 - u)
    result += p3 * u * u * u
    return result
}

@inlinable
func interpolate_bezier(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f, _ u: Float) -> vec3f {
    var result = p0 * (1 - u) * (1 - u) * (1 - u)
    result += p1 * 3 * u * (1 - u) * (1 - u)
    result += p2 * 3 * u * u * (1 - u)
    result += p3 * u * u * u
    return result
}

@inlinable
func interpolate_bezier(_ p0: vec4f, _ p1: vec4f, _ p2: vec4f, _ p3: vec4f, _ u: Float) -> vec4f {
    var result = p0 * (1 - u) * (1 - u) * (1 - u)
    result += p1 * 3 * u * (1 - u) * (1 - u)
    result += p2 * 3 * u * u * (1 - u)
    result += p3 * u * u * u
    return result
}

// Computes the derivative of a cubic Bezier segment parametrized by u.
@inlinable
func interpolate_bezier_derivative(_ p0: vec2f, _ p1: vec2f, _ p2: vec2f, _ p3: vec2f, _ u: Float) -> vec2f {
    var result = (p1 - p0) * 3 * (1 - u) * (1 - u)
    result += (p2 - p1) * 6 * u * (1 - u)
    result += (p3 - p2) * 3 * u * u
}

@inlinable
func interpolate_bezier_derivative(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f, _ u: Float) -> vec3f {
    var result = (p1 - p0) * 3 * (1 - u) * (1 - u)
    result += (p2 - p1) * 6 * u * (1 - u)
    result += (p3 - p2) * 3 * u * u
}

@inlinable
func interpolate_bezier_derivative(_ p0: vec4f, _ p1: vec4f, _ p2: vec4f, _ p3: vec4f, _ u: Float) -> vec4f {
    var result = (p1 - p0) * 3 * (1 - u) * (1 - u)
    result += (p2 - p1) * 6 * u * (1 - u)
    result += (p3 - p2) * 3 * u * u
}

// Interpolated line properties.
@inlinable
func line_tangent(_ t0: vec3f, _ t1: vec3f, _ u: Float) -> vec3f {
    normalize(t0 * (1 - u) + t1 * u)
}

// Interpolated triangle properties.
@inlinable
func triangle_normal(_ n0: vec3f, _ n1: vec3f, _ n2: vec3f, _ uv: vec2f) -> vec3f {
    normalize(n0 * (1 - uv.x - uv.y) + n1 * uv.x + n2 * uv.y)
}

// Interpolated quad properties.
@inlinable
func quad_point(_ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f, _ uv: vec2f) -> vec3f {
    if (uv.x + uv.y <= 1) {
        return triangle_point(p0, p1, p3, uv)
    } else {
        return triangle_point(p2, p3, p1, 1 - uv)
    }
}

@inlinable
func quad_normal(_ n0: vec3f, _ n1: vec3f, _ n2: vec3f, _ n3: vec3f, _ uv: vec2f) -> vec3f {
    if (uv.x + uv.y <= 1) {
        return triangle_normal(n0, n1, n3, uv)
    } else {
        return triangle_normal(n2, n3, n1, 1 - uv)
    }
}

// -----------------------------------------------------------------------------
// USER INTERFACE UTILITIES
// -----------------------------------------------------------------------------
// Generate a ray from a camera
@inlinable
func camera_ray(_ frame: frame3f, _ lens: Float, _ film: vec2f, _ image_uv: vec2f) -> ray3f {
    let e = vec3f(0, 0, 0)
    let q = vec3f(film.x * (0.5 - image_uv.x), film.y * (image_uv.y - 0.5), lens)
    let q1 = -q
    let d = normalize(q1 - e)
    let ray = ray3f(transform_point(frame, e), transform_direction(frame, d))
    return ray
}

// Generate a ray from a camera
@inlinable
func camera_ray(_ frame: frame3f, _ lens: Float, _ aspect: Float, _ film_: Float, _ image_uv: vec2f) -> ray3f {
    let film = aspect >= 1 ? vec2f(film_, film_ / aspect) : vec2f(film_ * aspect, film_)
    let e = vec3f(0, 0, 0)
    let q = vec3f(film.x * (0.5 - image_uv.x), film.y * (image_uv.y - 0.5), lens)
    let q1 = -q
    let d = normalize(q1 - e)
    let ray = ray3f(transform_point(frame, e), transform_direction(frame, d))
    return ray
}

// -----------------------------------------------------------------------------
// RAY-PRIMITIVE INTERSECTION FUNCTIONS
// -----------------------------------------------------------------------------
// Intersect a ray with a point (approximate)
@inlinable
func intersect_point(_ ray: ray3f, _ p: vec3f, _ r: Float,
                     _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    // find parameter for line-point minimum distance
    let w = p - ray.o
    let t = dot(w, ray.d) / dot(ray.d, ray.d)

    // exit if not within bounds
    if (t < ray.tmin || t > ray.tmax) {
        return false
    }

    // test for line-point distance vs point radius
    let rp = ray.o + ray.d * t
    let prp = p - rp
    if (dot(prp, prp) > r * r) {
        return false
    }

    // intersection occurred: set params and exit
    uv = [0, 0]
    dist = t
    return true
}

// Intersect a ray with a line
@inlinable
func intersect_line(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ r0: Float, _ r1: Float,
                    _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    // setup intersection params
    let u = ray.d
    let v = p1 - p0
    let w = ray.o - p0

    // compute values to solve a linear system
    let a = dot(u, u)
    let b = dot(u, v)
    let c = dot(v, v)
    let d = dot(u, w)
    let e = dot(v, w)
    let det = a * c - b * b

    // check determinant and exit if lines are parallel
    // (could use EPSILONS if desired)
    if (det == 0) {
        return false
    }

    // compute Parameters on both ray and segment
    let t = (b * e - c * d) / det
    var s = (a * e - b * d) / det

    // exit if not within bounds
    if (t < ray.tmin || t > ray.tmax) {
        return false
    }

    // clamp segment param to segment corners
    s = simd_clamp(s, 0.0, 1.0)

    // compute segment-segment distance on the closest points
    let pr = ray.o + ray.d * t
    let pl = p0 + (p1 - p0) * s
    let prl = pr - pl

    // check with the line radius at the same point
    let d2 = dot(prl, prl)
    let r = r0 * (1 - s) + r1 * s
    if (d2 > r * r) {
        return false
    }

    // intersection occurred: set params and exit
    uv = [s, sqrt(d2) / r]
    dist = t
    return true

}

// Intersect a ray with a triangle
@inlinable
func intersect_triangle(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f,
                        _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    // compute triangle edges
    let edge1 = p1 - p0
    let edge2 = p2 - p0

    // compute determinant to solve a linear system
    let pvec = simd_cross(ray.d, edge2)
    let det = dot(edge1, pvec)

    // check determinant and exit if triangle and ray are parallel
    // (could use EPSILONS if desired)
    if (det == 0) {
        return false
    }
    let inv_det = 1.0 / det

    // compute and check first barycentric coordinated
    let tvec = ray.o - p0
    let u = dot(tvec, pvec) * inv_det
    if (u < 0 || u > 1) {
        return false
    }

    // compute and check second barycentric coordinated
    let qvec = simd_cross(tvec, edge1)
    let v = dot(ray.d, qvec) * inv_det
    if (v < 0 || u + v > 1) {
        return false
    }

    // compute and check ray parameter
    let t = dot(edge2, qvec) * inv_det
    if (t < ray.tmin || t > ray.tmax) {
        return false
    }

    // intersection occurred: set params and exit
    uv = [u, v]
    dist = t
    return true
}

// Intersect a ray with a quad.
@inlinable
func intersect_quad(_ ray: ray3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                    _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    if (p2 == p3) {
        return intersect_triangle(ray, p0, p1, p3, &uv, &dist)
    }
    var hit = false
    var tray = ray
    if (intersect_triangle(tray, p0, p1, p3, &uv, &dist)) {
        hit = true
        tray.tmax = dist
    }
    if (intersect_triangle(tray, p2, p3, p1, &uv, &dist)) {
        hit = true
        uv = 1 - uv
        tray.tmax = dist
    }
    return hit
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(_ ray: ray3f, _ bbox: bbox3f) -> Bool {
    // determine intersection ranges
    let invd = 1.0 / ray.d
    var t0 = (bbox.min - ray.o) * invd
    var t1 = (bbox.max - ray.o) * invd
    // flip based on range directions
    if (invd.x < 0.0) {
        swap(&t0.x, &t1.x)
    }
    if (invd.y < 0.0) {
        swap(&t0.y, &t1.y)
    }
    if (invd.z < 0.0) {
        swap(&t0.z, &t1.z)
    }
    let tmin = max(t0.z, max(t0.y, max(t0.x, ray.tmin)))
    var tmax = min(t1.z, min(t1.y, min(t1.x, ray.tmax)))
    tmax *= 1.00000024  // for double: 1.0000000000000004
    return tmin <= tmax
}

// Intersect a ray with a axis-aligned bounding box
@inlinable
func intersect_bbox(_ ray: ray3f, _ ray_dinv: vec3f, _ bbox: bbox3f) -> Bool {
    let it_min = (bbox.min - ray.o) * ray_dinv
    let it_max = (bbox.max - ray.o) * ray_dinv
    let tmin = min(it_min, it_max)
    let tmax = max(it_min, it_max)
    let t0 = max(max(tmin), ray.tmin)
    var t1 = min(min(tmax), ray.tmax)
    t1 *= 1.00000024  // for double: 1.0000000000000004
    return t0 <= t1
}

// -----------------------------------------------------------------------------
// POINT-PRIMITIVE DISTANCE FUNCTIONS
// -----------------------------------------------------------------------------
// Check if a point overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_point(_ pos: vec3f, _ dist_max: Float, _ p: vec3f,
                   _ r: Float, _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    let d2 = dot(pos - p, pos - p)
    if (d2 > (dist_max + r) * (dist_max + r)) {
        return false
    }
    uv = [0, 0]
    dist = sqrt(d2)
    return true
}

// Compute the closest line uv to a give position pos.
@inlinable
func closest_uv_line(_ pos: vec3f, _ p0: vec3f, _ p1: vec3f) -> Float {
    let ab = p1 - p0
    let d = dot(ab, ab)
    // Project c onto ab, computing parameterized position d(t) = a + t*(b – a)
    var u = dot(pos - p0, ab) / d
    u = simd_clamp(u, 0.0, 1.0)
    return u
}

// Check if a line overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_line(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f,
                  _ r0: Float, _ r1: Float, _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    let u = closest_uv_line(pos, p0, p1)
    // Compute projected position from the clamped t d = a + t * ab
    let p = p0 + (p1 - p0) * u
    let r = r0 + (r1 - r0) * u
    let d2 = dot(pos - p, pos - p)
    // check distance
    if (d2 > (dist_max + r) * (dist_max + r)) {
        return false
    }
    // done
    uv = [u, 0]
    dist = sqrt(d2)
    return true
}

// Compute the closest triangle uv to a give position pos.
@inlinable
func closest_uv_triangle(_ pos: vec3f, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f) -> vec2f {
    // this is a complicated test -> I probably "--"+prefix to use a sequence of
    // test (triangle body, and 3 edges)
    let ab = p1 - p0
    let ac = p2 - p0
    let ap = pos - p0

    let d1 = dot(ab, ap)
    let d2 = dot(ac, ap)

    // corner and edge cases
    if (d1 <= 0 && d2 <= 0) {
        return [0, 0]
    }

    let bp = pos - p1
    let d3 = dot(ab, bp)
    let d4 = dot(ac, bp)
    if (d3 >= 0 && d4 <= d3) {
        return [1, 0]
    }

    let vc = d1 * d4 - d3 * d2
    if ((vc <= 0) && (d1 >= 0) && (d3 <= 0)) {
        return [d1 / (d1 - d3), 0]
    }

    let cp = pos - p2
    let d5 = dot(ab, cp)
    let d6 = dot(ac, cp)
    if (d6 >= 0 && d5 <= d6) {
        return [0, 1]
    }

    let vb = d5 * d2 - d1 * d6
    if ((vb <= 0) && (d2 >= 0) && (d6 <= 0)) {
        return [0, d2 / (d2 - d6)]
    }

    let va = d3 * d6 - d5 * d4
    if ((va <= 0) && (d4 - d3 >= 0) && (d5 - d6 >= 0)) {
        let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
        return [1 - w, w]
    }

    // face case
    let denom = 1 / (va + vb + vc)
    let u = vb * denom
    let v = vc * denom
    return [u, v]
}

// Check if a triangle overlaps a position pos within a maximum distance
// dist_max.
@inlinable
func overlap_triangle(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f,
                      _ r0: Float, _ r1: Float, _ r2: Float,
                      _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    let cuv = closest_uv_triangle(pos, p0, p1, p2)
    let p = p0 * (1 - cuv.x - cuv.y) + p1 * cuv.x + p2 * cuv.y
    let r = r0 * (1 - cuv.x - cuv.y) + r1 * cuv.x + r2 * cuv.y
    let dd = dot(p - pos, p - pos)
    if (dd > (dist_max + r) * (dist_max + r)) {
        return false
    }
    uv = cuv
    dist = sqrt(dd)
    return true
}

// Check if a quad overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_quad(_ pos: vec3f, _ dist_max: Float, _ p0: vec3f, _ p1: vec3f, _ p2: vec3f, _ p3: vec3f,
                  _ r0: Float, _ r1: Float, _ r2: Float, _ r3: Float,
                  _ uv: inout vec2f, _ dist: inout Float) -> Bool {
    var dist_max = dist_max
    if (p2 == p3) {
        return overlap_triangle(pos, dist_max, p0, p1, p3, r0, r1, r2, &uv, &dist)
    }
    var hit = false
    if (overlap_triangle(pos, dist_max, p0, p1, p3, r0, r1, r2, &uv, &dist)) {
        hit = true
        dist_max = dist
    }
    if (!overlap_triangle(pos, dist_max, p2, p3, p1, r2, r3, r1, &uv, &dist)) {
        hit = true
        uv = 1 - uv
        // dist_max = dist
    }
    return hit
}

// Check if a bbox overlaps a position pos within a maximum distance dist_max.
@inlinable
func overlap_bbox(_ pos: vec3f, _ dist_max: Float, _ bbox: bbox3f) -> Bool {
    // computing distance
    var dd: Float = 0.0

    // For each axis count any excess distance outside box extents
    if (pos.x < bbox.min.x) {
        dd += (bbox.min.x - pos.x) * (bbox.min.x - pos.x)
    }
    if (pos.x > bbox.max.x) {
        dd += (pos.x - bbox.max.x) * (pos.x - bbox.max.x)
    }
    if (pos.y < bbox.min.y) {
        dd += (bbox.min.y - pos.y) * (bbox.min.y - pos.y)
    }
    if (pos.y > bbox.max.y) {
        dd += (pos.y - bbox.max.y) * (pos.y - bbox.max.y)
    }
    if (pos.z < bbox.min.z) {
        dd += (bbox.min.z - pos.z) * (bbox.min.z - pos.z)
    }
    if (pos.z > bbox.max.z) {
        dd += (pos.z - bbox.max.z) * (pos.z - bbox.max.z)
    }

    // check distance
    return dd < dist_max * dist_max
}

// Check if two bbox overlap.
@inlinable
func overlap_bbox(_ bbox1: bbox3f, _ bbox2: bbox3f) -> Bool {
    if (bbox1.max.x < bbox2.min.x || bbox1.min.x > bbox2.max.x) {
        return false
    }
    if (bbox1.max.y < bbox2.min.y || bbox1.min.y > bbox2.max.y) {
        return false
    }
    if (bbox1.max.z < bbox2.min.z || bbox1.min.z > bbox2.max.z) {
        return false
    }
    return true
}
