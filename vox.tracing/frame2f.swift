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

