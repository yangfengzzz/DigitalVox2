//
//  bbox2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation


// Axis aligned bounding box represented as a min/max vector pairs.
public struct bbox2f {
    public var min: vec2f
    public var max: vec2f

    public init(_ min: vec2f = vec2f(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude),
                _ max: vec2f = vec2f(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)) {
        self.min = min
        self.max = max
    }

    subscript(i: Int) -> vec2f {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}

public let invalidb2f = bbox2f()

// Bounding box properties
@inlinable
func center(_ a: bbox2f) -> vec2f {
    fatalError()
}

@inlinable
func size(_ a: bbox2f) -> vec2f {
    fatalError()
}

// Bounding box comparisons.
@inlinable
func ==(_ a: bbox2f, _ b: bbox2f) -> Bool {
    fatalError()
}

@inlinable
func !=(_ a: bbox2f, _  b: bbox2f) -> Bool {
    fatalError()
}

// Bounding box expansions with points and other boxes.
@inlinable
func merge(_ a: bbox2f, _ b: vec2f) -> bbox2f {
    fatalError()
}

@inlinable
func merge(_ a: bbox2f, _ b: bbox2f) -> bbox2f {
    fatalError()
}

@inlinable
func expand(_ a: bbox2f, _ b: vec2f) {
    fatalError()
}

@inlinable
func expand(_ a: bbox2f, _ b: bbox2f) {
    fatalError()
}
