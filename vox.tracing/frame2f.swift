//
//  frame2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Rigid frames stored as a column-major affine transform matrix.
public struct frame2f {
    public var x = vec2f(1, 0)
    public var y = vec2f(0, 1)
    public var o = vec2f(0, 0)

    public init(_ x: vec2f, _ y: vec2f, _ o: vec2f) {
        self.x = x
        self.y = y
        self.o = o
    }

    subscript(i: Int) -> vec2f {
        get {
            switch i {
            case 0:return x
            case 1:return y
            case 2:return o
            default:fatalError()
            }
        }
        set {
            switch i {
            case 0:return x = newValue
            case 1:return y = newValue
            case 2:return o = newValue
            default:fatalError()
            }
        }
    }
}

let identity2x3f = frame2f([1, 0], [0, 1], [0, 0])

// Frame properties
@inlinable
func rotation(_ a: frame2f) -> mat2f {
    mat2f(a.x, a.y)
}

@inlinable
func translation(_ a: frame2f) -> vec2f {
    a.o
}

// Frame construction
@inlinable
func make_frame(_ m: mat2f, _ t: vec2f) -> frame2f {
    frame2f(m.x, m.y, t)
}

// Conversion between frame and mat
@inlinable
func frame_to_mat(_ f: frame2f) -> mat3f {
    mat3f([f.x.x, f.x.y, 0], [f.y.x, f.y.y, 0], [f.o.x, f.o.y, 1])
}

@inlinable
func mat_to_frame(_ m: mat3f) -> frame2f {
    frame2f([m.x.x, m.x.y], [m.y.x, m.y.y], [m.z.x, m.z.y])
}

// Frame comparisons.
@inlinable
func ==(_ a: frame2f, _ b: frame2f) -> Bool {
    a.x == b.x && a.y == b.y && a.o == b.o
}

@inlinable
func !=(_ a: frame2f, _ b: frame2f) -> Bool {
    !(a == b)
}

// Frame composition, equivalent to affine matrix product.
@inlinable
func *(_ a: frame2f, _ b: frame2f) -> frame2f {
    make_frame(rotation(a) * rotation(b), rotation(a) * b.o + a.o)
}

@inlinable
func *=(_ a: inout frame2f, _ b: frame2f) -> frame2f {
    a = a * b
    return a
}

// Frame inverse, equivalent to rigid affine inverse.
@inlinable
func inverse(_ a: frame2f, _  non_rigid: Bool = false) -> frame2f {
    if (non_rigid) {
        let minv = inverse(rotation(a))
        return make_frame(minv, -(minv * a.o))
    } else {
        let minv = transpose(rotation(a))
        return make_frame(minv, -(minv * a.o))
    }
}
