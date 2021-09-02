//
//  frame3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Rigid frames stored as a column-major affine transform matrix.
public struct frame3f {
    public var x = vec3f(1, 0, 0)
    public var y = vec3f(0, 1, 0)
    public var z = vec3f(0, 0, 1)
    public var o = vec3f(0, 0, 0)

    public init(_ x: vec3f, _ y: vec3f, _ z: vec3f, _ o: vec3f) {
        self.x = x
        self.y = y
        self.z = z
        self.o = o
    }

    subscript(i: Int) -> vec3f {
        get {
            switch i {
            case 0:return x
            case 1:return y
            case 2:return z
            case 3:return o
            default:fatalError()
            }
        }
        set {
            switch i {
            case 0:return x = newValue
            case 1:return y = newValue
            case 2:return z = newValue
            case 3:return o = newValue
            default:fatalError()
            }
        }
    }
}

let identity3x4f = frame3f([1, 0, 0], [0, 1, 0], [0, 0, 1], [0, 0, 0])


// Frame properties
@inlinable
func rotation(_ a: frame3f) -> mat3f {
    mat3f(a.x, a.y, a.z)
}

@inlinable
func translation(_ a: frame3f) -> vec3f {
    a.o
}

// Frame construction
@inlinable
func make_frame(_ m: mat3f, _ t: vec3f) -> frame3f {
    frame3f(m.x, m.y, m.z, t)
}

// Conversion between frame and mat
@inlinable
func frame_to_mat(_ f: frame3f) -> mat4f {
    mat4f([f.x.x, f.x.y, f.x.z, 0],
            [f.y.x, f.y.y, f.y.z, 0],
            [f.z.x, f.z.y, f.z.z, 0],
            [f.o.x, f.o.y, f.o.z, 1])
}

@inlinable
func mat_to_frame(_ m: mat4f) -> frame3f {
    frame3f([m.x.x, m.x.y, m.x.z],
            [m.y.x, m.y.y, m.y.z],
            [m.z.x, m.z.y, m.z.z],
            [m.w.x, m.w.y, m.w.z])
}

// Frame comparisons.
@inlinable
func ==(_ a: frame3f, _ b: frame3f) -> Bool {
    a.x == b.x && a.y == b.y && a.z == b.z && a.o == b.o
}

@inlinable
func !=(_ a: frame3f, _  b: frame3f) -> Bool {
    !(a == b)
}

// Frame composition, equivalent to affine matrix product.
@inlinable
func *(_ a: frame3f, _ b: frame3f) -> frame3f {
    make_frame(rotation(a) * rotation(b), rotation(a) * b.o + a.o)
}

@inlinable
func *=(_ a: inout frame3f, _ b: frame3f) -> frame3f {
    a = a * b
    return a
}

// Frame inverse, equivalent to rigid affine inverse.
@inlinable
func inverse(_ a: frame3f, _ non_rigid: Bool = false) -> frame3f {
    if (non_rigid) {
        let minv = inverse(rotation(a))
        return make_frame(minv, -(minv * a.o))
    } else {
        let minv = transpose(rotation(a))
        return make_frame(minv, -(minv * a.o))
    }
}

// Frame construction from axis.
@inlinable
func frame_from_z(_ o: vec3f, _ v: vec3f) -> frame3f {
    // https://graphics.pixar.com/library/OrthonormalB/paper.pdf
    let z = normalize(v)
    let sign = copysignf(1.0, z.z)
    let a = -1.0 / (sign + z.z)
    let b = z.x * z.y * a
    let x = vec3f(1.0 + sign * z.x * z.x * a, sign * b, -sign * z.x)
    let y = vec3f(b, sign + z.y * z.y * a, -z.y)
    return frame3f(x, y, z, o)
}

@inlinable
func frame_fromzx(_ o: vec3f, _ z_: vec3f, _ x_: vec3f) -> frame3f {
    let z = normalize(z_)
    let x = orthonormalize(x_, z)
    let y = normalize(cross(z, x))
    return frame3f(x, y, z, o)
}
