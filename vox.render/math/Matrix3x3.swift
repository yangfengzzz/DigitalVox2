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

//MARK:- Static Methods
extension Matrix3x3 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    ///   - out: The sum of two vectors
    static func add(left: Matrix3x3, right: Matrix3x3, out: Matrix3x3) {
        out.elements = left.elements + right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    ///   - out: The difference between two vectors
    static func subtract(left: Matrix3x3, right: Matrix3x3, out: Matrix3x3) {
        out.elements = left.elements - right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    ///   - out: The product of two vectors
    static func multiply(left: Matrix3x3, right: Matrix3x3, out: Matrix3x3) {
        out.elements = left.elements * right.elements
    }

    /// Determines whether the specified matrices are equals.
    /// - Parameters:
    ///   - left: The first matrix to compare
    ///   - right: The second matrix to compare
    /// - Returns: True if the specified matrices are equals, false otherwise
    static func equals(left: Matrix3x3, right: Matrix3x3) -> Bool {
        left.elements == right.elements
    }

    /// Performs a linear interpolation between two matrices.
    /// - Parameters:
    ///   - start: The first matrix
    ///   - end: The second matrix
    ///   - t: The blend amount where 0 returns start and 1 end
    ///   - out: The result of linear blending between two matrices
    static func lerp(start: Matrix3x3, end: Matrix3x3, t: Float, out: Matrix3x3) {
        out.elements = simd_linear_combination(1 - t, start.elements, t, end.elements)
    }

    /// Calculate a rotation matrix from a quaternion.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    ///   - out: The calculated rotation matrix
    static func rotationQuaternion(quaternion: Quaternion, out: Matrix3x3) {
        out.elements = matrix_float3x3(quaternion.elements)
    }

    /// Calculate a matrix from scale vector.
    /// - Parameters:
    ///   - s: The scale vector
    ///   - out: The calculated matrix
    static func scaling(s: Vector2, out: Matrix3x3) {
        out.elements = matrix_float3x3(diagonal: SIMD3<Float>(s.x, s.y, 1))
    }

    /// Calculate a matrix from translation vector.
    /// - Parameters:
    ///   - translation: The translation vector
    ///   - out: The calculated matrix
    static func translation(translation: Vector2, out: Matrix3x3) {
        out.elements = matrix_float3x3(diagonal: SIMD3<Float>(1, 1, 1))
        out.elements.columns.2[0] = translation.x
        out.elements.columns.2[1] = translation.y
    }


    /// Calculate the inverse of the specified matrix.
    /// - Parameters:
    ///   - a: The matrix whose inverse is to be calculated
    ///   - out: The inverse of the specified matrix
    static func invert(a: Matrix3x3, out: Matrix3x3) {
        out.elements = a.elements.inverse
    }

    /// Calculate a 3x3 normal matrix from a 4x4 matrix.
    /// - Remark:
    /// The calculation process is the transpose matrix of the inverse matrix.
    /// - Parameters:
    ///   - mat4: The 4x4 matrix
    ///   - out: The 3x3 normal matrix
    static func normalMatrix(mat4: Matrix, out: Matrix3x3) {
        let a11 = mat4.elements.columns.0[0]
        let a12 = mat4.elements.columns.0[1]
        let a13 = mat4.elements.columns.0[2]
        let a14 = mat4.elements.columns.0[3]
        let a21 = mat4.elements.columns.1[0]
        let a22 = mat4.elements.columns.1[1]
        let a23 = mat4.elements.columns.1[2]
        let a24 = mat4.elements.columns.1[3]
        let a31 = mat4.elements.columns.2[0]
        let a32 = mat4.elements.columns.2[1]
        let a33 = mat4.elements.columns.2[2]
        let a34 = mat4.elements.columns.2[3]
        let a41 = mat4.elements.columns.3[0]
        let a42 = mat4.elements.columns.3[1]
        let a43 = mat4.elements.columns.3[2]
        let a44 = mat4.elements.columns.3[3]

        let b00 = a11 * a22 - a12 * a21
        let b01 = a11 * a23 - a13 * a21
        let b02 = a11 * a24 - a14 * a21
        let b03 = a12 * a23 - a13 * a22
        let b04 = a12 * a24 - a14 * a22
        let b05 = a13 * a24 - a14 * a23
        let b06 = a31 * a42 - a32 * a41
        let b07 = a31 * a43 - a33 * a41
        let b08 = a31 * a44 - a34 * a41
        let b09 = a32 * a43 - a33 * a42
        let b10 = a32 * a44 - a34 * a42
        let b11 = a33 * a44 - a34 * a43

        var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
        if (det == 0) {
            return
        }
        det = 1.0 / det

        out.elements.columns.0[0] = (a22 * b11 - a23 * b10 + a24 * b09) * det
        out.elements.columns.0[1] = (a23 * b08 - a21 * b11 - a24 * b07) * det
        out.elements.columns.0[2] = (a21 * b10 - a22 * b08 + a24 * b06) * det

        out.elements.columns.1[0] = (a13 * b10 - a12 * b11 - a14 * b09) * det
        out.elements.columns.1[1] = (a11 * b11 - a13 * b08 + a14 * b07) * det
        out.elements.columns.1[2] = (a12 * b08 - a11 * b10 - a14 * b06) * det

        out.elements.columns.2[0] = (a42 * b05 - a43 * b04 + a44 * b03) * det
        out.elements.columns.2[1] = (a43 * b02 - a41 * b05 - a44 * b01) * det
        out.elements.columns.2[2] = (a41 * b04 - a42 * b02 + a44 * b00) * det
    }

    /// The specified matrix rotates around an angle.
    /// - Parameters:
    ///   - a: The specified matrix
    ///   - r: The rotation angle in radians
    ///   - out: The rotated matrix
    static func rotate(a: Matrix3x3, r: Float, out: Matrix3x3) {
        let s = sin(r)
        let c = cos(r)

        let a11 = a.elements.columns.0[0]
        let a12 = a.elements.columns.0[1]
        let a13 = a.elements.columns.0[2]
        let a21 = a.elements.columns.1[0]
        let a22 = a.elements.columns.1[1]
        let a23 = a.elements.columns.1[2]
        let a31 = a.elements.columns.2[0]
        let a32 = a.elements.columns.2[1]
        let a33 = a.elements.columns.2[2]

        out.elements.columns.0[0] = c * a11 + s * a21
        out.elements.columns.0[1] = c * a12 + s * a22
        out.elements.columns.0[2] = c * a13 + s * a23

        out.elements.columns.1[0] = c * a21 - s * a11
        out.elements.columns.1[1] = c * a22 - s * a12
        out.elements.columns.1[2] = c * a23 - s * a13

        out.elements.columns.2[0] = a31
        out.elements.columns.2[1] = a32
        out.elements.columns.2[2] = a33
    }

    /// Scale a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - s: The given vector
    ///   - out: The scaled matrix
    static func scale(m: Matrix3x3, s: Vector2, out: Matrix3x3) {
        out.elements = m.elements
        out.elements.columns.0 *= s.x
        out.elements.columns.1 *= s.y
    }

    /// Translate a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - translation: The given vector
    ///   - out: The translated matrix
    static func translate(m: Matrix3x3, translation: Vector2, out: Matrix3x3) {
        let x = translation.x
        let y = translation.y
        out.elements = m.elements

        out.elements.columns.2[0] = x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + m.elements.columns.2[0]
        out.elements.columns.2[1] = x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + m.elements.columns.2[1]
        out.elements.columns.2[2] = x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + m.elements.columns.2[2]
    }

    /// Calculate the transpose of the specified matrix.
    /// - Parameters:
    ///   - a: The specified matrix
    ///   - out: The transpose of the specified matrix
    static func transpose(a: Matrix3x3, out: Matrix3x3) {
        out.elements = a.elements.transpose
    }
}

//MARK:- Class Method
extension Matrix3x3 {
    /// Set the value of this matrix, and return this matrix.
    func setValue(m11: Float, m12: Float, m13: Float,
                  m21: Float, m22: Float, m23: Float,
                  m31: Float, m32: Float, m33: Float
    ) -> Matrix3x3 {
        elements.columns.0 = SIMD3<Float>(m11, m12, m13)
        elements.columns.1 = SIMD3<Float>(m21, m22, m23)
        elements.columns.2 = SIMD3<Float>(m31, m32, m33)

        return self
    }

    /// Set the value of this matrix by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This matrix
    func setValueByArray(array: Array<Float>, offset: Int = 0) -> Matrix3x3 {
        var index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                elements[i, j] = array[index + offset]
                index += 1
            }
        }
        return self
    }

    /// Set the value of this 3x3 matrix by the specified 4x4 matrix.
    /// - Remark: upper-left principle
    /// - Parameter a: The specified 4x4 matrix
    /// - Returns: This 3x3 matrix
    func setValueByMatrix(a: Matrix) -> Matrix3x3 {
        elements.columns.0[0] = a.elements.columns.0[0]
        elements.columns.0[1] = a.elements.columns.0[1]
        elements.columns.0[2] = a.elements.columns.0[2]

        elements.columns.1[0] = a.elements.columns.1[0]
        elements.columns.1[1] = a.elements.columns.1[1]
        elements.columns.1[2] = a.elements.columns.1[2]

        elements.columns.2[0] = a.elements.columns.2[0]
        elements.columns.2[1] = a.elements.columns.2[1]
        elements.columns.2[2] = a.elements.columns.2[2]

        return self
    }

    /// Determines the sum of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the sum of the two matrices
    func add(right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3.add(left: self, right: right, out: self)
        return self
    }

    /// Determines the difference between this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the difference between the two matrices
    func subtract(right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3.subtract(left: self, right: right, out: self)
        return self
    }

    /// Determines the product of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the product of the two matrices
    func multiply(right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3.multiply(left: self, right: right, out: self)
        return self
    }

    /// Calculate a determinant of this matrix.
    /// - Returns: The determinant of this matrix
    func determinant() -> Float {
        elements.determinant
    }

    /// Identity this matrix.
    /// - Returns: This matrix after identity
    func identity() -> Matrix3x3 {
        elements = simd_float3x3(diagonal: SIMD3<Float>(1, 1, 1))
        return self
    }

    /// Invert the matrix.
    /// - Returns: The matrix after invert
    func invert() -> Matrix3x3 {
        Matrix3x3.invert(a: self, out: self)
        return self
    }


    /// This matrix rotates around an angle.
    /// - Parameter r: The rotation angle in radians
    /// - Returns: This matrix after rotate
    func rotate(r: Float) -> Matrix3x3 {
        Matrix3x3.rotate(a: self, r: r, out: self)
        return self
    }

    /// Scale this matrix by a given vector.
    /// - Parameter s: The given vector
    /// - Returns: This matrix after scale
    func scale(s: Vector2) -> Matrix3x3 {
        Matrix3x3.scale(m: self, s: s, out: self)
        return self
    }

    /// Translate this matrix by a given vector.
    /// - Parameter translation: The given vector
    /// - Returns: This matrix after translate
    func translate(translation: Vector2) -> Matrix3x3 {
        Matrix3x3.translate(m: self, translation: translation, out: self)
        return self
    }

    /// Calculate the transpose of this matrix.
    /// - Returns: This matrix after transpose
    func transpose() -> Matrix3x3 {
        Matrix3x3.transpose(a: self, out: self)
        return self
    }
}
