//
//  Quaternion.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import simd

/// Represents a four dimensional mathematical quaternion.
class Quaternion {
    var elements: simd_quatf

    var x: Float {
        get {
            elements.imag.x
        }
        set {
            elements.imag.x = newValue
        }
    }

    var y: Float {
        get {
            elements.imag.y
        }
        set {
            elements.imag.y = newValue
        }
    }

    var z: Float {
        get {
            elements.imag.z
        }
        set {
            elements.imag.z = newValue
        }
    }

    var w: Float {
        get {
            elements.real
        }
        set {
            elements.real = newValue
        }
    }

    /// Constructor of Quaternion.
    /// - Parameters:
    ///   - x: The x component of the quaternion, default 0
    ///   - y: The y component of the quaternion, default 0
    ///   - z: The z component of the quaternion, default 0
    ///   - w: The w component of the quaternion, default 1
    init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, _ w: Float = 1) {
        elements = simd_quatf(ix: x, iy: y, iz: z, r: w)
    }

    static internal let _tempVector3 = Vector3()
}

extension Quaternion: IClone {
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

//MARK:- Static Methods
extension Quaternion {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    ///   - out: The sum of two vectors
    static func add(left: Quaternion, right: Quaternion, out: Quaternion) {
        out.elements = left.elements + right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    ///   - out: The product of two vectors
    static func multiply(left: Quaternion, right: Quaternion, out: Quaternion) {
        out.elements = left.elements * right.elements
    }

    /// Calculate quaternion that contains conjugated version of the specified quaternion.
    /// - Parameters:
    ///   - a: The specified quaternion
    ///   - out: The conjugate version of the specified quaternion
    static func conjugate(a: Quaternion, out: Quaternion) {
        out.elements = a.elements.conjugate
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    static func dot(left: Quaternion, right: Quaternion) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    static func equals(left: Quaternion, right: Quaternion) -> Bool {
        MathUtil.equals(left.x, right.x) &&
                MathUtil.equals(left.y, right.y) &&
                MathUtil.equals(left.z, right.z) &&
                MathUtil.equals(left.w, right.w)
    }

    /// Calculate a quaternion rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - rad: The rotation angle in radians
    ///   - out: The quaternion after rotate
    static func rotationAxisAngle(axis: Vector3, rad: Float, out: Quaternion) {
        out.elements = simd_quatf(angle: rad, axis: axis.normalize().elements)
    }

    /// Calculate a quaternion from the specified yaw, pitch and roll angles.
    /// - Parameters:
    ///   - yaw: Yaw around the y axis in radians
    ///   - pitch: Pitch around the x axis in radians
    ///   - roll: Roll around the z axis in radians
    ///   - out: The calculated quaternion
    static func rotationYawPitchRoll(yaw: Float, pitch: Float, roll: Float, out: Quaternion) {
        let halfRoll = roll * 0.5
        let halfPitch = pitch * 0.5
        let halfYaw = yaw * 0.5

        let sinRoll = sin(halfRoll)
        let cosRoll = cos(halfRoll)
        let sinPitch = sin(halfPitch)
        let cosPitch = cos(halfPitch)
        let sinYaw = sin(halfYaw)
        let cosYaw = cos(halfYaw)

        let cosYawPitch = cosYaw * cosPitch
        let sinYawPitch = sinYaw * sinPitch

        out.x = cosYaw * sinPitch * cosRoll + sinYaw * cosPitch * sinRoll
        out.y = sinYaw * cosPitch * cosRoll - cosYaw * sinPitch * sinRoll
        out.z = cosYawPitch * sinRoll - sinYawPitch * cosRoll
        out.w = cosYawPitch * cosRoll + sinYawPitch * sinRoll
    }

    /// Calculate a quaternion rotates around x, y, z axis (pitch/yaw/roll).
    /// - Parameters:
    ///   - x: The radian of rotation around X (pitch)
    ///   - y: The radian of rotation around Y (yaw)
    ///   - z: The radian of rotation around Z (roll)
    ///   - out: The calculated quaternion
    static func rotationEuler(x: Float, y: Float, z: Float, out: Quaternion) {
        Quaternion.rotationYawPitchRoll(yaw: y, pitch: x, roll: z, out: out)
    }

    /// Calculate a quaternion from the specified 3x3 matrix.
    /// - Parameters:
    ///   - m: The specified 3x3 matrix
    ///   - out: The calculated quaternion
    static func rotationMatrix3x3(m: Matrix3x3, out: Quaternion) {
        out.elements = simd_quatf(m.elements)
    }

    /// Calculate the inverse of the specified quaternion.
    /// - Parameters:
    ///   - a: The quaternion whose inverse is to be calculated
    ///   - out: The inverse of the specified quaternion
    static func invert(a: Quaternion, out: Quaternion) {
        out.elements = a.elements.inverse
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - start: The first vector
    ///   - end: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    ///   - out: The result of linear blending between two vectors
    static func lerp(start: Quaternion, end: Quaternion, t: Float, out: Quaternion) {
        let inv = 1.0 - t
        if (Quaternion.dot(left: start, right: end) >= 0) {
            out.x = start.x * inv + end.x * t
            out.y = start.y * inv + end.y * t
            out.z = start.z * inv + end.z * t
            out.w = start.w * inv + end.w * t
        } else {
            out.x = start.x * inv - end.x * t
            out.y = start.y * inv - end.y * t
            out.z = start.z * inv - end.z * t
            out.w = start.w * inv - end.w * t
        }

        _ = out.normalize()
    }

    /// Performs a spherical linear blend between two quaternions.
    /// - Parameters:
    ///   - start: The first quaternion
    ///   - end: The second quaternion
    ///   - t: The blend amount where 0 returns start and 1 end
    ///   - out: The result of spherical linear blending between two quaternions
    static func slerp(start: Quaternion, end: Quaternion, t: Float, out: Quaternion) {
        out.elements = simd_slerp(start.elements, end.elements, t)
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    ///   - out: The normalized vector
    static func normalize(left: Quaternion, out: Quaternion) {
        out.elements = simd_normalize(left.elements)
    }

    /// Calculate a quaternion rotate around X axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotationX(rad: Float, out: Quaternion) {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        out.x = s
        out.y = 0
        out.z = 0
        out.w = c
    }

    /// Calculate a quaternion rotate around Y axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotationY(rad: Float, out: Quaternion) {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        out.x = 0
        out.y = s
        out.z = 0
        out.w = c
    }

    /// Calculate a quaternion rotate around Z axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotationZ(rad: Float, out: Quaternion) {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        out.x = 0
        out.y = 0
        out.z = s
        out.w = c
    }

    /// Calculate a quaternion that the specified quaternion rotate around X axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotateX(quaternion: Quaternion, rad: Float, out: Quaternion) {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let bx = sin(rad)
        let bw = cos(rad)

        out.x = x * bw + w * bx
        out.y = y * bw + z * bx
        out.z = z * bw - y * bx
        out.w = w * bw - x * bx
    }

    /// Calculate a quaternion that the specified quaternion rotate around Y axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotateY(quaternion: Quaternion, rad: Float, out: Quaternion) {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let by = sin(rad)
        let bw = cos(rad)

        out.x = x * bw - z * by
        out.y = y * bw + w * by
        out.z = z * bw + x * by
        out.w = w * bw - y * by
    }

    /// Calculate a quaternion that the specified quaternion rotate around Z axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    ///   - out: The calculated quaternion
    static func rotateZ(quaternion: Quaternion, rad: Float, out: Quaternion) {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let bz = sin(rad)
        let bw = cos(rad)

        out.x = x * bw + y * bz
        out.y = y * bw - x * bz
        out.z = z * bw + w * bz
        out.w = w * bw - z * bz
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    ///   - out: The scaled vector
    static func scale(left: Quaternion, s: Float, out: Quaternion) {
        out.elements = left.elements * s
    }
}

extension Quaternion {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    ///   - z: The z component of the vector
    /// - Returns: This vector
    func setValue(x: Float, y: Float, z: Float, w: Float) -> Quaternion {
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
    func setValueByArray(array: Array<Float>, offset: Int = 0) -> Quaternion {
        x = array[offset]
        y = array[offset + 1]
        z = array[offset + 2]
        w = array[offset + 2]
        return self
    }

    /// Transforms this quaternion into its conjugated version.
    /// - Returns: This quaternion
    func conjugate() -> Quaternion {
        elements = elements.conjugate
        return self
    }

    /// Get the rotation axis and rotation angle of the quaternion (unit: radians).
    /// - Parameter out: The axis as an output parameter
    /// - Returns: The rotation angle (unit: radians)
    func getAxisAngle(out: Vector3) -> Float {
        out.elements = elements.axis
        return elements.angle
    }

    /// Identity this quaternion.
    /// - Returns: This quaternion after identity
    func identity() -> Quaternion {
        elements = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)

        return self
    }

    /// Calculate the length of this quaternion.
    /// - Returns: The length of this quaternion
    func length() -> Float {
        elements.length
    }

    /// Calculates the squared length of this quaternion.
    /// - Returns: The squared length of this quaternion
    func lengthSquared() -> Float {
        x * x + y * y + z * z + w * w
    }


    /// Converts this quaternion into a unit quaternion.
    /// - Returns: This quaternion
    func normalize() -> Quaternion {
        Quaternion.normalize(left: self, out: self)
        return self
    }

    /// Get the euler of this quaternion.
    /// - Parameter out: The euler (in radians) as an output parameter
    /// - Returns: Euler x->pitch y->yaw z->roll
    func toEuler(out: Vector3) -> Vector3 {
        _ = toYawPitchRoll(out: out)
        let t = out.x
        out.x = out.y
        out.y = t
        return out
    }

    /// Get the euler of this quaternion.
    /// - Parameter out: The euler (in radians) as an output parameter
    /// - Returns: Euler x->yaw y->pitch z->roll
    func toYawPitchRoll(out: Vector3) -> Vector3 {
        let xx = x * x
        let yy = y * y
        let zz = z * z
        let xy = x * y
        let zw = z * w
        let zx = z * x
        let yw = y * w
        let yz = y * z
        let xw = x * w

        out.y = asin(2.0 * (xw - yz))
        if (cos(out.y) > Float.leastNonzeroMagnitude) {
            out.z = atan2(2.0 * (xy + zw), 1.0 - 2.0 * (zz + xx))
            out.x = atan2(2.0 * (zx + yw), 1.0 - 2.0 * (yy + xx))
        } else {
            out.z = atan2(-2.0 * (xy - zw), 1.0 - 2.0 * (yy + zz))
            out.x = 0.0
        }

        return out
    }
    
    /// Clone the value of this quaternion to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = x
        out[outOffset + 1] = y
        out[outOffset + 2] = z
        out[outOffset + 3] = w
    }

    /// Calculate this quaternion rotate around X axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    func rotateX(rad: Float) -> Quaternion {
        Quaternion.rotateX(quaternion: self, rad: rad, out: self)
        return self
    }

    /// Calculate this quaternion rotate around Y axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    func rotateY(rad: Float) -> Quaternion {
        Quaternion.rotateY(quaternion: self, rad: rad, out: self)
        return self
    }

    /// Calculate this quaternion rotate around Z axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    func rotateZ(rad: Float) -> Quaternion {
        Quaternion.rotateZ(quaternion: self, rad: rad, out: self)
        return self
    }

    /// Calculate this quaternion rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - rad: The rotation angle in radians
    /// - Returns: This quaternion
    func rotationAxisAngle(axis: Vector3, rad: Float) -> Quaternion {
        Quaternion.rotationAxisAngle(axis: axis, rad: rad, out: self)
        return self
    }

    /// Determines the product of this quaternion and the specified quaternion.
    /// - Parameter quat: The specified quaternion
    /// - Returns: The product of the two quaternions
    func multiply(quat: Quaternion) -> Quaternion {
        Quaternion.multiply(left: self, right: quat, out: self)
        return self
    }
    
    /// Invert this quaternion.
    /// - Returns: This quaternion after invert
    func invert() -> Quaternion {
        Quaternion.invert(a: self, out: self)
        return self
    }

    /// Determines the dot product of this quaternion and the specified quaternion.
    /// - Parameter quat: The specified quaternion
    /// - Returns: The dot product of two quaternions
    func dot(quat: Quaternion) -> Float {
        Quaternion.dot(left: self, right: quat)
    }

    /// Performs a linear blend between this quaternion and the specified quaternion.
    /// - Parameters:
    ///   - quat: The specified quaternion
    ///   - t: The blend amount where 0 returns this and 1 quat
    /// - Returns: The result of linear blending between two quaternions
    func lerp(quat: Quaternion, t: Float) -> Quaternion {
        Quaternion.lerp(start: self, end: quat, t: t, out: self)
        return self
    }
}
