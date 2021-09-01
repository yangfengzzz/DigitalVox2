//
//  Matrix3x3.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Represents a 3x3 mathematical matrix.
class Matrix3x3 {
    var elements: simd_float3x3

    /// Constructor of 3*3 matrix.
    /// - Parameters:
    ///   - m11: Default 1 column 1, row 1
    ///   - m12: Default 0 column 1, row 2
    ///   - m13: Default 0 column 1, row 3
    ///   - m21: Default 0 column 2, row 1
    ///   - m22: Default 1 column 2, row 2
    ///   - m23: Default 0 column 2, row 3
    ///   - m31: Default 0 column 3, row 1
    ///   - m32: Default 0 column 3, row 2
    ///   - m33: Default 1 column 3, row 3
    init(m11: Float = 1, m12: Float = 0, m13: Float = 0,
         m21: Float = 0, m22: Float = 1, m23: Float = 0,
         m31: Float = 0, m32: Float = 0, m33: Float = 1) {
        elements = simd_float3x3([SIMD3<Float>(m11, m12, m13),
                                  SIMD3<Float>(m21, m22, m23),
                                  SIMD3<Float>(m31, m32, m33)])
    }
}

extension Matrix3x3: IClone {
    typealias Object = Matrix3x3

    func clone() -> Matrix3x3 {
        let ret = Matrix3x3()
        ret.elements = elements
        return ret
    }

    func cloneTo(target: Matrix3x3) {
        target.elements = elements
    }
}
