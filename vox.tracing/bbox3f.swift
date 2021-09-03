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
            switch i {
            case 0: return min
            case 1: return max
            default: fatalError()
            }
        }
        set {
            switch i {
            case 0: min = newValue
            case 1: max = newValue
            default: fatalError()
            }
        }
    }
}

public let invalidb3f = bbox3f()

// Bounding box properties
@inlinable
func center(_ a: bbox3f) -> vec3f {
    (a.min + a.max) / 2
}

@inlinable
func size(_ a: bbox3f) -> vec3f {
    a.max - a.min
}

// Bounding box comparisons.
@inlinable
func ==(_ a: bbox3f, _ b: bbox3f) -> Bool {
    a.min == b.min && a.max == b.max
}

@inlinable
func !=(_ a: bbox3f, _  b: bbox3f) -> Bool {
    a.min != b.min || a.max != b.max
}

// Bounding box expansions with points and other boxes.
@inlinable
func merge(_ a: bbox3f, _ b: vec3f) -> bbox3f {
    bbox3f(min(a.min, b), max(a.max, b))
}

@inlinable
func merge(_ a: bbox3f, _ b: bbox3f) -> bbox3f {
    bbox3f(min(a.min, b.min), max(a.max, b.max))
}

@inlinable
func expand(_ a: inout bbox3f, _ b: vec3f) {
    a = merge(a, b)
}

@inlinable
func expand(_ a: inout bbox3f, _ b: bbox3f) {
    a = merge(a, b)
}
