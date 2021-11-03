//
//  soa_float4x4.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Declare the 4x4 soa matrix type. Uses the column major convention where the
// matrix-times-vector is written v'=Mv:
// [ m._m.cols.0.x m._m.cols.1.x m._m.cols.2.x m._m.cols.3.x ]   {v.x}
// | m._m.cols.0.y m._m.cols.1.y m._m.cols.2.y m._m.cols.3.y | * {v.y}
// | m._m.cols.0.z m._m.cols.1.y m._m.cols.2.y m._m.cols.3.y |   {v.z}
// [ m._m.cols.0.w m._m.cols.1.w m._m.cols.2.w m._m.cols.3.w ]   {v.1}
extension SoaFloat4x4 {
    // Returns the identity matrix.
    static func identity() -> SoaFloat4x4 {
        let zero = OZZFloat4.zero()
        let one = OZZFloat4.one()
        return SoaFloat4x4((
                SoaFloat4(one, zero, zero, zero),
                SoaFloat4(zero, one, zero, zero),
                SoaFloat4(zero, zero, one, zero),
                SoaFloat4(zero, zero, zero, one)
        ))
    }

    // Returns a scaling matrix that scales along _v.
    // _v.w is ignored.
    static func Scaling(_ _v: SoaFloat4) -> SoaFloat4x4 {
        let zero = OZZFloat4.zero()
        let one = OZZFloat4.one()
        return SoaFloat4x4((
                SoaFloat4(_v.x, zero, zero, zero),
                SoaFloat4(zero, _v.y, zero, zero),
                SoaFloat4(zero, zero, _v.z, zero),
                SoaFloat4(zero, zero, zero, one)
        ))
    }

    // Returns the rotation matrix built from quaternion defined by x, y, z and w
    // components of _v.
    static func FromQuaternion(_ _q: SoaQuaternion) -> SoaFloat4x4 {
        assert(OZZInt4.areAllTrue(with: IsNormalizedEst(_q)))

        let zero = OZZFloat4.zero()
        let one = OZZFloat4.one()
        let two = one + one

        let xx = _q.x * _q.x
        let xy = _q.x * _q.y
        let xz = _q.x * _q.z
        let xw = _q.x * _q.w
        let yy = _q.y * _q.y
        let yz = _q.y * _q.z
        let yw = _q.y * _q.w
        let zz = _q.z * _q.z
        let zw = _q.z * _q.w

        return SoaFloat4x4((
                SoaFloat4(one - two * (yy + zz), two * (xy + zw), two * (xz - yw), zero),
                SoaFloat4(two * (xy - zw), one - two * (xx + zz), two * (yz + xw), zero),
                SoaFloat4(two * (xz + yw), two * (yz - xw), one - two * (xx + yy), zero),
                SoaFloat4(zero, zero, zero, one)
        ))
    }

    // Returns the affine transformation matrix built from split translation,
    // rotation (quaternion) and scale.
    static func FromAffine(_ _translation: SoaFloat3,
                           _ _quaternion: SoaQuaternion,
                           _ _scale: SoaFloat3) -> SoaFloat4x4 {
        assert(OZZInt4.areAllTrue(with: IsNormalizedEst(_quaternion)))

        let zero = OZZFloat4.zero()
        let one = OZZFloat4.one()
        let two = one + one

        let xx = _quaternion.x * _quaternion.x
        let xy = _quaternion.x * _quaternion.y
        let xz = _quaternion.x * _quaternion.z
        let xw = _quaternion.x * _quaternion.w
        let yy = _quaternion.y * _quaternion.y
        let yz = _quaternion.y * _quaternion.z
        let yw = _quaternion.y * _quaternion.w
        let zz = _quaternion.z * _quaternion.z
        let zw = _quaternion.z * _quaternion.w

        return SoaFloat4x4((
                SoaFloat4(_scale.x * (one - two * (yy + zz)), _scale.x * two * (xy + zw), _scale.x * two * (xz - yw), zero),
                SoaFloat4(_scale.y * two * (xy - zw), _scale.y * (one - two * (xx + zz)), _scale.y * two * (yz + xw), zero),
                SoaFloat4(_scale.z * two * (xz + yw), _scale.z * two * (yz - xw), _scale.z * (one - two * (xx + yy)), zero),
                SoaFloat4(_translation.x, _translation.y, _translation.z, one)
        ))
    }
}

// Returns the transpose of matrix _m.
func Transpose(_ _m: SoaFloat4x4) -> SoaFloat4x4 {
    SoaFloat4x4((
            SoaFloat4(_m.cols.0.x, _m.cols.1.x, _m.cols.2.x, _m.cols.3.x),
            SoaFloat4(_m.cols.0.y, _m.cols.1.y, _m.cols.2.y, _m.cols.3.y),
            SoaFloat4(_m.cols.0.z, _m.cols.1.z, _m.cols.2.z, _m.cols.3.z),
            SoaFloat4(_m.cols.0.w, _m.cols.1.w, _m.cols.2.w, _m.cols.3.w)
    ))
}

// Returns the inverse of matrix _m.
// If _invertible is not nullptr, each component will be set to true if its
// respective matrix is invertible. If _invertible is nullptr, then an assert is
// triggered in case any of the 4 matrices isn't invertible.
func Invert(_ _m: SoaFloat4x4, _ _invertible: inout SimdInt4) -> SoaFloat4x4 {
    let a00: SimdFloat4 = _m.cols.2.z * _m.cols.3.w - _m.cols.3.z * _m.cols.2.w
    let a01: SimdFloat4 = _m.cols.2.y * _m.cols.3.w - _m.cols.3.y * _m.cols.2.w
    let a02: SimdFloat4 = _m.cols.2.y * _m.cols.3.z - _m.cols.3.y * _m.cols.2.z
    let a03: SimdFloat4 = _m.cols.2.x * _m.cols.3.w - _m.cols.3.x * _m.cols.2.w
    let a04: SimdFloat4 = _m.cols.2.x * _m.cols.3.z - _m.cols.3.x * _m.cols.2.z
    let a05: SimdFloat4 = _m.cols.2.x * _m.cols.3.y - _m.cols.3.x * _m.cols.2.y
    let a06: SimdFloat4 = _m.cols.1.z * _m.cols.3.w - _m.cols.3.z * _m.cols.1.w
    let a07: SimdFloat4 = _m.cols.1.y * _m.cols.3.w - _m.cols.3.y * _m.cols.1.w
    let a08: SimdFloat4 = _m.cols.1.y * _m.cols.3.z - _m.cols.3.y * _m.cols.1.z
    let a09: SimdFloat4 = _m.cols.1.x * _m.cols.3.w - _m.cols.3.x * _m.cols.1.w
    let a10: SimdFloat4 = _m.cols.1.x * _m.cols.3.z - _m.cols.3.x * _m.cols.1.z
    let a11: SimdFloat4 = _m.cols.1.y * _m.cols.3.w - _m.cols.3.y * _m.cols.1.w
    let a12: SimdFloat4 = _m.cols.1.x * _m.cols.3.y - _m.cols.3.x * _m.cols.1.y
    let a13: SimdFloat4 = _m.cols.1.z * _m.cols.2.w - _m.cols.2.z * _m.cols.1.w
    let a14: SimdFloat4 = _m.cols.1.y * _m.cols.2.w - _m.cols.2.y * _m.cols.1.w
    let a15: SimdFloat4 = _m.cols.1.y * _m.cols.2.z - _m.cols.2.y * _m.cols.1.z
    let a16: SimdFloat4 = _m.cols.1.x * _m.cols.2.w - _m.cols.2.x * _m.cols.1.w
    let a17: SimdFloat4 = _m.cols.1.x * _m.cols.2.z - _m.cols.2.x * _m.cols.1.z
    let a18: SimdFloat4 = _m.cols.1.x * _m.cols.2.y - _m.cols.2.x * _m.cols.1.y

    var b0x: SimdFloat4 = _m.cols.1.y * a00
    b0x -= _m.cols.1.z * a01
    b0x += _m.cols.1.w * a02
    var b1x: SimdFloat4 = -_m.cols.1.x * a00
    b1x += _m.cols.1.z * a03
    b1x -= _m.cols.1.w * a04
    var b2x: SimdFloat4 = _m.cols.1.x * a01
    b2x -= _m.cols.1.y * a03
    b2x += _m.cols.1.w * a05
    var b3x: SimdFloat4 = -_m.cols.1.x * a02
    b3x += _m.cols.1.y * a04
    b3x -= _m.cols.1.z * a05

    var b0y: SimdFloat4 = -_m.cols.0.y * a00
    b0y += _m.cols.0.z * a01
    b0y -= _m.cols.0.w * a02
    var b1y: SimdFloat4 = _m.cols.0.x * a00
    b1y -= _m.cols.0.z * a03
    b1y += _m.cols.0.w * a04
    var b2y: SimdFloat4 = -_m.cols.0.x * a01
    b2y += _m.cols.0.y * a03
    b2y -= _m.cols.0.w * a05
    var b3y: SimdFloat4 = _m.cols.0.x * a02
    b3y -= _m.cols.0.y * a04
    b3y += _m.cols.0.z * a05

    var b0z: SimdFloat4 = _m.cols.0.y * a06
    b0z -= _m.cols.0.z * a07
    b0z += _m.cols.0.w * a08
    var b1z: SimdFloat4 = -_m.cols.0.x * a06
    b1z += _m.cols.0.z * a09
    b1z -= _m.cols.0.w * a10
    var b2z: SimdFloat4 = _m.cols.0.x * a11
    b2z -= _m.cols.0.y * a09
    b2z += _m.cols.0.w * a12
    var b3z: SimdFloat4 = -_m.cols.0.x * a08
    b3z += _m.cols.0.y * a10
    b3z -= _m.cols.0.z * a12

    var b0w: SimdFloat4 = -_m.cols.0.y * a13
    b0w += _m.cols.0.z * a14
    b0w -= _m.cols.0.w * a15
    var b1w: SimdFloat4 = _m.cols.0.x * a13
    b1w -= _m.cols.0.z * a16
    b1w += _m.cols.0.w * a17
    var b2w: SimdFloat4 = -_m.cols.0.x * a14
    b2w += _m.cols.0.y * a16
    b2w -= _m.cols.0.w * a18
    var b3w: SimdFloat4 = _m.cols.0.x * a15
    b3w -= _m.cols.0.y * a17
    b3w += _m.cols.0.z * a18

    var det: SimdFloat4 = _m.cols.0.x * b0x + _m.cols.0.y * b1x
    det += _m.cols.0.z * b2x + _m.cols.0.w * b3x
    let invertible = OZZFloat4.cmpNe(with: det, OZZFloat4.zero())
    guard OZZInt4.areAllTrue(with: invertible) else {
        fatalError("Matrix is not invertible")
    }
    _invertible = invertible
    let inv_det: SimdFloat4 = OZZFloat4.select(with: invertible, OZZFloat4.rcpEstNR(with: det), OZZFloat4.zero())

    return SoaFloat4x4((
            SoaFloat4(b0x * inv_det, b0y * inv_det, b0z * inv_det, b0w * inv_det),
            SoaFloat4(b1x * inv_det, b1y * inv_det, b1z * inv_det, b1w * inv_det),
            SoaFloat4(b2x * inv_det, b2y * inv_det, b2z * inv_det, b2w * inv_det),
            SoaFloat4(b3x * inv_det, b3y * inv_det, b3z * inv_det, b3w * inv_det)
    ))
}

// Scales matrix _m along the axis defined by _v components.
// _v.w is ignored.
func Scale(_ _m: SoaFloat4x4, _ _v: SoaFloat4) -> SoaFloat4x4 {
    SoaFloat4x4((
            SoaFloat4(_m.cols.0.x * _v.x, _m.cols.0.y * _v.x,
                    _m.cols.0.z * _v.x, _m.cols.0.w * _v.x),
            SoaFloat4(_m.cols.1.x * _v.y, _m.cols.1.y * _v.y,
                    _m.cols.1.z * _v.y, _m.cols.1.w * _v.y),
            SoaFloat4(_m.cols.2.x * _v.z, _m.cols.2.y * _v.z,
                    _m.cols.2.z * _v.z, _m.cols.2.w * _v.z),
            _m.cols.3))
}

// Computes the multiplication of matrix Float4x4 and vector  _v.
func *(_m: SoaFloat4x4, _v: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(
            _m.cols.0.x * _v.x + _m.cols.1.x * _v.y + _m.cols.2.x * _v.z + _m.cols.3.x * _v.w,
            _m.cols.0.y * _v.x + _m.cols.1.y * _v.y + _m.cols.2.y * _v.z + _m.cols.3.y * _v.w,
            _m.cols.0.z * _v.x + _m.cols.1.z * _v.y + _m.cols.2.z * _v.z + _m.cols.3.z * _v.w,
            _m.cols.0.w * _v.x + _m.cols.1.w * _v.y + _m.cols.2.w * _v.z + _m.cols.3.w * _v.w)
}

// Computes the multiplication of two matrices _a and _b.
func *(_a: SoaFloat4x4, _b: SoaFloat4x4) -> SoaFloat4x4 {
    SoaFloat4x4((_a * _b.cols.0, _a * _b.cols.1, _a * _b.cols.2, _a * _b.cols.3))
}

// Computes the per element addition of two matrices _a and _b.
func +(_a: SoaFloat4x4, _b: SoaFloat4x4) -> SoaFloat4x4 {
    SoaFloat4x4((
            SoaFloat4(_a.cols.0.x + _b.cols.0.x, _a.cols.0.y + _b.cols.0.y,
                    _a.cols.0.z + _b.cols.0.z, _a.cols.0.w + _b.cols.0.w),
            SoaFloat4(_a.cols.1.x + _b.cols.1.x, _a.cols.1.y + _b.cols.1.y,
                    _a.cols.1.z + _b.cols.1.z, _a.cols.1.w + _b.cols.1.w),
            SoaFloat4(_a.cols.2.x + _b.cols.2.x, _a.cols.2.y + _b.cols.2.y,
                    _a.cols.2.z + _b.cols.2.z, _a.cols.2.w + _b.cols.2.w),
            SoaFloat4(_a.cols.3.x + _b.cols.3.x, _a.cols.3.y + _b.cols.3.y,
                    _a.cols.3.z + _b.cols.3.z, _a.cols.3.w + _b.cols.3.w)
    ))
}

// Computes the per element subtraction of two matrices _a and _b.
func -(_a: SoaFloat4x4, _b: SoaFloat4x4) -> SoaFloat4x4 {
    SoaFloat4x4((
            SoaFloat4(_a.cols.0.x - _b.cols.0.x, _a.cols.0.y - _b.cols.0.y,
                    _a.cols.0.z - _b.cols.0.z, _a.cols.0.w - _b.cols.0.w),
            SoaFloat4(_a.cols.1.x - _b.cols.1.x, _a.cols.1.y - _b.cols.1.y,
                    _a.cols.1.z - _b.cols.1.z, _a.cols.1.w - _b.cols.1.w),
            SoaFloat4(_a.cols.2.x - _b.cols.2.x, _a.cols.2.y - _b.cols.2.y,
                    _a.cols.2.z - _b.cols.2.z, _a.cols.2.w - _b.cols.2.w),
            SoaFloat4(_a.cols.3.x - _b.cols.3.x, _a.cols.3.y - _b.cols.3.y,
                    _a.cols.3.z - _b.cols.3.z, _a.cols.3.w - _b.cols.3.w)
    ))
}
