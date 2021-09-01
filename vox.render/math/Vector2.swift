//
//  Vector2.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Describes a 2D-vector.
class Vector2 {
    /// An array containing the elements of the vector
    var elements: SIMD2<Float>

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

    /// Constructor of Vector2.
    /// - Parameters:
    ///   - x: The x component of the vector, default 0
    ///   - y: The y component of the vector, default 0
    init(_ x: Float = 0, _ y: Float = 0) {
        elements = SIMD2<Float>(x, y)
    }

    static internal let _zero = Vector2(0.0, 0.0)
    static internal let _one = Vector2(1.0, 1.0)
}

extension Vector2: IClone {
    typealias Object = Vector2

    func clone() -> Vector2 {
        Vector2(x, y)

    }

    func cloneTo(target: Vector2) {
        target.x = x
        target.y = y
    }
}

//MARK:- Static Methods
extension Vector2 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    ///   - out: The sum of two vectors
    static func add(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = left.elements + right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    ///   - out: The difference between two vectors
    static func subtract(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = left.elements - right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    ///   - out: The product of two vectors
    static func multiply(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = left.elements * right.elements
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    ///   - out: The divisor of two vectors
    static func divide(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = left.elements / right.elements
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    static func dot(left: Vector2, right: Vector2) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    static func distance(left: Vector2, right: Vector2) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    static func distanceSquared(left: Vector2, right: Vector2) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    static func equals(left: Vector2, right: Vector2) -> Bool {
        left.elements == right.elements
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    ///   - out: The result of linear blending between two vectors
    static func lerp(left: Vector2, right: Vector2, t: Float, out: Vector2) {
        let x = left.x
        let y = left.y
        out.x = x + (right.x - x) * t
        out.y = y + (right.y - y) * t
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - out: The vector containing the largest components of the specified vectors
    static func max(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = simd_max(left.elements, right.elements)
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - out: The vector containing the smallest components of the specified vectors
    static func min(left: Vector2, right: Vector2, out: Vector2) {
        out.elements = simd_min(left.elements, right.elements)
    }

    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    ///   - out: The vector facing in the opposite direction
    static func negate(left: Vector2, out: Vector2) {
        out.elements = -left.elements
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    ///   - out: The normalized vector
    static func normalize(left: Vector2, out: Vector2) {
        out.elements = simd_normalize(left.elements)
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    ///   - out: The scaled vector
    static func scale(left: Vector2, s: Float, out: Vector2) {
        out.elements = left.elements * s
    }
}

//MARK:- Class Method
extension Vector2 {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    /// - Returns: This vector
    func setValue(x: Float, y: Float) -> Vector2 {
        self.x = x
        self.y = y
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    func setValueByArray(array: Array<Float>, offset: Int = 0) -> Vector2 {
        x = array[offset]
        y = array[offset + 1]
        return self
    }

    /// Determines the sum of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func add(right: Vector2) -> Vector2 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func subtract(right: Vector2) -> Vector2 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func multiply(right: Vector2) -> Vector2 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    func divide(right: Vector2) -> Vector2 {
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
    func negate() -> Vector2 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    func normalize() -> Vector2 {
        elements = simd_normalize(elements)
        return self
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    func scale(s: Float) -> Vector2 {
        elements *= s
        return self
    }
}
