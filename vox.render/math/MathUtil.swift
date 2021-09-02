//
//  MathUtil.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Common utility methods for math operations.
class MathUtil {
    /// The conversion factor that radian to degree.
    static let radToDegreeFactor: Float = 180 / Float.pi
    /// The conversion factor that degree to radian.
    static let degreeToRadFactor: Float = Float.pi / 180

    /// Determines whether the specified v is pow2.
    /// - Parameter v: The specified v
    /// - Returns: True if the specified v is pow2, false otherwise
    static func isPowerOf2(v: Int) -> Bool {
        (v & (v - 1)) == 0
    }

    /// Modify the specified r from radian to degree.
    /// - Parameter r: The specified r
    /// - Returns: The degree value
    static func radianToDegree(r: Float) -> Float {
        r * MathUtil.radToDegreeFactor
    }

    /// Modify the specified d from degree to radian.
    /// - Parameter d: The specified d
    /// - Returns: The radian value
    static func degreeToRadian(d: Float) -> Float {
        d * MathUtil.degreeToRadFactor
    }
}
