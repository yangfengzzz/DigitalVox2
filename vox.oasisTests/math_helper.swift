//
//  math_helper.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

let kFloatNearTolerance: Float = 1e-5
let kFloatNearEstTolerance: Float = 1e-3

// Implements "float near" test as a function. Avoids overloading compiler
// optimizer when too much EXPECT_NEAR are used in a single compilation unit.
func ExpectFloatNear(_ _a: Float, _ _b: Float,
                     _ _tol: Float = kFloatNearTolerance) {
    XCTAssertEqual(_a, _b, accuracy: _tol)
}

// Implements "int equality" test as a function. Avoids overloading compiler
// optimizer when too much EXPECT_TRUE are used in a single compilation unit.
func ExpectIntEq(_ _a: Int32, _ _b: Int32) {
    XCTAssertEqual(_a, _b)
}

// Implements "bool equality" test as a function. Avoids overloading compiler
// optimizer when too much EXPECT_TRUE are used in a single compilation unit.
func ExpectTrue(_ _b: Bool) {
    XCTAssertTrue(_b)
}

func EXPECT_FLOAT4_EQ(_ _expected: VecFloat4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    ExpectFloatNear(_expected.x, _x)
    ExpectFloatNear(_expected.y, _y)
    ExpectFloatNear(_expected.z, _z)
    ExpectFloatNear(_expected.w, _w)
}

func EXPECT_FLOAT3_EQ(_ _expected: VecFloat3, _ _x: Float, _ _y: Float, _ _z: Float) {
    ExpectFloatNear(_expected.x, _x)
    ExpectFloatNear(_expected.y, _y)
    ExpectFloatNear(_expected.z, _z)
}

func EXPECT_FLOAT2_EQ(_ _expected: VecFloat2, _ _x: Float, _ _y: Float) {
    ExpectFloatNear(_expected.x, _x)
    ExpectFloatNear(_expected.y, _y)
}

func EXPECT_QUATERNION_EQ(_ _expected: VecQuaternion, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    ExpectFloatNear(_expected.x, _x)
    ExpectFloatNear(_expected.y, _y)
    ExpectFloatNear(_expected.z, _z)
    ExpectFloatNear(_expected.w, _w)
}

func _IMPL_EXPECT_SIMDFLOAT_EQ_TOL(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float, _ _tol: Float) {
    ExpectFloatNear(_expected.x, _x, _tol)
    ExpectFloatNear(_expected.y, _y, _tol)
    ExpectFloatNear(_expected.z, _z, _tol)
    ExpectFloatNear(_expected.w, _w, _tol)
}

func _IMPL_EXPECT_SIMDFLOAT_EQ(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_TOL(_expected, _x, _y, _z, _w, kFloatNearTolerance)
}

func _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_TOL(_expected, _x, _y, _z, _w, kFloatNearEstTolerance)
}

func EXPECT_SIMDFLOAT_EQ(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected, _x, _y, _z, _w)
}

func EXPECT_SIMDFLOAT_EQ_EST(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected, _x, _y, _z, _w)
}

func _IMPL_EXPECT_SIMDFLOAT2_EQ_TOL(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _tol: Float) {
    ExpectFloatNear(_expected.x, _x, _tol)
    ExpectFloatNear(_expected.y, _y, _tol)
}

func EXPECT_SIMDFLOAT2_EQ_EST(_ _expected: simd_float4, _ _x: Float, _ _y: Float) {
    _IMPL_EXPECT_SIMDFLOAT2_EQ_TOL(_expected, _x, _y, kFloatNearEstTolerance)
}

func _IMPL_EXPECT_SIMDFLOAT3_EQ_TOL(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float, _ _tol: Float) {
    ExpectFloatNear(_expected.x, _x, _tol)
    ExpectFloatNear(_expected.y, _y, _tol)
    ExpectFloatNear(_expected.z, _z, _tol)
}

func EXPECT_SIMDFLOAT3_EQ(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float) {
    _IMPL_EXPECT_SIMDFLOAT3_EQ_TOL(_expected, _x, _y, _z, kFloatNearTolerance)
}

func EXPECT_SIMDFLOAT3_EQ_EST(_ _expected: simd_float4, _ _x: Float, _ _y: Float, _ _z: Float) {
    _IMPL_EXPECT_SIMDFLOAT3_EQ_TOL(_expected, _x, _y, _z, kFloatNearEstTolerance)
}

func EXPECT_SIMDINT_EQ(_ _expected: SimdInt4, _ _x: Int32, _ _y: Int32, _ _z: Int32, _ _w: Int32) {
    ExpectIntEq(getX(_expected), _x)
    ExpectIntEq(getY(_expected), _y)
    ExpectIntEq(getZ(_expected), _z)
    ExpectIntEq(getW(_expected), _w)
}

func EXPECT_FLOAT4x4_EQ(_ _expected: simd_float4x4,
                        _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                        _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                        _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float,
                        _ _w0: Float, _ _w1: Float, _ _w2: Float, _ _w3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.columns.0, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.columns.1, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.columns.2, _z0, _z1, _z2, _z3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.columns.3, _w0, _w1, _w2, _w3)
}

func EXPECT_SIMDQUATERNION_EQ(_ _expected: SimdQuaternion, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.xyzw, _x, _y, _z, _w)
}

func EXPECT_SIMDQUATERNION_EQ_EST(_ _expected: SimdQuaternion, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.xyzw, _x, _y, _z, _w)
}

func EXPECT_SIMDQUATERNION_EQ_TOL(_ _expected: SimdQuaternion, _ _x: Float, _ _y: Float, _ _z: Float, _ _w: Float, _ _tol: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_TOL(_expected.xyzw, _x, _y, _z, _w, _tol)
}

func EXPECT_SOAFLOAT4_EQ(_ _expected: SoaFloat4,
                         _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                         _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                         _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float,
                         _ _w0: Float, _ _w1: Float, _ _w2: Float, _ _w3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.y, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.z, _z0, _z1, _z2, _z3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.w, _w0, _w1, _w2, _w3)
}

func EXPECT_SOAFLOAT3_EQ(_ _expected: SoaFloat3,
                         _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                         _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                         _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.y, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.z, _z0, _z1, _z2, _z3)
}

func EXPECT_SOAFLOAT3_EQ_EST(_ _expected: SoaFloat3,
                             _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                             _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                             _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.y, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.z, _z0, _z1, _z2, _z3)
}

func EXPECT_SOAFLOAT2_EQ(_ _expected: SoaFloat2,
                         _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                         _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.y, _y0, _y1, _y2, _y3)
}

func EXPECT_SOAFLOAT1_EQ(_ _expected: simd_float4,
                         _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected, _x0, _x1, _x2, _x3)
}

func EXPECT_SOAQUATERNION_EQ(_ _expected: SoaQuaternion,
                             _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                             _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                             _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float,
                             _ _w0: Float, _ _w1: Float, _ _w2: Float, _ _w3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.y, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.z, _z0, _z1, _z2, _z3)
    _IMPL_EXPECT_SIMDFLOAT_EQ(_expected.w, _w0, _w1, _w2, _w3)
}

func EXPECT_SOAQUATERNION_EQ_EST(_ _expected: SoaQuaternion,
                                 _ _x0: Float, _ _x1: Float, _ _x2: Float, _ _x3: Float,
                                 _ _y0: Float, _ _y1: Float, _ _y2: Float, _ _y3: Float,
                                 _ _z0: Float, _ _z1: Float, _ _z2: Float, _ _z3: Float,
                                 _ _w0: Float, _ _w1: Float, _ _w2: Float, _ _w3: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.x, _x0, _x1, _x2, _x3)
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.y, _y0, _y1, _y2, _y3)
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.z, _z0, _z1, _z2, _z3)
    _IMPL_EXPECT_SIMDFLOAT_EQ_EST(_expected.w, _w0, _w1, _w2, _w3)
}

func EXPECT_SOAFLOAT4x4_EQ(_ expected: SoaFloat4x4,
                           _ col0xx: Float, _ col0xy: Float, _ col0xz: Float, _ col0xw: Float,
                           _ col0yx: Float, _ col0yy: Float, _ col0yz: Float, _ col0yw: Float,
                           _ col0zx: Float, _ col0zy: Float, _ col0zz: Float, _ col0zw: Float,
                           _ col0wx: Float, _ col0wy: Float, _ col0wz: Float, _ col0ww: Float,
                           _ col1xx: Float, _ col1xy: Float, _ col1xz: Float, _ col1xw: Float,
                           _ col1yx: Float, _ col1yy: Float, _ col1yz: Float, _ col1yw: Float,
                           _ col1zx: Float, _ col1zy: Float, _ col1zz: Float, _ col1zw: Float,
                           _ col1wx: Float, _ col1wy: Float, _ col1wz: Float, _ col1ww: Float,
                           _ col2xx: Float, _ col2xy: Float, _ col2xz: Float, _ col2xw: Float,
                           _ col2yx: Float, _ col2yy: Float, _ col2yz: Float, _ col2yw: Float,
                           _ col2zx: Float, _ col2zy: Float, _ col2zz: Float, _ col2zw: Float,
                           _ col2wx: Float, _ col2wy: Float, _ col2wz: Float, _ col2ww: Float,
                           _ col3xx: Float, _ col3xy: Float, _ col3xz: Float, _ col3xw: Float,
                           _ col3yx: Float, _ col3yy: Float, _ col3yz: Float, _ col3yw: Float,
                           _ col3zx: Float, _ col3zy: Float, _ col3zz: Float, _ col3zw: Float,
                           _ col3wx: Float, _ col3wy: Float, _ col3wz: Float, _ col3ww: Float) {
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.0.x, col0xx, col0xy, col0xz, col0xw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.0.y, col0yx, col0yy, col0yz, col0yw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.0.z, col0zx, col0zy, col0zz, col0zw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.0.w, col0wx, col0wy, col0wz, col0ww)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.1.x, col1xx, col1xy, col1xz, col1xw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.1.y, col1yx, col1yy, col1yz, col1yw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.1.z, col1zx, col1zy, col1zz, col1zw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.1.w, col1wx, col1wy, col1wz, col1ww)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.2.x, col2xx, col2xy, col2xz, col2xw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.2.y, col2yx, col2yy, col2yz, col2yw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.2.z, col2zx, col2zy, col2zz, col2zw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.2.w, col2wx, col2wy, col2wz, col2ww)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.3.x, col3xx, col3xy, col3xz, col3xw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.3.y, col3yx, col3yy, col3yz, col3yw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.3.z, col3zx, col3zy, col3zz, col3zw)
    _IMPL_EXPECT_SIMDFLOAT_EQ(expected.cols.3.w, col3wx, col3wy, col3wz, col3ww)
}
