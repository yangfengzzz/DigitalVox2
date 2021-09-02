//
//  math.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

@inlinable
func bias(_ a: Float, _ bias: Float) -> Float {
    return a / ((1 / bias - 2) * (1 - a) + 1)
}

@inlinable
func gain(_ a: Float, _ gain: Float) -> Float {
    return (a < 0.5) ? bias(a * 2, gain) / 2
            : bias(a * 2 - 1, 1 - gain) / 2 + 0.5
}

// -----------------------------------------------------------------------------
// TRANSFORMS
// -----------------------------------------------------------------------------
// Transforms points, vectors and directions by matrices.
@inlinable
func transform_point(_ a: mat3f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: mat3f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: mat3f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_normal(_ a: mat3f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: mat2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: mat2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_normal(_ a: mat2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_point(_ a: mat4f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: mat4f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: mat4f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: mat3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: mat3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_normal(_ a: mat3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

// Transforms points, vectors and directions by frames.
@inlinable
func transform_point(_ a: frame2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: frame2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: frame2f, _ b: vec2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transform_normal(_ a: frame2f, _ b: vec2f, _ non_rigid: Bool = false) -> vec2f {
    fatalError("TODO")
}

// Transforms points, vectors and directions by frames.
@inlinable
func transform_point(_ a: frame3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_vector(_ a: frame3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_direction(_ a: frame3f, _ b: vec3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transform_normal(_ a: frame3f, _ b: vec3f, _ non_rigid: Bool = false) -> vec3f {
    fatalError("TODO")
}

// Translation, scaling and rotations transforms.
@inlinable
func translation_frame(_ a: vec3f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func scaling_frame(_ a: vec3f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func rotation_frame(_ axis: vec3f, _ angle: Float) -> frame3f {
    fatalError("TODO")
}

@inlinable
func rotation_frame(_ quat: vec4f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func rotation_frame(_ quat: quat4f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func rotation_frame(_ rot: mat3f) -> frame3f {
    fatalError("TODO")
}

// Lookat frame. Z-axis can be inverted with inv_xz.
@inlinable
func lookat_frame(_ eye: vec3f, _ center: vec3f, _ up: vec3f, _ inv_xz: Bool = false) -> frame3f {
    fatalError("TODO")
}

// OpenGL frustum, ortho and perspecgive matrices.
@inlinable
func frustum_mat(_ l: Float, _ r: Float, _ b: Float, _ t: Float, _ n: Float, _ f: Float) -> mat4f {
    fatalError("TODO")
}

@inlinable
func ortho_mat(_ l: Float, _ r: Float, _ b: Float, _ t: Float, _  n: Float, _ f: Float) -> mat4f {
    fatalError("TODO")
}

@inlinable
func ortho2d_mat(_ left: Float, _ right: Float, _ bottom: Float, _ top: Float) -> mat4f {
    fatalError("TODO")
}

@inlinable
func ortho_mat(_ xmag: Float, _ ymag: Float, _ near: Float, _ far: Float) -> mat4f {
    fatalError("TODO")
}

@inlinable
func perspective_mat(_ fovy: Float, _ aspect: Float, _ near: Float, _ far: Float) -> mat4f {
    fatalError("TODO")
}

@inlinable
func perspective_mat(_ fovy: Float, _ aspect: Float, _ near: Float) -> mat4f {
    fatalError("TODO")
}

// Rotation conversions.
@inlinable
func rotation_axisangle(_ quat: vec4f) -> (vec3f, Float) {
    fatalError("TODO")
}

@inlinable
func rotation_quat(_ axis: vec3f, _ angle: Float) -> vec4f {
    fatalError("TODO")
}

@inlinable
func rotation_quat(_ axisangle: vec4f) -> vec4f {
    fatalError("TODO")
}

// -----------------------------------------------------------------------------
// USER INTERFACE UTILITIES
// -----------------------------------------------------------------------------
// Computes the image uv coordinates corresponding to the view parameters.
// Returns negative coordinates if out of the image.
@inlinable
func image_coords(_ mouse_pos: vec2f, _ center: vec2f,
                  _ scale: Float, _ txt_size: vec2i) -> vec2i {
    fatalError("TODO")
}

// Center image and autofit. Returns center and scale.
@inlinable
func camera_imview(_ center: vec2f, _ scale: Float,
                   _ imsize: vec2i, _ winsize: vec2i, zoom_to_fit: Bool) -> (vec2f, Float) {
    fatalError("TODO")
}

// Turntable for UI navigation. Returns from and to.
@inlinable
func camera_turntable(_ from: vec3f, _ to: vec3f,
                      _ up: vec3f, _ rotate: vec2f, dolly: Float, _ pan: vec2f) -> (vec3f, vec3f) {
    fatalError("TODO")
}

// Turntable for UI navigation. Returns frame and focus.
@inlinable
func camera_turntable(_ frame: frame3f, _ focus: Float,
                      _ rotate: vec2f, dolly: Float, _ pan: vec2f) -> (frame3f, Float) {
    fatalError("TODO")
}

// FPS camera for UI navigation for a frame parametrization. Returns frame.
@inlinable
func camera_fpscam(_ frame: frame3f, _ transl: vec3f, _ rotate: vec2f) -> frame3f {
    fatalError("TODO")
}
