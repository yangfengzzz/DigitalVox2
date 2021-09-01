//
//  Matrix.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Represents a 4x4 mathematical matrix.
class Matrix {
    /// An array containing the elements of the matrix (column matrix).
    /// - Remark:
    var elements: simd_float4x4

    /// Constructor of 4x4 Matrix.
    /// - Parameters:
    ///   - m11: default 1, column 1, row 1
    ///   - m12: default 0, column 1, row 2
    ///   - m13: default 0, column 1, row 3
    ///   - m14: default 0, column 1, row 4
    ///   - m21: default 0, column 2, row 1
    ///   - m22: default 1, column 2, row 2
    ///   - m23: default 0, column 2, row 3
    ///   - m24: default 0, column 2, row 4
    ///   - m31: default 0, column 3, row 1
    ///   - m32: default 0, column 3, row 2
    ///   - m33: default 1, column 3, row 3
    ///   - m34: default 0, column 3, row 4
    ///   - m41: default 0, column 4, row 1
    ///   - m42: default 0, column 4, row 2
    ///   - m43: default 0, column 4, row 3
    ///   - m44: default 1, column 4, row 4
    init(_ m11: Float = 1, _ m12: Float = 0, _ m13: Float = 0, _ m14: Float = 0,
         _ m21: Float = 0, _ m22: Float = 1, _ m23: Float = 0, _ m24: Float = 0,
         _ m31: Float = 0, _ m32: Float = 0, _ m33: Float = 1, _ m34: Float = 0,
         _ m41: Float = 0, _ m42: Float = 0, _ m43: Float = 0, _ m44: Float = 1) {
        elements = simd_float4x4([SIMD4<Float>(m11, m12, m13, m14),
                                  SIMD4<Float>(m21, m22, m23, m24),
                                  SIMD4<Float>(m31, m32, m33, m34),
                                  SIMD4<Float>(m41, m42, m43, m44)])
    }

    private static let _tempVec30: Vector3 = Vector3()
    private static let _tempVec31: Vector3 = Vector3()
    private static let _tempVec32: Vector3 = Vector3()
    private static let _tempMat30: Matrix3x3 = Matrix3x3()

    /// Identity matrix.
    static internal let _identity: Matrix = Matrix(
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
    )
}

extension Matrix: IClone {
    typealias Object = Matrix

    func clone() -> Matrix {
        let ret = Matrix()
        ret.elements = elements
        return ret
    }

    func cloneTo(target: Matrix) {
        target.elements = elements
    }
}

extension Matrix {
    /// Determines the product of two matrices.
    /// - Parameters:
    ///   - left: The first matrix to multiply
    ///   - right: The second matrix to multiply
    ///   - out: The product of the two matrices
    static func multiply(left: Matrix, right: Matrix, out: Matrix) {
        out.elements = left.elements * right.elements
    }

    /// Determines whether the specified matrices are equals.
    /// - Parameters:
    ///   - left: The first matrix to compare
    ///   - right: The second matrix to compare
    /// - Returns: True if the specified matrices are equals, false otherwise
    static func equals(left: Matrix, right: Matrix) -> Bool {
        left.elements == right.elements
    }

    /// Performs a linear interpolation between two matrices.
    /// - Parameters:
    ///   - start: The first matrix
    ///   - end: The second matrix
    ///   - t: The blend amount where 0 returns start and 1 end
    ///   - out: The result of linear blending between two matrices
    static func lerp(start: Matrix, end: Matrix, t: Float, out: Matrix) {
        out.elements = simd_linear_combination(1 - t, start.elements, t, end.elements)
    }
}
