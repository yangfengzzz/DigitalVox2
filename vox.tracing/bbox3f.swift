//
//  bbox3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Axis aligned bounding box represented as a min/max vector pairs.
public struct bbox3f {
    public var min: vec3f
    public var max: vec3f

    public init(_ min: vec3f = vec3f(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude),
                _ max: vec3f = vec3f(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)) {
        self.min = min
        self.max = max
    }

    subscript(i: Int) -> vec3f {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}

public let invalidb3f = bbox3f()

// Bounding box properties
@inlinable
func center(_ a: bbox3f) -> vec3f {
    fatalError()
}

@inlinable
func size(_ a: bbox3f) -> vec3f {
    fatalError()
}

// Bounding box comparisons.
@inlinable
func ==(_ a: bbox3f, _ b: bbox3f) -> Bool {
    fatalError()
}

@inlinable
func !=(_ a: bbox3f, _  b: bbox3f) -> Bool {
    fatalError()
}

// Bounding box expansions with points and other boxes.
@inlinable
func merge(_ a: bbox3f, _ b: vec3f) -> bbox3f {
    fatalError()
}

@inlinable
func merge(_ a: bbox3f, _ b: bbox3f) -> bbox3f {
    fatalError()
}

@inlinable
func expand(_ a: bbox3f, _ b: vec3f) {
    fatalError()
}

@inlinable
func expand(_ a: bbox3f, _ b: bbox3f) {
    fatalError()
}
