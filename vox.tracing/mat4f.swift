//
//  mat4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias mat4f = matrix_float4x4

let identity4x4f = mat4f(
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
);

// Matrix diagonals and transposes.
@inlinable
func diagonal(_ a: mat4f) -> vec4f {
    fatalError("TODO")
}

@inlinable
func transpose(_ a: mat4f) -> mat4f {
    fatalError("TODO")
}
