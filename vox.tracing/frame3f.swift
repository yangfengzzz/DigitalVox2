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
