//
//  math.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

@inlinable
func bias(_ a: Float, _ bias: Float) -> Float {
    a / ((1 / bias - 2) * (1 - a) + 1)
}

@inlinable
func gain(_ a: Float, _ gain: Float) -> Float {
    (a < 0.5) ? bias(a * 2, gain) / 2 : bias(a * 2 - 1, 1 - gain) / 2 + 0.5
}

// -----------------------------------------------------------------------------
// TRANSFORMS
// -----------------------------------------------------------------------------
// Transforms points, vectors and directions by matrices.
@inlinable
func transform_point(_ a: mat3f, _ b: vec2f) -> vec2f {
    let tvb = a * vec3f(b.x, b.y, 1)
    return vec2f(tvb.x, tvb.y) / tvb.z
}

@inlinable
func transform_vector(_ a: mat3f, _ b: vec2f) -> vec2f {
    let tvb = a * vec3f(b.x, b.y, 0)
    return vec2f(tvb.x, tvb.y) / tvb.z
}

@inlinable
func transform_direction(_ a: mat3f, _ b: vec2f) -> vec2f {
    normalize(transform_vector(a, b))
}

@inlinable
func transform_normal(_ a: mat3f, _ b: vec2f) -> vec2f {
    normalize(transform_vector(transpose(inverse(a)), b))
}

@inlinable
func transform_vector(_ a: mat2f, _ b: vec2f) -> vec2f {
    a * b
}

@inlinable
func transform_direction(_ a: mat2f, _ b: vec2f) -> vec2f {
    normalize(transform_vector(a, b))
}

@inlinable
func transform_normal(_ a: mat2f, _ b: vec2f) -> vec2f {
    normalize(transform_vector(transpose(inverse(a)), b))
}

@inlinable
func transform_point(_ a: mat4f, _ b: vec3f) -> vec3f {
    let tvb = a * vec4f(b.x, b.y, b.z, 1)
    return vec3f(tvb.x, tvb.y, tvb.z) / tvb.w
}

@inlinable
func transform_vector(_ a: mat4f, _ b: vec3f) -> vec3f {
    let tvb = a * vec4f(b.x, b.y, b.z, 0)
    return vec3f(tvb.x, tvb.y, tvb.z)
}

@inlinable
func transform_direction(_ a: mat4f, _ b: vec3f) -> vec3f {
    normalize(transform_vector(a, b))
}

@inlinable
func transform_vector(_ a: mat3f, _ b: vec3f) -> vec3f {
    a * b
}

@inlinable
func transform_direction(_ a: mat3f, _ b: vec3f) -> vec3f {
    normalize(transform_vector(a, b))

}

@inlinable
func transform_normal(_ a: mat3f, _ b: vec3f) -> vec3f {
    normalize(transform_vector(transpose(inverse(a)), b))
}

// Transforms points, vectors and directions by frames.
@inlinable
func transform_point(_ a: frame2f, _ b: vec2f) -> vec2f {
    a.x * b.x + a.y * b.y + a.o
}

@inlinable
func transform_vector(_ a: frame2f, _ b: vec2f) -> vec2f {
    a.x * b.x + a.y * b.y
}

@inlinable
func transform_direction(_ a: frame2f, _ b: vec2f) -> vec2f {
    normalize(transform_vector(a, b))
}

@inlinable
func transform_normal(_ a: frame2f, _ b: vec2f, _ non_rigid: Bool = false) -> vec2f {
    if (non_rigid) {
        return transform_normal(rotation(a), b)
    } else {
        return normalize(transform_vector(a, b))
    }

}

// Transforms points, vectors and directions by frames.
@inlinable
func transform_point(_ a: frame3f, _ b: vec3f) -> vec3f {
    let vec = a.x * b.x + a.y * b.y + a.z * b.z
    return vec + a.o
}

@inlinable
func transform_vector(_ a: frame3f, _ b: vec3f) -> vec3f {
    a.x * b.x + a.y * b.y + a.z * b.z
}

@inlinable
func transform_direction(_ a: frame3f, _ b: vec3f) -> vec3f {
    normalize(transform_vector(a, b))
}

@inlinable
func transform_normal(_ a: frame3f, _ b: vec3f, _ non_rigid: Bool = false) -> vec3f {
    if (non_rigid) {
        return transform_normal(rotation(a), b)
    } else {
        return normalize(transform_vector(a, b))
    }
}

// Translation, scaling and rotations transforms.
@inlinable
func translation_frame(_ a: vec3f) -> frame3f {
    frame3f([1, 0, 0], [0, 1, 0], [0, 0, 1], a)
}

@inlinable
func scaling_frame(_ a: vec3f) -> frame3f {
    frame3f([a.x, 0, 0], [0, a.y, 0], [0, 0, a.z], [0, 0, 0])
}

@inlinable
func rotation_frame(_ axis: vec3f, _ angle: Float) -> frame3f {
    let s = sin(angle), c = cos(angle)
    let vv = normalize(axis)
    return frame3f(
            [c + (1 - c) * vv.x * vv.x, (1 - c) * vv.x * vv.y + s * vv.z, (1 - c) * vv.x * vv.z - s * vv.y],
            [(1 - c) * vv.x * vv.y - s * vv.z, c + (1 - c) * vv.y * vv.y, (1 - c) * vv.y * vv.z + s * vv.x],
            [(1 - c) * vv.x * vv.z + s * vv.y, (1 - c) * vv.y * vv.z - s * vv.x, c + (1 - c) * vv.z * vv.z],
            [0, 0, 0])
}

@inlinable
func rotation_frame(_ quat: vec4f) -> frame3f {
    let v = quat
    return frame3f(
            [v.w * v.w + v.x * v.x - v.y * v.y - v.z * v.z, (v.x * v.y + v.z * v.w) * 2, (v.z * v.x - v.y * v.w) * 2],
            [(v.x * v.y - v.z * v.w) * 2, v.w * v.w - v.x * v.x + v.y * v.y - v.z * v.z, (v.y * v.z + v.x * v.w) * 2],
            [(v.z * v.x + v.y * v.w) * 2, (v.y * v.z - v.x * v.w) * 2, v.w * v.w - v.x * v.x - v.y * v.y + v.z * v.z],
            [0, 0, 0])
}

@inlinable
func rotation_frame(_ quat: quat4f) -> frame3f {
    let v = quat
    return frame3f([v.w * v.w + v.x * v.x - v.y * v.y - v.z * v.z, (v.x * v.y + v.z * v.w) * 2, (v.z * v.x - v.y * v.w) * 2],
            [(v.x * v.y - v.z * v.w) * 2, v.w * v.w - v.x * v.x + v.y * v.y - v.z * v.z, (v.y * v.z + v.x * v.w) * 2],
            [(v.z * v.x + v.y * v.w) * 2, (v.y * v.z - v.x * v.w) * 2, v.w * v.w - v.x * v.x - v.y * v.y + v.z * v.z],
            [0, 0, 0])
}

@inlinable
func rotation_frame(_ rot: mat3f) -> frame3f {
    frame3f(rot.x, rot.y, rot.z, [0, 0, 0])
}

// Lookat frame. Z-axis can be inverted with inv_xz.
@inlinable
func lookat_frame(_ eye: vec3f, _ center: vec3f, _ up: vec3f, _ inv_xz: Bool = false) -> frame3f {
    var w = normalize(eye - center)
    var u = normalize(cross(up, w))
    let v = normalize(cross(w, u))
    if (inv_xz) {
        w = -w
        u = -u
    }
    return frame3f(u, v, w, eye)
}

// OpenGL frustum, ortho and perspecgive matrices.
@inlinable
func frustum_mat(_ l: Float, _ r: Float, _ b: Float, _ t: Float, _ n: Float, _ f: Float) -> mat4f {
    mat4f([2 * n / (r - l), 0, 0, 0], [0, 2 * n / (t - b), 0, 0],
            [(r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1],
            [0, 0, -2 * f * n / (f - n), 0])
}

@inlinable
func ortho_mat(_ l: Float, _ r: Float, _ b: Float, _ t: Float, _  n: Float, _ f: Float) -> mat4f {
    mat4f([2 / (r - l), 0, 0, 0], [0, 2 / (t - b), 0, 0],
            [0, 0, -2 / (f - n), 0],
            [-(r + l) / (r - l), -(t + b) / (t - b), -(f + n) / (f - n), 1])
}

@inlinable
func ortho2d_mat(_ left: Float, _ right: Float, _ bottom: Float, _ top: Float) -> mat4f {
    ortho_mat(left, right, bottom, top, -1, 1)
}

@inlinable
func ortho_mat(_ xmag: Float, _ ymag: Float, _ near: Float, _ far: Float) -> mat4f {
    mat4f([1 / xmag, 0, 0, 0], [0, 1 / ymag, 0, 0], [0, 0, 2 / (near - far), 0],
            [0, 0, (far + near) / (near - far), 1])
}

@inlinable
func perspective_mat(_ fovy: Float, _ aspect: Float, _ near: Float, _ far: Float) -> mat4f {
    let tg = tan(fovy / 2)
    return mat4f([1 / (aspect * tg), 0, 0, 0], [0, 1 / tg, 0, 0],
            [0, 0, (far + near) / (near - far), -1],
            [0, 0, 2 * far * near / (near - far), 0])
}

@inlinable
func perspective_mat(_ fovy: Float, _ aspect: Float, _ near: Float) -> mat4f {
    let tg = tan(fovy / 2)
    return mat4f([1 / (aspect * tg), 0, 0, 0], [0, 1 / tg, 0, 0], [0, 0, -1, -1],
            [0, 0, 2 * near, 0])
}

// Rotation conversions.
@inlinable
func rotation_axisangle(_ quat: vec4f) -> (vec3f, Float) {
    (normalize(vec3f(quat.x, quat.y, quat.z)), 2 * acos(quat.w))
}

@inlinable
func rotation_quat(_ axis: vec3f, _ angle: Float) -> vec4f {
    let len = length(axis)
    if (len == 0) {
        return [0, 0, 0, 1]
    }
    return vec4f(sin(angle / 2) * axis.x / len, sin(angle / 2) * axis.y / len,
            sin(angle / 2) * axis.z / len, cos(angle / 2))
}

@inlinable
func rotation_quat(_ axisangle: vec4f) -> vec4f {
    rotation_quat(vec3f(axisangle.x, axisangle.y, axisangle.z), axisangle.w)
}

// -----------------------------------------------------------------------------
// USER INTERFACE UTILITIES
// -----------------------------------------------------------------------------
// Computes the image uv coordinates corresponding to the view parameters.
// Returns negative coordinates if out of the image.
@inlinable
func image_coords(_ mouse_pos: vec2f, _ center: vec2f,
                  _ scale: Float, _ txt_size: vec2i) -> vec2i {
    let xyf = (mouse_pos - center) / scale
    return vec2i(Int(round(xyf.x + Float(txt_size.x) / 2.0)),
            Int(round(xyf.y + Float(txt_size.y) / 2.0)))
}

// Center image and autofit. Returns center and scale.
@inlinable
func camera_imview(_ center: vec2f, _ scale: Float,
                   _ imsize: vec2i, _ winsize: vec2i, zoom_to_fit: Bool) -> (vec2f, Float) {
    if (zoom_to_fit) {
        return ([Float(winsize.x) / 2, Float(winsize.y) / 2],
                min(Float(winsize.x) / Float(imsize.x), Float(winsize.y) / Float(imsize.y)))
    } else {
        return ([(Float(winsize.x) >= Float(imsize.x) * scale) ? Float(winsize.x) / 2 : center.x,
                 (Float(winsize.y) >= Float(imsize.y) * scale) ? Float(winsize.y) / 2 : center.y], scale)
    }
}

// Turntable for UI navigation. Returns from and to.
@inlinable
func camera_turntable(_ from_: vec3f, _ to_: vec3f,
                      _ up: vec3f, _ rotate: vec2f, _ dolly: Float, _ pan: vec2f) -> (vec3f, vec3f) {
    // copy values
    var from = from_, to = to_

    // rotate if necessary
    if (rotate != zero2f) {
        let z = normalize(to - from)
        let lz = length(to - from)
        let phi = atan2(z.z, z.x) + rotate.x
        var theta = acos(z.y) + rotate.y
        theta = simd_clamp(theta, 0.001, Float.pi - 0.001)
        let nz = vec3f(sin(theta) * cos(phi) * lz, cos(theta) * lz,
                sin(theta) * sin(phi) * lz)
        from = to - nz
    }

    // dolly if necessary
    if (dolly != 0) {
        var z = normalize(to - from)
        let lz = max(0.001, length(to - from) * (1 + dolly))
        z *= lz
        from = to - z
    }

    // pan if necessary
    if (pan != zero2f) {
        let z = normalize(to - from)
        let x = normalize(cross(up, z))
        let y = normalize(cross(z, x))
        let t = vec3f(pan.x * x.x + pan.y * y.x, pan.x * x.y + pan.y * y.y, pan.x * x.z + pan.y * y.z)
        from += t
        to += t
    }

    // done
    return (from, to)
}

// Turntable for UI navigation. Returns frame and focus.
@inlinable
func camera_turntable(_ frame_: frame3f, _ focus_: Float,
                      _ rotate: vec2f, _ dolly: Float, _ pan: vec2f) -> (frame3f, Float) {
    // copy values
    var frame = frame_
    var focus = focus_
    // rotate if necessary
    if (rotate != zero2f) {
        let phi = atan2(frame.z.z, frame.z.x) + rotate.x
        var theta = acos(frame.z.y) + rotate.y
        theta = simd_clamp(theta, 0.001, Float.pi - 0.001)
        let new_z = vec3f(sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi))
        let new_center = frame.o - frame.z * focus
        let new_o = new_center + new_z * focus
        frame = lookat_frame(new_o, new_center, [0, 1, 0])
        focus = length(new_o - new_center)
    }

    // pan if necessary
    if (dolly != 0) {
        let c = frame.o - frame.z * focus
        focus = max(focus * (1 + dolly), 0.001)
        frame.o = c + frame.z * focus
    }

    // pan if necessary
    if (pan != zero2f) {
        frame.o += frame.x * pan.x + frame.y * pan.y
    }

    // done
    return (frame, focus)
}

// FPS camera for UI navigation for a frame parametrization. Returns frame.
@inlinable
func camera_fpscam(_ frame: frame3f, _ transl: vec3f, _ rotate: vec2f) -> frame3f {
    // https://gamedev.stackexchange.com/questions/30644/how-to-keep-my-quaternion-using-fps-camera-from-tilting-and-messing-up
    let y = vec3f(0, 1, 0)
    let z = orthonormalize(frame.z, y)
    let x = simd_cross(y, z)

    let rot = rotation_frame(vec3f(1, 0, 0), rotate.y) *
            frame3f(frame.x, frame.y, frame.z, vec3f(0, 0, 0)) *
            rotation_frame(vec3f(0, 1, 0), rotate.x)
    let vec = transl.x * x + transl.y * y + transl.z * z

    return frame3f(rot.x, rot.y, rot.z, vec + frame.o)
}
