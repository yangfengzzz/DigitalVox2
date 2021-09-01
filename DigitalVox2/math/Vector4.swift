//
//  Vector4.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Describes a 4D-vector.
class Vector4 {
    var elements: SIMD4<Float>

    var x: Float {
        get {
            elements.x
        }
        set {
            elements.x = newValue
        }
    }

    var y: Float {
        get {
            elements.y
        }
        set {
            elements.y = newValue
        }
    }

    var z: Float {
        get {
            elements.z
        }
        set {
            elements.z = newValue
        }
    }

    var w: Float {
        get {
            elements.w
        }
        set {
            elements.w = newValue
        }
    }

    /// Constructor of Vector4.
    /// - Parameters:
    ///   - x: The x component of the vector, default 0
    ///   - y: The y component of the vector, default 0
    ///   - z: The z component of the vector, default 0
    ///   - w: The w component of the vector, default 0
    init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, _ w: Float = 0) {
        elements = SIMD4<Float>(x, y, z, w)
    }

    static internal let _zero = Vector4(0.0, 0.0, 0.0, 0.0)
    static internal let _one = Vector4(1.0, 1.0, 1.0, 1.0)
}

extension Vector4: IClone {
    typealias Object = Vector4

    func clone() -> Vector4 {
        Vector4(x, y, z, w)
    }

    func cloneTo(target: Vector4) {
        target.x = x
        target.y = y
        target.z = z
        target.w = w
    }
}
