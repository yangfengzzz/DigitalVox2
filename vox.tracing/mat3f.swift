//
//  mat3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat3f = matrix_float3x3

let identity3x3f = mat3f(
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1]
);

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat3f) -> vec3f {
    fatalError("TODO")
}

@inlinable
func transpose(_ a: mat3f) -> mat3f {
    fatalError("TODO")
}

// Matrix adjoints, determinants and inverses.
@inlinable
func determinant(_ a: mat3f) -> Float {
    fatalError("TODO")
}

@inlinable
func adjoint(_ a: mat3f) -> mat3f {
    fatalError("TODO")
}

@inlinable
func inverse(_ a: mat3f) -> mat3f {
    fatalError("TODO")
}

// Constructs a basis from a direction
@inlinable
func basis_fromz(_ v: vec3f) -> mat3f {
    fatalError("TODO")
}
