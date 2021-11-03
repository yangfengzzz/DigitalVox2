//
//  simd_math.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

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
    static func translation(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.translation(with: _v)
    }

    /// Returns a scaling matrix that scales along _v.
    /// _v.w is ignored.
    static func scaling(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.scaling(with: _v)
    }

    /// Returns the rotation matrix built from Euler angles defined by x, y and z
    /// components of _v. Euler angles are ordered Heading, Elevation and Bank, or
    /// Yaw, Pitch and Roll. _v.w is ignored.
    static func fromEuler(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromEuler(with: _v)
    }

    /// Returns the rotation matrix built from axis defined by _axis.xyz and
    /// _angle.x
    static func fromAxisAngle(_axis: SIMD4<Float>,
                              _angle: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromAxisAngle(with: _axis, _angle)
    }

    /// Returns the rotation matrix built from quaternion defined by x, y, z and w
    /// components of _v.
    static func fromQuaternion(_v: SIMD4<Float>) -> simd_float4x4 {
        OZZFloat4x4.fromQuaternion(with: _v)
    }

    /// Returns the affine transformation matrix built from split translation,
    /// rotation (quaternion) and scale.
    static func fromAffine(_translation: SIMD4<Float>,
                           _quaternion: SIMD4<Float>,
                           _scale: SIMD4<Float>) -> simd_float4x4 {
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
func invert(_ _m: simd_float4x4, _invertible: inout SimdInt4) -> simd_float4x4 {
    OZZFloat4x4.invert(with: _m, &_invertible)
}

/// Translates matrix _m along the axis defined by _v components.
/// _v.w is ignored.
func translate(_ _m: simd_float4x4, _v: _SimdFloat4) -> simd_float4x4 {
    OZZFloat4x4.translate(with: _m, _v)
}

/// Scales matrix _m along each axis with x, y, z components of _v.
/// _v.w is ignored.
func scale(_ _m: simd_float4x4, _v: _SimdFloat4) -> simd_float4x4 {
    OZZFloat4x4.scale(with: _m, _v)
}

/// Multiply each column of matrix _m with vector _v.
func columnMultiply(_ _m: simd_float4x4, _v: _SimdFloat4) -> simd_float4x4 {
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
func toQuaternion(_ _m: simd_float4x4) -> SimdFloat4 {
    OZZFloat4x4.toQuaternion(with: _m)
}

/// Decompose a general 3D transformation matrix _m into its scalar, rotational
/// and translational components.
/// Returns false if it was not possible to decompose the matrix. This would be
/// because more than 1 of the 3 first column of _m are scaled to 0.
func toAffine(_ _m: simd_float4x4, _translation: inout SimdFloat4,
              _quaternion: inout SimdFloat4, _scale: inout SimdFloat4) -> Bool {
    OZZFloat4x4.toAffine(with: _m, &_translation, &_quaternion, &_scale)
}

/// Computes the transformation of a Float4x4 matrix and a point _p.
/// This is equivalent to multiplying a matrix by a SimdFloat4 with a w component
/// of 1.
func transformPoint(_ _m: simd_float4x4, _v: _SimdFloat4) -> SimdFloat4 {
    OZZFloat4x4.transformPoint(with: _m, _v)
}


/// Computes the transformation of a Float4x4 matrix and a vector _v.
/// This is equivalent to multiplying a matrix by a SimdFloat4 with a w component
/// of 0.
func transformVector(_ _m: simd_float4x4, _v: _SimdFloat4) -> SimdFloat4 {
    OZZFloat4x4.transformVector(with: _m, _v)
}

