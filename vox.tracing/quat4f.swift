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
    fatalError("TODO")
}

@inlinable
func length(_  a: quat4f) -> Float {
    fatalError("TODO")
}

@inlinable
func normalize(_  a: quat4f) -> quat4f {
    fatalError("TODO")
}

@inlinable
func conjugate(_ a: quat4f) -> quat4f {
    fatalError("TODO")
}

@inlinable
func inverse(_ a: quat4f) -> quat4f {
    fatalError("TODO")
}

@inlinable
func uangle(_ a: quat4f, _ b: quat4f) -> Float {
    fatalError("TODO")
}

@inlinable
func lerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    fatalError("TODO")
}

@inlinable
func nlerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    fatalError("TODO")
}

@inlinable
func slerp(_ a: quat4f, _ b: quat4f, _ t: Float) -> quat4f {
    fatalError("TODO")
}
