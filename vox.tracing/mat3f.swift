//
//  mat3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat3f = matrix_float3x3

extension mat3f {
    public var x: vec3f {
        get {
            columns.0
        }
        set {
            columns.0 = newValue
        }
    }

    public var y: vec3f {
        get {
            columns.1
        }
        set {
            columns.1 = newValue
        }
    }

    public var z: vec3f {
        get {
            columns.2
        }
        set {
            columns.2 = newValue
        }
    }
}

public let identity3x3f = mat3f(
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1]
)

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat3f) -> vec3f {
    [a.x.x, a.y.y, a.z.z]
}

@inlinable
func transpose(_ a: mat3f) -> mat3f {
    a.transpose
}

// Matrix adjoints, determinants and inverses.
@inlinable
func determinant(_ a: mat3f) -> Float {
    a.determinant
}

@inlinable
func adjoint(_ a: mat3f) -> mat3f {
    transpose(mat3f(cross(a.y, a.z), cross(a.z, a.x), cross(a.x, a.y)))
}

@inlinable
func inverse(_ a: mat3f) -> mat3f {
    a.inverse
}

// Constructs a basis from a direction
@inlinable
func basis_fromz(_ v: vec3f) -> mat3f {
    // https://graphics.pixar.com/library/OrthonormalB/paper.pdf
    let z = normalize(v)
    let sign = copysignf(1.0, z.z)
    let a = -1.0 / (sign + z.z)
    let b = z.x * z.y * a
    let x = vec3f(1.0 + sign * z.x * z.x * a, sign * b, -sign * z.x)
    let y = vec3f(b, sign + z.y * z.y * a, -z.y)
    return mat3f(x, y, z)
}
