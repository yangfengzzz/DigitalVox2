//
//  vec_math.test.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class VecMathTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVectorLoad4() throws {
        EXPECT_FLOAT4_EQ(VecFloat4(46.0), 46.0, 46.0, 46.0, 46.0)
        EXPECT_FLOAT4_EQ(VecFloat4(-1.0, 0.0, 1.0, 2.0), -1.0, 0.0, 1.0, 2.0)
        let f3 = VecFloat3(-1.0, 0.0, 1.0)
        EXPECT_FLOAT4_EQ(VecFloat4(f3, 2.0), -1.0, 0.0, 1.0, 2.0)
        let f2 = VecFloat2(-1.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4(f2, 1.0, 2.0), -1.0, 0.0, 1.0, 2.0)
    }

    func testVectorLoad3() {
        EXPECT_FLOAT3_EQ(VecFloat3(46.0), 46.0, 46.0, 46.0)
        EXPECT_FLOAT3_EQ(VecFloat3(-1.0, 0.0, 1.0), -1.0, 0.0, 1.0)
        let f2 = VecFloat2(-1.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3(f2, 1.0), -1.0, 0.0, 1.0)
    }

    func testVectorLoad2() {
        EXPECT_FLOAT2_EQ(VecFloat2(46.0), 46.0, 46.0)
        EXPECT_FLOAT2_EQ(VecFloat2(-1.0, 0.0), -1.0, 0.0)
    }

    func testVectorConstant4() {
        EXPECT_FLOAT4_EQ(VecFloat4.zero(), 0.0, 0.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.one(), 1.0, 1.0, 1.0, 1.0)
        EXPECT_FLOAT4_EQ(VecFloat4.x_axis(), 1.0, 0.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.y_axis(), 0.0, 1.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.z_axis(), 0.0, 0.0, 1.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.w_axis(), 0.0, 0.0, 0.0, 1.0)
    }

    func testVectorConstant3() {
        EXPECT_FLOAT3_EQ(VecFloat3.zero(), 0.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.one(), 1.0, 1.0, 1.0)
        EXPECT_FLOAT3_EQ(VecFloat3.x_axis(), 1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.y_axis(), 0.0, 1.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.z_axis(), 0.0, 0.0, 1.0)
    }

    func testVectorConstant2() {
        EXPECT_FLOAT2_EQ(VecFloat2.zero(), 0.0, 0.0)
        EXPECT_FLOAT2_EQ(VecFloat2.one(), 1.0, 1.0)
        EXPECT_FLOAT2_EQ(VecFloat2.x_axis(), 1.0, 0.0)
        EXPECT_FLOAT2_EQ(VecFloat2.y_axis(), 0.0, 1.0)
    }

    func testVectorArithmetic4() {
        let a = VecFloat4(0.5, 1.0, 2.0, 3.0)
        let b = VecFloat4(4.0, 5.0, -6.0, 7.0)

        let add = a + b
        EXPECT_FLOAT4_EQ(add, 4.5, 6.0, -4.0, 10.0)

        let sub = a - b
        EXPECT_FLOAT4_EQ(sub, -3.5, -4.0, 8.0, -4.0)

        let neg = -b
        EXPECT_FLOAT4_EQ(neg, -4.0, -5.0, 6.0, -7.0)

        let mul = a * b
        EXPECT_FLOAT4_EQ(mul, 2.0, 5.0, -12.0, 21.0)

        let mul_scal = a * 2.0
        EXPECT_FLOAT4_EQ(mul_scal, 1.0, 2.0, 4.0, 6.0)

        let div = a / b
        EXPECT_FLOAT4_EQ(div, 0.5 / 4.0, 1.0 / 5.0, -2.0 / 6.0, 3.0 / 7.0)

        let div_scal = a / 2.0
        EXPECT_FLOAT4_EQ(div_scal, 0.5 / 2.0, 1.0 / 2.0, 2.0 / 2.0, 3.0 / 2.0)

        let hadd4 = hAdd(a)
        XCTAssertEqual(hadd4, 6.5)

        let dot = dot(a, b)
        XCTAssertEqual(dot, 16.0)

        let length = length(a)
        XCTAssertEqual(length, sqrt(14.25))

        let length2 = lengthSqr(a)
        XCTAssertEqual(length2, 14.25)

        XCTAssertFalse(isNormalized(a))
        let normalize = normalize(a)
        XCTAssertTrue(isNormalized(normalize))
        EXPECT_FLOAT4_EQ(normalize, 0.13245323, 0.26490647, 0.52981293, 0.79471946)

        let safe = VecFloat4(1.0, 0.0, 0.0, 0.0)
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(isNormalized(normalize_safe))
        EXPECT_FLOAT4_EQ(normalize_safe, 0.13245323, 0.26490647, 0.52981293, 0.79471946)

        let normalize_safer = normalizeSafe(VecFloat4.zero(), safe)
        XCTAssertTrue(isNormalized(normalize_safer))
        EXPECT_FLOAT4_EQ(normalize_safer, safe.x, safe.y, safe.z, safe.w)

        let lerp_0 = lerp(a, b, 0.0)
        EXPECT_FLOAT4_EQ(lerp_0, a.x, a.y, a.z, a.w)

        let lerp_1 = lerp(a, b, 1.0)
        EXPECT_FLOAT4_EQ(lerp_1, b.x, b.y, b.z, b.w)

        let lerp_0_5 = lerp(a, b, 0.5)
        EXPECT_FLOAT4_EQ(lerp_0_5, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5,
                (a.z + b.z) * 0.5, (a.w + b.w) * 0.5)

        let lerp_2 = lerp(a, b, 2.0)
        EXPECT_FLOAT4_EQ(lerp_2, 2.0 * b.x - a.x, 2.0 * b.y - a.y, 2.0 * b.z - a.z,
                2.0 * b.w - a.w)
    }

    func testVectorArithmetic3() {
        let a = VecFloat3(0.5, 1.0, 2.0)
        let b = VecFloat3(4.0, 5.0, -6.0)

        let add = a + b
        EXPECT_FLOAT3_EQ(add, 4.5, 6.0, -4.0)

        let sub = a - b
        EXPECT_FLOAT3_EQ(sub, -3.5, -4.0, 8.0)

        let neg = -b
        EXPECT_FLOAT3_EQ(neg, -4.0, -5.0, 6.0)

        let mul = a * b
        EXPECT_FLOAT3_EQ(mul, 2.0, 5.0, -12.0)

        let mul_scal = a * 2.0
        EXPECT_FLOAT3_EQ(mul_scal, 1.0, 2.0, 4.0)

        let div = a / b
        EXPECT_FLOAT3_EQ(div, 0.5 / 4.0, 1.0 / 5.0, -2.0 / 6.0)

        let div_scal = a / 2.0
        EXPECT_FLOAT3_EQ(div_scal, 0.5 / 2.0, 1.0 / 2.0, 2.0 / 2.0)

        let hadd4 = hAdd(a)
        XCTAssertEqual(hadd4, 3.5)

        let dot = dot(a, b)
        XCTAssertEqual(dot, -5.0)

        let cross = cross(a, b)
        EXPECT_FLOAT3_EQ(cross, -16.0, 11.0, -1.5)

        let length = length(a)
        XCTAssertEqual(length, sqrt(5.25))

        let length2 = lengthSqr(a)
        XCTAssertEqual(length2, 5.25)

        XCTAssertFalse(isNormalized(a))
        let normalize = normalize(a)
        XCTAssertTrue(isNormalized(normalize))
        EXPECT_FLOAT3_EQ(normalize, 0.21821788, 0.43643576, 0.87287152)

        let safe = VecFloat3(1.0, 0.0, 0.0)
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(isNormalized(normalize_safe))
        EXPECT_FLOAT3_EQ(normalize_safe, 0.21821788, 0.43643576, 0.87287152)

        let normalize_safer = normalizeSafe(VecFloat3.zero(), safe)
        XCTAssertTrue(isNormalized(normalize_safer))
        EXPECT_FLOAT3_EQ(normalize_safer, safe.x, safe.y, safe.z)

        let lerp_0 = lerp(a, b, 0.0)
        EXPECT_FLOAT3_EQ(lerp_0, a.x, a.y, a.z)

        let lerp_1 = lerp(a, b, 1.0)
        EXPECT_FLOAT3_EQ(lerp_1, b.x, b.y, b.z)

        let lerp_0_5 = lerp(a, b, 0.5)
        EXPECT_FLOAT3_EQ(lerp_0_5, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5,
                (a.z + b.z) * 0.5)

        let lerp_2 = lerp(a, b, 2.0)
        EXPECT_FLOAT3_EQ(lerp_2, 2.0 * b.x - a.x, 2.0 * b.y - a.y, 2.0 * b.z - a.z)
    }

    func testVectorArithmetic2() {
        let a = VecFloat2(0.5, 1.0)
        let b = VecFloat2(4.0, 5.0)

        let add = a + b
        EXPECT_FLOAT2_EQ(add, 4.5, 6.0)

        let sub = a - b
        EXPECT_FLOAT2_EQ(sub, -3.5, -4.0)

        let neg = -b
        EXPECT_FLOAT2_EQ(neg, -4.0, -5.0)

        let mul = a * b
        EXPECT_FLOAT2_EQ(mul, 2.0, 5.0)

        let mul_scal = a * 2.0
        EXPECT_FLOAT2_EQ(mul_scal, 1.0, 2.0)

        let div = a / b
        EXPECT_FLOAT2_EQ(div, 0.5 / 4.0, 1.0 / 5.0)
        let div_scal = a / 2.0
        EXPECT_FLOAT2_EQ(div_scal, 0.5 / 2.0, 1.0 / 2.0)

        let hadd4 = hAdd(a)
        XCTAssertEqual(hadd4, 1.5)

        let dot = dot(a, b)
        XCTAssertEqual(dot, 7.0)

        let length = length(a)
        XCTAssertEqual(length, sqrt(1.25))

        let length2 = lengthSqr(a)
        XCTAssertEqual(length2, 1.25)

        XCTAssertFalse(isNormalized(a))
        let normalize = normalize(a)
        XCTAssertTrue(isNormalized(normalize))
        EXPECT_FLOAT2_EQ(normalize, 0.44721359, 0.89442718)

        let safe = VecFloat2(1.0, 0.0)
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(isNormalized(normalize_safe))
        EXPECT_FLOAT2_EQ(normalize_safe, 0.44721359, 0.89442718)

        let normalize_safer = normalizeSafe(VecFloat2.zero(), safe)
        XCTAssertTrue(isNormalized(normalize_safer))
        EXPECT_FLOAT2_EQ(normalize_safer, safe.x, safe.y)

        let lerp_0 = lerp(a, b, 0.0)
        EXPECT_FLOAT2_EQ(lerp_0, a.x, a.y)

        let lerp_1 = lerp(a, b, 1.0)
        EXPECT_FLOAT2_EQ(lerp_1, b.x, b.y)

        let lerp_0_5 = lerp(a, b, 0.5)
        EXPECT_FLOAT2_EQ(lerp_0_5, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5)

        let lerp_2 = lerp(a, b, 2.0)
        EXPECT_FLOAT2_EQ(lerp_2, 2.0 * b.x - a.x, 2.0 * b.y - a.y)
    }
}
