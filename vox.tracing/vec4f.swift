//
//  vec4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

public typealias vec4f = SIMD4<Float>

let zero4f = vec4f(0, 0, 0, 0)

let one4f = vec4f(1, 1, 1, 1)

@inlinable func xyz(a: vec4f) -> vec3f {
    fatalError("TODO")
}
