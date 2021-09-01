//
//  Quaternion.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Represents a four dimensional mathematical quaternion.
class Quaternion {
    var element: simd_quatf

    var x: Float {
        get {
            element.imag.x
        }
        set {
            element.imag.x = newValue
        }
    }

    var y: Float {
        get {
            element.imag.y
        }
        set {
            element.imag.y = newValue
        }
    }

    var z: Float {
        get {
            element.imag.z
        }
        set {
            element.imag.z = newValue
        }
    }

    var w: Float {
        get {
            element.real
        }
        set {
            element.real = newValue
        }
    }

    /// Constructor of Quaternion.
    /// - Parameters:
    ///   - x: The x component of the quaternion, default 0
    ///   - y: The y component of the quaternion, default 0
    ///   - z: The z component of the quaternion, default 0
    ///   - w: The w component of the quaternion, default 1
    init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, _ w: Float = 1) {
        element = simd_quatf(ix: x, iy: y, iz: z, r: w)
    }

    static internal let _tempVector3 = Vector3()
}

extension Quaternion:IClone {
    typealias Object = Quaternion
    
    func clone() -> Quaternion {
        Quaternion(x, y, z, w)
    }
    
    func cloneTo(target: Quaternion) {
        target.x = x
        target.y = y
        target.z = z
        target.w = w
    }
}
