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

//MARK:- Static Methods
extension Vector4 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    ///   - out: The sum of two vectors
    static func add(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = left.elements + right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    ///   - out: The difference between two vectors
    static func subtract(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = left.elements - right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    ///   - out: The product of two vectors
    static func multiply(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = left.elements * right.elements
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    ///   - out: The divisor of two vectors
    static func divide(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = left.elements / right.elements
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    static func dot(left: Vector4, right: Vector4) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    static func distance(left: Vector4, right: Vector4) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    static func distanceSquared(left: Vector4, right: Vector4) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    static func equals(left: Vector4, right: Vector4) -> Bool {
        MathUtil.equals(left.x, right.x) &&
        MathUtil.equals(left.y, right.y) &&
        MathUtil.equals(left.z, right.z) &&
        MathUtil.equals(left.w, right.w)
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    ///   - out: The result of linear blending between two vectors
    static func lerp(left: Vector4, right: Vector4, t: Float, out: Vector4) {
        let x = left.x
        let y = left.y
        let z = left.z
        let w = left.w
        out.x = x + (right.x - x) * t
        out.y = y + (right.y - y) * t
        out.z = z + (right.z - z) * t
        out.w = w + (right.w - w) * t
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - out: The vector containing the largest components of the specified vectors
    static func max(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = simd_max(left.elements, right.elements)
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - out: The vector containing the smallest components of the specified vectors
    static func min(left: Vector4, right: Vector4, out: Vector4) {
        out.elements = simd_min(left.elements, right.elements)
    }

    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    ///   - out: The vector facing in the opposite direction
    static func negate(left: Vector4, out: Vector4) {
        out.elements = -left.elements
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    ///   - out: The normalized vector
    static func normalize(left: Vector4, out: Vector4) {
        out.elements = simd_normalize(left.elements)
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    ///   - out: The scaled vector
    static func scale(left: Vector4, s: Float, out: Vector4) {
        out.elements = left.elements * s
    }
}

//MARK:- Static Method: Transformation
extension Vector4 {
    /// Performs a transformation using the given 4x4 matrix.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - m: The transform matrix
    ///   - out: The transformed vector4
    static func transform(v: Vector4, m: Matrix, out: Vector4) {
        out.elements = simd_mul(m.elements, v.elements)
    }

    /// Performs a transformation using the given quaternion.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - q: The transform quaternion
    ///   - out: The transformed vector
    static func transformByQuat(v: Vector4, q: Quaternion, out: Vector4) {
        let x = v.x
        let y = v.y
        let z = v.z
        let w = v.w
        let qx = q.x
        let qy = q.y
        let qz = q.z
        let qw = q.w

        // calculate quat * vec
        let ix = qw * x + qy * z - qz * y
        let iy = qw * y + qz * x - qx * z
        let iz = qw * z + qx * y - qy * x
        let iw = -qx * x - qy * y - qz * z

        // calculate result * inverse quat
        out.x = ix * qw - iw * qx - iy * qz + iz * qy
        out.y = iy * qw - iw * qy - iz * qx + ix * qz
        out.z = iz * qw - iw * qz - ix * qy + iy * qx
        out.w = w
    }
}

//MARK:- Class Method
extension Vector4 {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    ///   - z: The z component of the vector
    /// - Returns: This vector
    func setValue(x: Float, y: Float, z: Float, w:Float) -> Vector4 {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    func setValueByArray(array: Array<Float>, offset: Int = 0) -> Vector4 {
        x = array[offset]
        y = array[offset + 1]
        z = array[offset + 2]
        w = array[offset + 3]
        return self
    }

    /// Determines the sum of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func add(right: Vector4) -> Vector4 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func subtract(right: Vector4) -> Vector4 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func multiply(right: Vector4) -> Vector4 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func divide(right: Vector4) -> Vector4 {
        elements /= right.elements
        return self
    }

    /// Calculate the length of this vector.
    /// - Returns: The length of this vector
    func length() -> Float {
        simd_length(elements)
    }

    /// Calculate the squared length of this vector.
    /// - Returns: The squared length of this vector
    func lengthSquared() -> Float {
        simd_length_squared(elements)
    }


    /// Reverses the direction of this vector.
    /// - Returns: This vector
    func negate() -> Vector4 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    func normalize() -> Vector4 {
        elements = simd_normalize(elements)
        return self
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    func scale(s: Float) -> Vector4 {
        elements *= s
        return self
    }
    
    /// Clone the value of this vector to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = x
        out[outOffset + 1] = y
        out[outOffset + 2] = z
        out[outOffset + 3] = w
    }
}
