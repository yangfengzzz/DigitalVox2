//
//  mat2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat2f = matrix_float2x2

let identity2x2f = mat2f(
        [1, 0],
        [0, 1]
);

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat2f) -> vec2f {
    fatalError("TODO")
}

@inlinable
func transpose(_ a: mat2f) -> mat2f {
    fatalError("TODO")
}

// Matrix adjoints, determinants and inverses.
@inlinable
func determinant(_ a: mat2f) -> Float {
    fatalError("TODO")
}

@inlinable
func adjoint(_ a: mat2f) -> mat2f {
    fatalError("TODO")
}

@inlinable
func inverse(_ a: mat2f) -> mat2f {
    fatalError("TODO")
}
