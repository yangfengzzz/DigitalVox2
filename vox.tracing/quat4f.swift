//
//  quat4f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public typealias quat4f = simd_quatf

let identity_quat4f = quat4f(ix: 0, iy: 0, iz: 0, r: 1)

// Quaterion operations
@inlinable
func dot(_ a: quat4f, _  b: quat4f) -> Float {
    simd_dot(a, b)
}

@inlinable
func length(_  a: quat4f) -> Float {
    simd_length(a)
}

@inlinable
func normalize(_  a: quat4f) -> quat4f {
    simd_normalize(a)
}

@inlinable
func conjugate(_ a: quat4f) -> quat4f {
    a.conjugate
}

@inlinable
func inverse(_ a: quat4f) -> quat4f {
    a.inverse
}

@inlinable
func uangle(_ a: quat4f, _ b: quat4f) -> Float {
    let d = dot(a, b)
    return d > 1 ? 0 : acos(d < -1 ? -1 : d)
}

@inlinable
func lerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    a * (1 - t) + b * t
}

@inlinable
func nlerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    normalize(lerp(a, b, t))
}

@inlinable
func slerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    simd_slerp(a, b, t)
}
