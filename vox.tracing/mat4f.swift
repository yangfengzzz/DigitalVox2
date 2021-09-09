//
//  mat4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat4f = matrix_float4x4

extension mat4f {
    public var x: vec4f {
        get {
            columns.0
        }
        set {
            columns.0 = newValue
        }
    }

    public var y: vec4f {
        get {
            columns.1
        }
        set {
            columns.1 = newValue
        }
    }

    public var z: vec4f {
        get {
            columns.2
        }
        set {
            columns.2 = newValue
        }
    }

    public var w: vec4f {
        get {
            columns.3
        }
        set {
            columns.3 = newValue
        }
    }
}

public let identity4x4f = mat4f(
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
)

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat4f) -> vec4f {
    [a.x.x, a.y.y, a.z.z, a.w.w]
}

@inlinable
func transpose(_ a: mat4f) -> mat4f {
    a.transpose
}

func matrix4x4_translation(_ tx: Float, _ ty: Float, _ tz: Float) -> mat4f {
    mat4f(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [tx, ty, tz, 1]
    )
}

func matrix4x4_rotation(_ radians: Float, _ axis: vec3f) -> mat4f {
    let axis = normalize(axis)
    let ct = cos(radians)
    let st = sin(radians)
    let ci = 1 - ct
    let x = axis.x, y = axis.y, z = axis.z

    return mat4f(
            [ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0],
            [x * y * ci - z * st, ct + y * y * ci, z * y * ci + x * st, 0],
            [x * z * ci + y * st, y * z * ci - x * st, ct + z * z * ci, 0],
            [0, 0, 0, 1]
    )
}

func matrix4x4_scale(_ sx: Float, _ sy: Float, _ sz: Float) -> mat4f {
    mat4f(
            [sx, 0, 0, 0],
            [0, sy, 0, 0],
            [0, 0, sz, 0],
            [0, 0, 0, 1]
    )
}
