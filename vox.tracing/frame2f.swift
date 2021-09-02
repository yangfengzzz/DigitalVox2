//
//  frame2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Rigid frames stored as a column-major affine transform matrix.
public struct frame2f {
    var x = vec2f(1, 0)
    var y = vec2f(0, 1)
    var o = vec2f(0, 0)

    init(_ x: vec2f, _ y: vec2f, _ o: vec2f) {
        self.x = x
        self.y = y
        self.o = o
    }

    subscript(i: Int) -> vec2f {
        get {
            fatalError("TODO")
        }
        set {
            fatalError("TODO")
        }
    }
}

let identity2x3f = frame2f([1, 0], [0, 1], [0, 0])

// Frame properties
@inlinable
func rotation(_ a: frame2f) -> mat2f {
    fatalError("TODO")
}

@inlinable
func translation(_ a: frame2f) -> vec2f {
    fatalError("TODO")
}

// Frame construction
@inlinable
func make_frame(_ m: mat2f, _ t: vec2f) -> frame2f {
    fatalError("TODO")
}

// Conversion between frame and mat
@inlinable
func frame_to_mat(_ f: frame2f) -> mat3f {
    fatalError("TODO")
}

@inlinable
func mat_to_frame(_ ma: mat3f) -> frame2f {
    fatalError("TODO")
}

// Frame comparisons.
@inlinable
func ==(_ a: frame2f, _ b: frame2f) -> Bool {
    fatalError("TODO")
}

@inlinable
func !=(_ a: frame2f, _ b: frame2f) -> Bool {
    fatalError("TODO")
}

// Frame composition, equivalent to affine matrix product.
@inlinable
func *(_ a: frame2f, _ b: frame2f) -> frame2f {
    fatalError("TODO")
}

@inlinable
func *=(_ a: inout frame2f, _ b: frame2f) -> frame2f {
    fatalError("TODO")
}

// Frame inverse, equivalent to rigid affine inverse.
@inlinable
func inverse(_ a: frame2f, _  non_rigid: Bool = false) -> frame2f {
    fatalError("TODO")
}
