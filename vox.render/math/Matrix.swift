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
    init(m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0,
         m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0,
         m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0,
         m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1) {
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
            m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0,
            m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0,
            m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
            m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0
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

//MARK:- Static Methods
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
        MathUtil.equals(left.elements.columns.0[0], right.elements.columns.0[0]) &&
                MathUtil.equals(left.elements.columns.0[1], right.elements.columns.0[1]) &&
                MathUtil.equals(left.elements.columns.0[2], right.elements.columns.0[2]) &&
                MathUtil.equals(left.elements.columns.0[3], right.elements.columns.0[3]) &&
                MathUtil.equals(left.elements.columns.1[0], right.elements.columns.1[0]) &&
                MathUtil.equals(left.elements.columns.1[1], right.elements.columns.1[1]) &&
                MathUtil.equals(left.elements.columns.1[2], right.elements.columns.1[2]) &&
                MathUtil.equals(left.elements.columns.1[3], right.elements.columns.1[3]) &&
                MathUtil.equals(left.elements.columns.2[0], right.elements.columns.2[0]) &&
                MathUtil.equals(left.elements.columns.2[1], right.elements.columns.2[1]) &&
                MathUtil.equals(left.elements.columns.2[2], right.elements.columns.2[2]) &&
                MathUtil.equals(left.elements.columns.2[3], right.elements.columns.2[3]) &&
                MathUtil.equals(left.elements.columns.3[0], right.elements.columns.3[0]) &&
                MathUtil.equals(left.elements.columns.3[1], right.elements.columns.3[1]) &&
                MathUtil.equals(left.elements.columns.3[2], right.elements.columns.3[2]) &&
                MathUtil.equals(left.elements.columns.3[3], right.elements.columns.3[3])
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

    /// Calculate a rotation matrix from a quaternion.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    ///   - out: The calculated rotation matrix
    static func rotationQuaternion(quaternion: Quaternion, out: Matrix) {
        out.elements = matrix_float4x4(quaternion.elements)
    }

    /// Calculate a matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - r: The rotation angle in radians
    ///   - out: The matrix after rotate
    static func rotationAxisAngle(axis: Vector3, r: Float, out: Matrix) {
        out.elements = matrix_float4x4(simd_quatf(angle: r, axis: axis.elements))
    }


    /// Calculate a matrix from a quaternion and a translation.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    ///   - translation: The translation used to calculate the matrix
    ///   - out: The calculated matrix
    static func rotationTranslation(quaternion: Quaternion, translation: Vector3, out: Matrix) {
        Matrix.rotationQuaternion(quaternion: quaternion, out: out)

        out.elements.columns.3[0] = translation.x
        out.elements.columns.3[1] = translation.y
        out.elements.columns.3[2] = translation.z
    }

    /// Calculate an affine matrix.
    /// - Parameters:
    ///   - scale: The scale used to calculate matrix
    ///   - rotation: The rotation used to calculate matrix
    ///   - translation: The translation used to calculate matrix
    ///   - out: The calculated matrix
    static func affineTransformation(scale: Vector3, rotation: Quaternion, translation: Vector3, out: Matrix) {
        let x = rotation.x
        let y = rotation.y
        let z = rotation.z
        let w = rotation.w
        let x2 = x + x
        let y2 = y + y
        let z2 = z + z

        let xx = x * x2
        let xy = x * y2
        let xz = x * z2
        let yy = y * y2
        let yz = y * z2
        let zz = z * z2
        let wx = w * x2
        let wy = w * y2
        let wz = w * z2
        let sx = scale.x
        let sy = scale.y
        let sz = scale.z

        out.elements.columns.0[0] = (1 - (yy + zz)) * sx
        out.elements.columns.0[1] = (xy + wz) * sx
        out.elements.columns.0[2] = (xz - wy) * sx
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = (xy - wz) * sy
        out.elements.columns.1[1] = (1 - (xx + zz)) * sy
        out.elements.columns.1[2] = (yz + wx) * sy
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = (xz + wy) * sz
        out.elements.columns.2[1] = (yz - wx) * sz
        out.elements.columns.2[2] = (1 - (xx + yy)) * sz
        out.elements.columns.2[3] = 0

        out.elements.columns.3[0] = translation.x
        out.elements.columns.3[1] = translation.y
        out.elements.columns.3[2] = translation.z
        out.elements.columns.3[3] = 1
    }

    /// Calculate a matrix from scale vector.
    /// - Parameters:
    ///   - s: The scale vector
    ///   - out: The calculated matrix
    static func scaling(s: Vector3, out: Matrix) {
        out.elements.columns.0[0] = s.x
        out.elements.columns.0[1] = 0
        out.elements.columns.0[2] = 0
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = 0
        out.elements.columns.1[1] = s.y
        out.elements.columns.1[2] = 0
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = 0
        out.elements.columns.2[1] = 0
        out.elements.columns.2[2] = s.z
        out.elements.columns.2[3] = 0

        out.elements.columns.3[0] = 0
        out.elements.columns.3[1] = 0
        out.elements.columns.3[2] = 0
        out.elements.columns.3[4] = 1
    }

    /// Calculate a matrix from translation vector.
    /// - Parameters:
    ///   - translation: The translation vector
    ///   - out: The calculated matrix
    static func translation(translation: Vector3, out: Matrix) {
        out.elements.columns.0[0] = 1
        out.elements.columns.0[1] = 0
        out.elements.columns.0[2] = 0
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = 0
        out.elements.columns.1[1] = 1
        out.elements.columns.1[2] = 0
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = 0
        out.elements.columns.2[1] = 0
        out.elements.columns.2[2] = 1
        out.elements.columns.2[3] = 0

        out.elements.columns.3[0] = translation.x
        out.elements.columns.3[1] = translation.y
        out.elements.columns.3[2] = translation.z
        out.elements.columns.3[3] = 1
    }

    /// Calculate the inverse of the specified matrix.
    /// - Parameters:
    ///   - a: The matrix whose inverse is to be calculated
    ///   - out: The inverse of the specified matrix
    static func invert(a: Matrix, out: Matrix) {
        out.elements = a.elements.inverse
    }

    /// Calculate a right-handed look-at matrix.
    /// - Parameters:
    ///   - eye: The position of the viewer's eye
    ///   - target: The camera look-at target
    ///   - up: The camera's up vector
    ///   - out: The calculated look-at matrix
    static func lookAt(eye: Vector3, target: Vector3, up: Vector3, out: Matrix) {
        let xAxis: Vector3 = Matrix._tempVec30
        let yAxis: Vector3 = Matrix._tempVec31
        let zAxis: Vector3 = Matrix._tempVec32

        Vector3.subtract(left: eye, right: target, out: zAxis)
        _ = zAxis.normalize()
        Vector3.cross(left: up, right: zAxis, out: xAxis)
        _ = xAxis.normalize()
        Vector3.cross(left: zAxis, right: xAxis, out: yAxis)

        out.elements.columns.0[0] = xAxis.x
        out.elements.columns.0[1] = yAxis.x
        out.elements.columns.0[2] = zAxis.x
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = xAxis.y
        out.elements.columns.1[1] = yAxis.y
        out.elements.columns.1[2] = zAxis.y
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = xAxis.z
        out.elements.columns.2[1] = yAxis.z
        out.elements.columns.2[2] = zAxis.z
        out.elements.columns.2[3] = 0

        out.elements.columns.3[0] = -Vector3.dot(left: xAxis, right: eye)
        out.elements.columns.3[1] = -Vector3.dot(left: yAxis, right: eye)
        out.elements.columns.3[2] = -Vector3.dot(left: zAxis, right: eye)
        out.elements.columns.3[3] = 1
    }

    /// Calculate an orthographic projection matrix.
    /// - Parameters:
    ///   - left: The left edge of the viewing
    ///   - right: The right edge of the viewing
    ///   - bottom: The bottom edge of the viewing
    ///   - top: The top edge of the viewing
    ///   - near: The depth of the near plane
    ///   - far: The depth of the far plane
    ///   - out: The calculated orthographic projection matrix
    static func ortho(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float, out: Matrix) {
        let lr = 1 / (left - right)
        let bt = 1 / (bottom - top)
        let nf = 1 / (near - far)

        out.elements.columns.0[0] = -2 * lr
        out.elements.columns.0[1] = 0
        out.elements.columns.0[2] = 0
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = 0
        out.elements.columns.1[1] = -2 * bt
        out.elements.columns.1[2] = 0
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = 0
        out.elements.columns.2[1] = 0
        out.elements.columns.2[2] = 2 * nf
        out.elements.columns.2[3] = 0

        out.elements.columns.3[0] = (left + right) * lr
        out.elements.columns.3[1] = (top + bottom) * bt
        out.elements.columns.3[2] = (far + near) * nf
        out.elements.columns.3[3] = 1
    }


    /// Calculate a perspective projection matrix.
    /// - Parameters:
    ///   - fovy: Field of view in the y direction, in radians
    ///   - aspect: Aspect ratio, defined as view space width divided by height
    ///   - near: The depth of the near plane
    ///   - far: The depth of the far plane
    ///   - out: The calculated perspective projection matrix
    static func perspective(fovy: Float, aspect: Float, near: Float, far: Float, out: Matrix) {
        let f = 1.0 / tan(fovy / 2)
        let nf = 1 / (near - far)

        out.elements.columns.0[0] = f / aspect
        out.elements.columns.0[1] = 0
        out.elements.columns.0[2] = 0
        out.elements.columns.0[3] = 0

        out.elements.columns.1[0] = 0
        out.elements.columns.1[1] = f
        out.elements.columns.1[2] = 0
        out.elements.columns.1[3] = 0

        out.elements.columns.2[0] = 0
        out.elements.columns.2[1] = 0
        out.elements.columns.2[2] = (far + near) * nf
        out.elements.columns.2[3] = -1

        out.elements.columns.3[0] = 0
        out.elements.columns.3[1] = 0
        out.elements.columns.3[2] = 2 * far * near * nf
        out.elements.columns.3[3] = 0
    }

    /// The specified matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - m: The specified matrix
    ///   - axis: The axis
    ///   - r:  The rotation angle in radians
    ///   - out: The rotated matrix
    static func rotateAxisAngle(m: Matrix, axis: Vector3, r: Float, out: Matrix) {
        out.elements = m.elements * matrix_float4x4(simd_quatf(angle: r, axis: axis.elements))
    }

    /// Scale a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - s: The given vector
    ///   - out: The scaled matrix
    static func scale(m: Matrix, s: Vector3, out: Matrix) {
        out.elements = m.elements
        out.elements.columns.0 *= s.x
        out.elements.columns.1 *= s.y
        out.elements.columns.2 *= s.z
    }


    /// Translate a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - v: The given vector
    ///   - out: The translated matrix
    static func translate(m: Matrix, v: Vector3, out: Matrix) {
        let x = v.x
        let y = v.y
        let z = v.z
        if (m === out) {
            out.elements.columns.3[0] = m.elements.columns.0[0] * x + m.elements.columns.1[0] * y + m.elements.columns.2[0] * z + m.elements.columns.3[0]
            out.elements.columns.3[1] = m.elements.columns.0[1] * x + m.elements.columns.1[1] * y + m.elements.columns.2[1] * z + m.elements.columns.3[1]
            out.elements.columns.3[2] = m.elements.columns.0[2] * x + m.elements.columns.1[2] * y + m.elements.columns.2[2] * z + m.elements.columns.3[2]
            out.elements.columns.3[3] = m.elements.columns.0[3] * x + m.elements.columns.1[3] * y + m.elements.columns.2[3] * z + m.elements.columns.3[3]
        } else {
            out.elements.columns.0 = m.elements.columns.0
            out.elements.columns.1 = m.elements.columns.1
            out.elements.columns.2 = m.elements.columns.2

            out.elements.columns.3[0] = m.elements.columns.0[0] * x + m.elements.columns.1[0] * y + m.elements.columns.2[0] * z + m.elements.columns.3[0]
            out.elements.columns.3[1] = m.elements.columns.0[1] * x + m.elements.columns.1[1] * y + m.elements.columns.2[1] * z + m.elements.columns.3[1]
            out.elements.columns.3[2] = m.elements.columns.0[2] * x + m.elements.columns.1[2] * y + m.elements.columns.2[2] * z + m.elements.columns.3[2]
            out.elements.columns.3[3] = m.elements.columns.0[3] * x + m.elements.columns.1[3] * y + m.elements.columns.2[3] * z + m.elements.columns.3[3]
        }
    }

    /// Calculate the transpose of the specified matrix.
    /// - Parameters:
    ///   - a: The specified matrix
    ///   - out: The transpose of the specified matrix
    static func transpose(a: Matrix, out: Matrix) {
        out.elements = a.elements.transpose
    }
}

//MARK:- Class Method
extension Matrix {
    /// Set the value of this matrix, and return this matrix.
    /// - Parameters:
    ///   - m11: column 1, row 1
    ///   - m12: column 1, row 2
    ///   - m13: column 1, row 3
    ///   - m14: column 1, row 4
    ///   - m21: column 2, row 1
    ///   - m22: column 2, row 2
    ///   - m23: column 2, row 3
    ///   - m24: column 2, row 4
    ///   - m31: column 3, row 1
    ///   - m32: column 3, row 2
    ///   - m33: column 3, row 3
    ///   - m34: column 3, row 4
    ///   - m41: column 4, row 1
    ///   - m42: column 4, row 2
    ///   - m43: column 4, row 3
    ///   - m44: column 4, row 4
    /// - Returns: This matrix
    func setValue(m11: Float, m12: Float, m13: Float, m14: Float,
                  m21: Float, m22: Float, m23: Float, m24: Float,
                  m31: Float, m32: Float, m33: Float, m34: Float,
                  m41: Float, m42: Float, m43: Float, m44: Float) -> Matrix {
        elements.columns.0 = SIMD4<Float>(m11, m12, m13, m14)
        elements.columns.1 = SIMD4<Float>(m21, m22, m23, m24)
        elements.columns.2 = SIMD4<Float>(m31, m32, m33, m34)
        elements.columns.3 = SIMD4<Float>(m41, m42, m43, m44)

        return self
    }


    /// Set the value of this matrix by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This matrix
    func setValueByArray(array: Array<Float>, offset: Int = 0) -> Matrix {
        var index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                elements[i, j] = array[index + offset]
                index += 1
            }
        }
        return self
    }

    /// Determines the product of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the product of the two matrices
    func multiply(right: Matrix) -> Matrix {
        Matrix.multiply(left: self, right: right, out: self)
        return self
    }

    /// Calculate a determinant of this matrix.
    /// - Returns: The determinant of this matrix
    func determinant() -> Float {
        return elements.determinant
    }


    /// Decompose this matrix to translation, rotation and scale elements.
    /// - Parameters:
    ///   - translation: Translation vector as an output parameter
    ///   - rotation: Rotation quaternion as an output parameter
    ///   - scale: Scale vector as an output parameter
    /// - Returns: True if this matrix can be decomposed, false otherwise
    func decompose(translation: Vector3, rotation: Quaternion, scale: Vector3) -> Bool {
        let rm: Matrix3x3 = Matrix._tempMat30

        let m11 = elements.columns.0[0]
        let m12 = elements.columns.0[1]
        let m13 = elements.columns.0[2]
        let m14 = elements.columns.0[3]
        let m21 = elements.columns.1[0]
        let m22 = elements.columns.1[1]
        let m23 = elements.columns.1[2]
        let m24 = elements.columns.1[3]
        let m31 = elements.columns.2[0]
        let m32 = elements.columns.2[1]
        let m33 = elements.columns.2[2]
        let m34 = elements.columns.2[3]

        translation.x = elements.columns.3[0]
        translation.y = elements.columns.3[1]
        translation.z = elements.columns.3[2]

        let xs: Float = sign(m11 * m12 * m13 * m14) < 0 ? -1 : 1
        let ys: Float = sign(m21 * m22 * m23 * m24) < 0 ? -1 : 1
        let zs: Float = sign(m31 * m32 * m33 * m34) < 0 ? -1 : 1

        let sx = xs * sqrt(m11 * m11 + m12 * m12 + m13 * m13)
        let sy = ys * sqrt(m21 * m21 + m22 * m22 + m23 * m23)
        let sz = zs * sqrt(m31 * m31 + m32 * m32 + m33 * m33)

        scale.x = sx
        scale.y = sy
        scale.z = sz

        if (abs(sx) < Float.leastNonzeroMagnitude ||
                abs(sy) < Float.leastNonzeroMagnitude ||
                abs(sz) < Float.leastNonzeroMagnitude) {
            _ = rotation.identity()
            return false
        } else {
            let invSX = 1 / sx
            let invSY = 1 / sy
            let invSZ = 1 / sz

            rm.elements.columns.0[0] = m11 * invSX
            rm.elements.columns.0[1] = m12 * invSX
            rm.elements.columns.0[2] = m13 * invSX
            rm.elements.columns.1[0] = m21 * invSY
            rm.elements.columns.1[1] = m22 * invSY
            rm.elements.columns.1[2] = m23 * invSY
            rm.elements.columns.2[0] = m31 * invSZ
            rm.elements.columns.2[1] = m32 * invSZ
            rm.elements.columns.2[2] = m33 * invSZ
            Quaternion.rotationMatrix3x3(m: rm, out: rotation)
            return true
        }
    }


    /// Get rotation from this matrix.
    /// - Parameter out: Rotation quaternion as an output parameter
    /// - Returns: The out
    func getRotation(out: Quaternion) -> Quaternion {
        out.elements = simd_quatf(elements)
        return out
    }

    /// Get scale from this matrix.
    /// - Parameter out: Scale vector as an output parameter
    /// - Returns: The out
    func getScaling(out: Vector3) -> Vector3 {
        let m11 = elements.columns.0[0]
        let m12 = elements.columns.0[1]
        let m13 = elements.columns.0[2]
        let m21 = elements.columns.1[0]
        let m22 = elements.columns.1[1]
        let m23 = elements.columns.1[2]
        let m31 = elements.columns.2[0]
        let m32 = elements.columns.2[1]
        let m33 = elements.columns.2[2]

        out.x = sqrt(m11 * m11 + m12 * m12 + m13 * m13)
        out.y = sqrt(m21 * m21 + m22 * m22 + m23 * m23)
        out.z = sqrt(m31 * m31 + m32 * m32 + m33 * m33)

        return out
    }


    /// Get translation from this matrix.
    /// - Parameter out: Translation vector as an output parameter
    /// - Returns: The out
    func getTranslation(out: Vector3) -> Vector3 {
        out.x = elements.columns.3[0]
        out.y = elements.columns.3[1]
        out.z = elements.columns.3[2]

        return out
    }

    /// Identity this matrix.
    /// - Returns: This matrix after identity
    func identity() -> Matrix {
        elements = simd_float4x4(0)
        elements.columns.0[0] = 1
        elements.columns.1[1] = 1
        elements.columns.2[2] = 1
        elements.columns.3[3] = 1

        return self
    }

    /// Invert the matrix.
    /// - Returns: The matrix after invert
    func invert() -> Matrix {
        Matrix.invert(a: self, out: self)
        return self
    }

    /// This matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - r: The rotation angle in radians
    /// - Returns: This matrix after rotate
    func rotateAxisAngle(axis: Vector3, r: Float) -> Matrix {
        Matrix.rotateAxisAngle(m: self, axis: axis, r: r, out: self)
        return self
    }

    /// Scale this matrix by a given vector.
    /// - Parameter s: The given vector
    /// - Returns: This matrix after scale
    func scale(s: Vector3) -> Matrix {
        Matrix.scale(m: self, s: s, out: self)
        return self
    }

    /// Translate this matrix by a given vector.
    /// - Parameter v: The given vector
    /// - Returns: This matrix after translate
    func translate(v: Vector3) -> Matrix {
        Matrix.translate(m: self, v: v, out: self)
        return self
    }

    /// Calculate the transpose of this matrix.
    /// - Returns: This matrix after transpose
    func transpose() -> Matrix {
        Matrix.transpose(a: self, out: self)
        return self
    }
}
