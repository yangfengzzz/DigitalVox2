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

public let invalidb2f = bbox2f()

// Bounding box properties
@inlinable
func center(_ a: bbox2f) -> vec2f {
    (a.min + a.max) / 2
}

@inlinable
func size(_ a: bbox2f) -> vec2f {
    a.max - a.min
}

// Bounding box comparisons.
@inlinable
func ==(_ a: bbox2f, _ b: bbox2f) -> Bool {
    a.min == b.min && a.max == b.max
}

@inlinable
func !=(_ a: bbox2f, _  b: bbox2f) -> Bool {
    a.min != b.min || a.max != b.max
}

// Bounding box expansions with points and other boxes.
@inlinable
func merge(_ a: bbox2f, _ b: vec2f) -> bbox2f {
    bbox2f(min(a.min, b), max(a.max, b))
}

@inlinable
func merge(_ a: bbox2f, _ b: bbox2f) -> bbox2f {
    bbox2f(min(a.min, b.min), max(a.max, b.max))
}

@inlinable
func expand(_ a: inout bbox2f, _ b: vec2f) {
    a = merge(a, b)
}

@inlinable
func expand(_ a: inout bbox2f, _ b: bbox2f) {
    a = merge(a, b)
}
