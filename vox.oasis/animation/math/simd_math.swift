//
//  simd_math.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

extension simd_float4 {
    // Returns a simd_float4 vector with all components set to 0.
    static func zero() -> simd_float4 {
        OZZFloat4.zero()
    }

    // Returns a simd_float4 vector with all components set to 1.
    static func one() -> simd_float4 {
        OZZFloat4.one()
    }

    // Returns a simd_float4 vector with the x component set to 1 and all the others to 0.
    static func x_axis() -> simd_float4 {
        OZZFloat4.x_axis()
    }

    // Returns a simd_float4 vector with the y component set to 1 and all the others to 0.
    static func y_axis() -> simd_float4 {
        OZZFloat4.y_axis()
    }

    // Returns a simd_float4 vector with the z component set to 1 and all the others to 0.
    static func z_axis() -> simd_float4 {
        OZZFloat4.z_axis()
    }

    // Returns a simd_float4 vector with the w component set to 1 and all the others to 0.
    static func w_axis() -> simd_float4 {
        OZZFloat4.w_axis()
    }

    // Loads _x, _y, _z, _w to the returned vector.
    // r.x = _x
    // r.y = _y
    // r.z = _z
    // r.w = _w
    static func load(_ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) -> simd_float4 {
        OZZFloat4.load(with: _x, _y, _z, _w)
    }

    // Loads _x to the x component of the returned vector, and sets y, z and w to 0.
    // r.x = _x
    // r.y = 0
    // r.z = 0
    // r.w = 0
    static func loadX(_ _x: Float) -> simd_float4 {
        OZZFloat4.loadX(with: _x)
    }

    // Loads _x to the all the components of the returned vector.
    // r.x = _x
    // r.y = _x
    // r.z = _x
    // r.w = _x
    static func load1(_ _x: Float) -> simd_float4 {
        OZZFloat4.load1(with: _x)
    }

    // Loads the 4 values of _f to the returned vector.
    // _f must be aligned to 16 bytes.
    // r.x = _f[0]
    // r.y = _f[1]
    // r.z = _f[2]
    // r.w = _f[3]
    static func loadPtr(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.loadPtr(with: &_f)
    }

    // Loads the 4 values of _f to the returned vector.
    // _f must be aligned to 4 bytes.
    // r.x = _f[0]
    // r.y = _f[1]
    // r.z = _f[2]
    // r.w = _f[3]
    static func loadPtrU(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.loadPtrU(with: &_f)
    }

    // Loads _f[0] to the x component of the returned vector, and sets y, z and w
    // to 0.
    // _f must be aligned to 4 bytes.
    // r.x = _f[0]
    // r.y = 0
    // r.z = 0
    // r.w = 0
    static func loadXPtrU(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.loadXPtrU(with: &_f)
    }

    // Loads _f[0] to all the components of the returned vector.
    // _f must be aligned to 4 bytes.
    // r.x = _f[0]
    // r.y = _f[0]
    // r.z = _f[0]
    // r.w = _f[0]
    static func load1PtrU(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.load1PtrU(with: &_f)
    }

    // Loads the 2 first value of _f to the x and y components of the returned
    // vector. The remaining components are set to 0.
    // _f must be aligned to 4 bytes.
    // r.x = _f[0]
    // r.y = _f[1]
    // r.z = 0
    // r.w = 0
    static func load2PtrU(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.load2PtrU(with: &_f)
    }

    // Loads the 3 first value of _f to the x, y and z components of the returned
    // vector. The remaining components are set to 0.
    // _f must be aligned to 4 bytes.
    // r.x = _f[0]
    // r.y = _f[1]
    // r.z = _f[2]
    // r.w = 0
    static func load3PtrU(_ _f: inout [Float]) -> simd_float4 {
        OZZFloat4.load3PtrU(with: &_f)
    }

    // Convert from integer to float.
    static func fromInt(_ _i: _SimdInt4) -> simd_float4 {
        OZZFloat4.fromInt(with: _i)
    }
}

// Returns the x component of _v as a float.
func getX(_ _v: simd_float4) -> Float {
    OZZFloat4.getXWith(_v)
}

// Returns the y component of _v as a float.
func getY(_ _v: simd_float4) -> Float {
    OZZFloat4.getYWith(_v)
}

// Returns the z component of _v as a float.
func getZ(_ _v: simd_float4) -> Float {
    OZZFloat4.getZWith(_v)
}

// Returns the w component of _v as a float.
func getW(_ _v: simd_float4) -> Float {
    OZZFloat4.getWWith(_v)
}

// Returns _v with the x component set to x component of _f.
func setX(_ _v: simd_float4, _ _f: simd_float4) -> simd_float4 {
    OZZFloat4.setXWith(_v, _f)
}

// Returns _v with the y component set to  x component of _f.
func setY(_ _v: simd_float4, _ _f: simd_float4) -> simd_float4 {
    OZZFloat4.setYWith(_v, _f)
}

// Returns _v with the z component set to  x component of _f.
func setZ(_ _v: simd_float4, _ _f: simd_float4) -> simd_float4 {
    OZZFloat4.setZWith(_v, _f)
}

// Returns _v with the w component set to  x component of _f.
func setW(_ _v: simd_float4, _ _f: simd_float4) -> simd_float4 {
    OZZFloat4.setWWith(_v, _f)
}

// Returns _v with the _i th component set to _f.
// _i must be in range [0,3]
func setI(_ _v: simd_float4, _ _f: simd_float4, _ _i: Int) -> simd_float4 {
    OZZFloat4.setIWith(_v, _f, Int32(_i))
}

// Stores the 4 components of _v to the four first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
// _f[3] = _v.w
func storePtr(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.storePtr(with: _v, &_f)
}

// Stores the x component of _v to the first float of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
func store1Ptr(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store1Ptr(with: _v, &_f)
}

// Stores x and y components of _v to the two first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
func store2Ptr(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store2Ptr(with: _v, &_f)
}

// Stores x, y and z components of _v to the three first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
func store3Ptr(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store3Ptr(with: _v, &_f)
}

// Stores the 4 components of _v to the four first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
// _f[3] = _v.w
func storePtrU(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.storePtrU(with: _v, &_f)
}

// Stores the x component of _v to the first float of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
func store1PtrU(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store1PtrU(with: _v, &_f)
}

// Stores x and y components of _v to the two first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
func store2PtrU(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store2PtrU(with: _v, &_f)
}

// Stores x, y and z components of _v to the three first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
func store3PtrU(_ _v: simd_float4, _ _f: inout [Float]) {
    OZZFloat4.store3PtrU(with: _v, &_f)
}

// Replicates x of _a to all the components of the returned vector.
func splatX(_ _v: simd_float4) -> simd_float4 {
    OZZFloat4.splatX(with: _v)
}

// Replicates y of _a to all the components of the returned vector.
func splatY(_ _v: simd_float4) -> simd_float4 {
    OZZFloat4.splatY(with: _v)
}

// Replicates z of _a to all the components of the returned vector.
func splatZ(_ _v: simd_float4) -> simd_float4 {
    OZZFloat4.splatZ(with: _v)
}

// Replicates w of _a to all the components of the returned vector.
func splatW(_ _v: simd_float4) -> simd_float4 {
    OZZFloat4.splatW(with: _v)
}


//MARK: - simd_float4x4
extension simd_float4x4 {
    // MARK:- Translate
    init(translation: SIMD3<Float>) {
        let matrix = float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }

    // MARK:- Scale
    init(scaling: SIMD3<Float>) {
        let matrix = float4x4(
                [scaling.x, 0, 0, 0],
                [0, scaling.y, 0, 0],
                [0, 0, scaling.z, 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }

    // MARK:- Rotate
    init(rotationX angle: Float) {
        let matrix = float4x4(
                [1, 0, 0, 0],
                [0, cos(angle), sin(angle), 0],
                [0, -sin(angle), cos(angle), 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationY angle: Float) {
        let matrix = float4x4(
                [cos(angle), 0, -sin(angle), 0],
                [0, 1, 0, 0],
                [sin(angle), 0, cos(angle), 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationZ angle: Float) {
        let matrix = float4x4(
                [cos(angle), sin(angle), 0, 0],
                [-sin(angle), cos(angle), 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotation angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }

    init(rotationYXZ angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationY * rotationX * rotationZ
    }

    /// convert double4x4 to float4x4
    init(_ m: matrix_double4x4) {
        self.init()
        let matrix: float4x4 = float4x4(SIMD4<Float>(m.columns.0),
                SIMD4<Float>(m.columns.1),
                SIMD4<Float>(m.columns.2),
                SIMD4<Float>(m.columns.3))
        self = matrix
    }

    /// Returns the identity matrix.
    static func identity() -> simd_float4x4 {
        OZZFloat4x4.identity()
    }

    /// Returns a translation matrix.
    /// _v.w is ignored.
    static func translation(_ _v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.translation(with: _v)
    }

    /// Returns a scaling matrix that scales along _v.
    /// _v.w is ignored.
    static func scaling(_ _v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.scaling(with: _v)
    }

    /// Returns the rotation matrix built from Euler angles defined by x, y and z
    /// components of _v. Euler angles are ordered Heading, Elevation and Bank, or
    /// Yaw, Pitch and Roll. _v.w is ignored.
    static func fromEuler(_ _v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromEuler(with: _v)
    }

    /// Returns the rotation matrix built from axis defined by _axis.xyz and
    /// _angle.x
    static func fromAxisAngle(_ _axis: SIMD4<Float>,
                              _ _angle: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromAxisAngle(with: _axis, _angle)
    }

    /// Returns the rotation matrix built from quaternion defined by x, y, z and w
    /// components of _v.
    static func fromQuaternion(_ _v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromQuaternion(with: _v)
    }

    /// Returns the affine transformation matrix built from split translation,
    /// rotation (quaternion) and scale.
    static func fromAffine(_ _translation: SIMD4<Float>,
                           _ _quaternion: SIMD4<Float>,
                           _ _scale: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromAffine(with: _translation, _quaternion, _scale)
    }
}

/// Returns the transpose of matrix _m.
func transpose(_ _m: simd_float4x4) -> simd_float4x4 {
    OZZFloat4x4.transpose(with: _m);
}

/// Returns the inverse of matrix _m.
/// If _invertible is not nullptr, its x component will be set to true if matrix is
/// invertible. If _invertible is nullptr, then an assert is triggered in case the
/// matrix isn't invertible.
func invert(_ _m: simd_float4x4, _ _invertible: inout SimdInt4) -> simd_float4x4 {
    OZZFloat4x4.invert(with: _m, &_invertible)
}

/// Translates matrix _m along the axis defined by _v components.
/// _v.w is ignored.
func translate(_ _m: simd_float4x4, _ _v: simd_float4) -> simd_float4x4 {
    OZZFloat4x4.translate(with: _m, _v)
}

/// Scales matrix _m along each axis with x, y, z components of _v.
/// _v.w is ignored.
func scale(_ _m: simd_float4x4, _ _v: simd_float4) -> simd_float4x4 {
    OZZFloat4x4.scale(with: _m, _v)
}

/// Multiply each column of matrix _m with vector _v.
func columnMultiply(_ _m: simd_float4x4, _ _v: simd_float4) -> simd_float4x4 {
    OZZFloat4x4.columnMultiply(with: _m, _v)
}

/// Tests if each 3 column of upper 3x3 matrix of _m is a normal matrix.
/// Returns the result in the x, y and z component of the returned vector. w is
/// set to 0.
func isNormalized(_ _m: simd_float4x4) -> SimdInt4 {
    OZZFloat4x4.isNormalized(with: _m)
}

/// Tests if each 3 column of upper 3x3 matrix of _m is a normal matrix.
/// Uses the estimated tolerance
/// Returns the result in the x, y and z component of the returned vector. w is
/// set to 0.
func isNormalizedEst(_ _m: simd_float4x4) -> SimdInt4 {
    OZZFloat4x4.isNormalizedEst(with: _m)
}

/// Tests if the upper 3x3 matrix of _m is an orthogonal matrix.
/// A matrix that contains a reflexion cannot be considered orthogonal.
/// Returns the result in the x component of the returned vector. y, z and w are
/// set to 0.
func isOrthogonal(_ _m: simd_float4x4) -> SimdInt4 {
    OZZFloat4x4.isOrthogonal(with: _m)
}

/// Returns the quaternion that represent the rotation of matrix _m.
/// _m must be normalized and orthogonal.
/// the return quaternion is normalized.
func toQuaternion(_ _m: simd_float4x4) -> simd_float4 {
    OZZFloat4x4.toQuaternion(with: _m)
}

/// Decompose a general 3D transformation matrix _m into its scalar, rotational
/// and translational components.
/// Returns false if it was not possible to decompose the matrix. This would be
/// because more than 1 of the 3 first column of _m are scaled to 0.
func toAffine(_ _m: simd_float4x4, _ _translation: inout simd_float4,
              _ _quaternion: inout simd_float4, _ _scale: inout simd_float4) -> Bool {
    OZZFloat4x4.toAffine(with: _m, &_translation, &_quaternion, &_scale)
}

/// Computes the transformation of a Float4x4 matrix and a point _p.
/// This is equivalent to multiplying a matrix by a simd_float4 with a w component
/// of 1.
func transformPoint(_ _m: simd_float4x4, _ _v: simd_float4) -> simd_float4 {
    OZZFloat4x4.transformPoint(with: _m, _v)
}


/// Computes the transformation of a Float4x4 matrix and a vector _v.
/// This is equivalent to multiplying a matrix by a simd_float4 with a w component
/// of 0.
func transformVector(_ _m: simd_float4x4, _ _v: simd_float4) -> simd_float4 {
    OZZFloat4x4.transformVector(with: _m, _v)
}

//MARK: - Math
enum math {
    // Converts from a float to a half.
    static func floatToHalf(_ _f: Float) -> UInt16 {
        OZZMath.floatToHalf(with: _f)
    }

    // Converts from a half to a float.
    static func halfToFloat(_ _h: UInt16) -> Float {
        OZZMath.halfToFloat(with: _h)
    }

    // Converts from a float to a half.
    static func floatToHalf(_ _f: simd_float4) -> SimdInt4 {
        OZZMath.floatToHalf(withSIMD: _f)
    }

    // Converts from a half to a float.
    static func halfToFloat(_ _h: _SimdInt4) -> simd_float4 {
        OZZMath.halfToFloat(withSIMD: _h)
    }
}
