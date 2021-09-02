//
//  mat2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat2f = matrix_float2x2

extension mat2f {
    public var x: vec2f {
        get {
            columns.0
        }
        set {
            columns.0 = newValue
        }
    }

    public var y: vec2f {
        get {
            columns.1
        }
        set {
            columns.1 = newValue
        }
    }
}

let identity2x2f = mat2f(
        [1, 0],
        [0, 1]
);

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat2f) -> vec2f {
    [a.x.x, a.y.y]
}

@inlinable
func transpose(_ a: mat2f) -> mat2f {
    a.transpose
}

// Matrix adjoints, determinants and inverses.
@inlinable
func determinant(_ a: mat2f) -> Float {
    a.determinant
}

@inlinable
func adjoint(_ a: mat2f) -> mat2f {
    mat2f([a.y.y, -a.x.y], [-a.y.x, a.x.x])
}

@inlinable
func inverse(_ a: mat2f) -> mat2f {
    a.inverse
}
