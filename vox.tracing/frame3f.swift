//
//  frame3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Rigid frames stored as a column-major affine transform matrix.
public struct frame3f {
    var x = vec3f(1, 0, 0)
    var y = vec3f(0, 1, 0)
    var z = vec3f(0, 0, 1)
    var o = vec3f(0, 0, 0)

    init(_ x: vec3f, _ y: vec3f, _ z: vec3f, _ o: vec3f) {
        self.x = x
        self.y = y
        self.z = z
        self.o = o
    }

    subscript(i: Int) -> vec3f {
        get {
            fatalError("TODO")
        }
        set {
            fatalError("TODO")
        }
    }
}

let identity3x4f = frame3f([1, 0, 0], [0, 1, 0], [0, 0, 1], [0, 0, 0])


// Frame properties
@inlinable
func rotation(_ a: frame3f) -> mat3f {
    fatalError("TODO")
}

@inlinable
func translation(_ a: frame3f) -> vec3f {
    fatalError("TODO")
}

// Frame construction
@inlinable
func make_frame(_ m: mat3f, _ t: vec3f) -> frame3f {
    fatalError("TODO")
}

// Conversion between frame and mat
@inlinable
func frame_to_mat(_ f: frame3f) -> mat4f {
    fatalError("TODO")
}

@inlinable
func mat_to_frame(_ m: mat4f) -> frame3f {
    fatalError("TODO")
}

// Frame comparisons.
@inlinable
func ==(_ a: frame3f, _ b: frame3f) -> Bool {
    fatalError("TODO")
}

@inlinable
func !=(_ a: frame3f, _  b: frame3f) -> Bool {
    fatalError("TODO")
}

// Frame composition, equivalent to affine matrix product.
@inlinable
func *(_ a: frame3f, _ b: frame3f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func *=(_ a: inout frame3f, _ b: frame3f) -> frame3f {
    fatalError("TODO")
}

// Frame inverse, equivalent to rigid affine inverse.
@inlinable
func inverse(_ a: frame3f, _ non_rigid: Bool = false) -> frame3f {
    fatalError("TODO")
}

// Frame construction from axis.
@inlinable
func frame_fromz(_ o: vec3f, _ v: vec3f) -> frame3f {
    fatalError("TODO")
}

@inlinable
func frame_fromzx(_ o: vec3f, _ z_: vec3f, _ x_: vec3f) -> frame3f {
    fatalError("TODO")
}
