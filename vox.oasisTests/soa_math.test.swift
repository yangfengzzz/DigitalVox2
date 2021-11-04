//
//  soa_math.test.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class soa_math: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //MARK: - Soa Float
    func testSoaFloatLoad4() {
        EXPECT_SOAFLOAT4_EQ(
                SoaFloat4.load(
                        simd_float4.load(0.0, 1.0, 2.0, 3.0),
                        simd_float4.load(4.0, 5.0, 6.0, 7.0),
                        simd_float4.load(8.0, 9.0, 10.0, 11.0),
                        simd_float4.load(12.0, 13.0, 14.0, 15.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0)
        EXPECT_SOAFLOAT4_EQ(
                SoaFloat4.load(
                        SoaFloat3.load(
                                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                                simd_float4.load(8.0, 9.0, 10.0, 11.0)),
                        simd_float4.load(12.0, 13.0, 14.0, 15.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0)
        EXPECT_SOAFLOAT4_EQ(
                SoaFloat4.load(
                        SoaFloat2.load(
                                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                                simd_float4.load(4.0, 5.0, 6.0, 7.0)),
                        simd_float4.load(8.0, 9.0, 10.0, 11.0),
                        simd_float4.load(12.0, 13.0, 14.0, 15.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0)
    }

    func testSoaFloatLoad3() {
        EXPECT_SOAFLOAT3_EQ(
                SoaFloat3.load(simd_float4.load(0.0, 1.0, 2.0, 3.0),
                        simd_float4.load(4.0, 5.0, 6.0, 7.0),
                        simd_float4.load(8.0, 9.0, 10.0, 11.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0)
        EXPECT_SOAFLOAT3_EQ(
                SoaFloat3.load(
                        SoaFloat2.load(simd_float4.load(0.0, 1.0, 2.0, 3.0),
                                simd_float4.load(4.0, 5.0, 6.0, 7.0)),
                        simd_float4.load(8.0, 9.0, 10.0, 11.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0)
    }

    func testSoaFloatLoad2() {
        EXPECT_SOAFLOAT2_EQ(
                SoaFloat2.load(simd_float4.load(0.0, 1.0, 2.0, 3.0),
                        simd_float4.load(4.0, 5.0, 6.0, 7.0)),
                0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0)
    }

    func testSoaFloatConstant4() {
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.zero(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.one(), 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.x_axis(), 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.y_axis(), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.z_axis(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT4_EQ(SoaFloat4.w_axis(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
    }

    func testSoaFloatConstant3() {
        EXPECT_SOAFLOAT3_EQ(SoaFloat3.zero(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT3_EQ(SoaFloat3.one(), 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ(SoaFloat3.x_axis(), 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT3_EQ(SoaFloat3.y_axis(), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                1.0, 0.0, 0.0, 0.0, 0.0)
        EXPECT_SOAFLOAT3_EQ(SoaFloat3.z_axis(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 1.0, 1.0, 1.0)
    }

    func testSoaFloatConstant2() {
        EXPECT_SOAFLOAT2_EQ(SoaFloat2.zero(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0)
        EXPECT_SOAFLOAT2_EQ(SoaFloat2.one(), 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT2_EQ(SoaFloat2.x_axis(), 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
                0.0)
        EXPECT_SOAFLOAT2_EQ(SoaFloat2.y_axis(), 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                1.0)
    }

    func testSoaFloatArithmetic4() {
        let a = SoaFloat4(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(4.0, 5.0, 6.0, 7.0),
                z: simd_float4.load(8.0, 9.0, 10.0, 11.0),
                w: simd_float4.load(12.0, 13.0, 14.0, 15.0))
        let b = SoaFloat4(
                x: simd_float4.load(-0.5, -1.0, -2.0, -3.0),
                y: simd_float4.load(-4.0, -5.0, -6.0, -7.0),
                z: simd_float4.load(-8.0, -9.0, -10.0, -11.0),
                w: simd_float4.load(-12.0, -13.0, -14.0, -15.0))
        let c = SoaFloat4(x: simd_float4.load(0.05, 0.1, 0.2, 0.3),
                y: simd_float4.load(0.4, 0.5, 0.6, 0.7),
                z: simd_float4.load(0.8, 0.9, 1.0, 1.1),
                w: simd_float4.load(1.2, 1.3, 1.4, 1.5))

        let add = a + b
        EXPECT_SOAFLOAT4_EQ(add, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

        let sub = a - b
        EXPECT_SOAFLOAT4_EQ(sub, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0,
                18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0)

        let neg = -a
        EXPECT_SOAFLOAT4_EQ(neg, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0, -8.0,
                -9.0, -10.0, -11.0, -12.0, -13.0, -14.0, -15.0)

        let mul = a * b
        EXPECT_SOAFLOAT4_EQ(mul, -0.25, -1.0, -4.0, -9.0, -16.0, -25.0, -36.0, -49.0,
                -64.0, -81.0, -100.0, -121.0, -144.0, -169.0, -196.0,
                -225.0)

        let mul_add = mAdd(a, b, c)
        EXPECT_SOAFLOAT4_EQ(mul_add, -0.2, -0.9, -3.8, -8.7, -15.6, -24.5,
                -35.4, -48.3, -63.2, -80.1, -99.0, -119.9, -142.8,
                -167.7, -194.6, -223.5)

        let mul_scal = a * simd_float4.load1(2.0)
        EXPECT_SOAFLOAT4_EQ(mul_scal, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0,
                18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0)

        let div = a / b
        EXPECT_SOAFLOAT4_EQ(div, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)

        let div_scal = a / simd_float4.load1(2.0)
        EXPECT_SOAFLOAT4_EQ(div_scal, 0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5,
                4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5)

        let hadd4 = hAdd(a)
        EXPECT_SOAFLOAT1_EQ(hadd4, 24.5, 28.0, 32.0, 36.0)

        let dot = dot(a, b)
        EXPECT_SOAFLOAT1_EQ(dot, -224.25, -276.0, -336.0, -404.0)

        let length = length(a)
        EXPECT_SOAFLOAT1_EQ(length, 14.974979, 16.613247, 18.3303, 20.09975)

        let length2 = lengthSqr(a)
        EXPECT_SOAFLOAT1_EQ(length2, 224.25, 276.0, 336.0, 404.0)

        XCTAssertTrue(areAllFalse(isNormalized(a)))
        XCTAssertTrue(areAllFalse(isNormalizedEst(a)))
        let normalize = normalize(a)
        XCTAssertTrue(areAllTrue(isNormalized(normalize)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize)))
        EXPECT_SOAFLOAT4_EQ(normalize, 0.033389, 0.0601929, 0.1091089, 0.1492555,
                0.267112, 0.300964, 0.3273268, 0.348263, 0.53422445,
                0.541736, 0.545544, 0.547270, 0.80133667, 0.782508,
                0.763762, 0.74627789)

        let safe = SoaFloat4.x_axis()
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safe)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safe)))
        EXPECT_SOAFLOAT4_EQ(normalize_safe, 0.033389, 0.0601929, 0.1091089, 0.1492555,
                0.267112, 0.300964, 0.3273268, 0.348263, 0.53422445,
                0.541736, 0.545544, 0.547270, 0.80133667, 0.782508,
                0.763762, 0.74627789)

        let normalize_safer = normalizeSafe(SoaFloat4.zero(), safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safer)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safer)))
        EXPECT_SOAFLOAT4_EQ(normalize_safer, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

        let lerp_0 = lerp(a, b, simd_float4.zero())
        EXPECT_SOAFLOAT4_EQ(lerp_0, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
                10.0, 11.0, 12.0, 13.0, 14.0, 15.0)

        let lerp_1 = lerp(a, b, simd_float4.one())
        EXPECT_SOAFLOAT4_EQ(lerp_1, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0,
                -8.0, -9.0, -10.0, -11.0, -12.0, -13.0, -14.0, -15.0)

        let lerp_0_5 = lerp(a, b, simd_float4.load1(0.5))
        EXPECT_SOAFLOAT4_EQ(lerp_0_5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    }

    func testSoaFloatArithmetic3() {
        let a = SoaFloat3(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(4.0, 5.0, 6.0, 7.0),
                z: simd_float4.load(8.0, 9.0, 10.0, 11.0))
        let b = SoaFloat3(x: simd_float4.load(-0.5, -1.0, -2.0, -3.0),
                y: simd_float4.load(-4.0, -5.0, -6.0, -7.0),
                z: simd_float4.load(-8.0, -9.0, -10.0, -11.0))
        let c = SoaFloat3(x: simd_float4.load(0.05, 0.1, 0.2, 0.3),
                y: simd_float4.load(0.4, 0.5, 0.6, 0.7),
                z: simd_float4.load(0.8, 0.9, 1.0, 1.1))

        let add = a + b
        EXPECT_SOAFLOAT3_EQ(add, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0)

        let sub = a - b
        EXPECT_SOAFLOAT3_EQ(sub, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0,
                18.0, 20.0, 22.0)

        let neg = -a
        EXPECT_SOAFLOAT3_EQ(neg, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0, -8.0,
                -9.0, -10.0, -11.0)

        let mul = a * b
        EXPECT_SOAFLOAT3_EQ(mul, -0.25, -1.0, -4.0, -9.0, -16.0, -25.0, -36.0, -49.0,
                -64.0, -81.0, -100.0, -121.0)

        let mul_add = mAdd(a, b, c)
        EXPECT_SOAFLOAT3_EQ(mul_add, -0.2, -0.9, -3.8, -8.7, -15.6, -24.5,
                -35.4, -48.3, -63.2, -80.1, -99.0, -119.9)

        let mul_scal = a * simd_float4.load1(2.0)
        EXPECT_SOAFLOAT3_EQ(mul_scal, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0,
                18.0, 20.0, 22.0)

        let div = a / b
        EXPECT_SOAFLOAT3_EQ(div, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                -1.0, -1.0, -1.0)

        let div_scal = a / simd_float4.load1(2.0)
        EXPECT_SOAFLOAT3_EQ(div_scal, 0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5)

        let hadd4 = hAdd(a)
        EXPECT_SOAFLOAT1_EQ(hadd4, 12.5, 15.0, 18.0, 21.0)

        let dot = dot(a, b)
        EXPECT_SOAFLOAT1_EQ(dot, -80.25, -107.0, -140.0, -179.0)

        let length = length(a)
        EXPECT_SOAFLOAT1_EQ(length, 8.958236, 10.34408, 11.83216, 13.37909)

        let length2 = lengthSqr(a)
        EXPECT_SOAFLOAT1_EQ(length2, 80.25, 107.0, 140.0, 179.0)

        let cross = cross(a, b)
        EXPECT_SOAFLOAT3_EQ(cross, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0)

        XCTAssertTrue(areAllFalse(isNormalized(a)))
        XCTAssertTrue(areAllFalse(isNormalizedEst(a)))
        let normalize = normalize(a)
        XCTAssertTrue(areAllTrue(isNormalized(normalize)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize)))
        EXPECT_SOAFLOAT3_EQ(normalize, 0.055814, 0.096673, 0.16903, 0.22423, 0.446516,
                0.483368, 0.50709, 0.52320, 0.893033, 0.870063, 0.84515,
                0.822178)

        let safe = SoaFloat3.x_axis()
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safe)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safe)))
        EXPECT_SOAFLOAT3_EQ(normalize_safe, 0.055814, 0.096673, 0.16903, 0.22423,
                0.446516, 0.483368, 0.50709, 0.52320, 0.893033, 0.870063,
                0.84515, 0.822178)

        let normalize_safer = normalizeSafe(SoaFloat3.zero(), safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safer)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safer)))
        EXPECT_SOAFLOAT3_EQ(normalize_safer, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0)

        let lerp_0 = lerp(a, b, simd_float4.zero())
        EXPECT_SOAFLOAT3_EQ(lerp_0, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
                10.0, 11.0)

        let lerp_1 = lerp(a, b, simd_float4.one())
        EXPECT_SOAFLOAT3_EQ(lerp_1, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0,
                -8.0, -9.0, -10.0, -11.0)

        let lerp_0_5 = lerp(a, b, simd_float4.load1(0.5))
        EXPECT_SOAFLOAT3_EQ(lerp_0_5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0)
    }

    func testSoaFloatArithmetic2() {
        let a = SoaFloat2(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(4.0, 5.0, 6.0, 7.0))
        let b = SoaFloat2(x: simd_float4.load(-0.5, -1.0, -2.0, -3.0),
                y: simd_float4.load(-4.0, -5.0, -6.0, -7.0))
        let c = SoaFloat2(x: simd_float4.load(0.05, 0.1, 0.2, 0.3),
                y: simd_float4.load(0.4, 0.5, 0.6, 0.7))

        let add = a + b
        EXPECT_SOAFLOAT2_EQ(add, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

        let sub = a - b
        EXPECT_SOAFLOAT2_EQ(sub, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0)

        let neg = -a
        EXPECT_SOAFLOAT2_EQ(neg, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0)

        let mul = a * b
        EXPECT_SOAFLOAT2_EQ(mul, -0.25, -1.0, -4.0, -9.0, -16.0, -25.0, -36.0,
                -49.0)

        let mul_add = mAdd(a, b, c)
        EXPECT_SOAFLOAT2_EQ(mul_add, -0.2, -0.9, -3.8, -8.7, -15.6, -24.5,
                -35.4, -48.3)

        let mul_scal = a * simd_float4.load1(2.0)
        EXPECT_SOAFLOAT2_EQ(mul_scal, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0)

        let div = a / b
        EXPECT_SOAFLOAT2_EQ(div, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)

        let div_scal = a / simd_float4.load1(2.0)
        EXPECT_SOAFLOAT2_EQ(div_scal, 0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5)

        let hadd4 = hAdd(a)
        EXPECT_SOAFLOAT1_EQ(hadd4, 4.5, 6.0, 8.0, 10.0)

        let dot = dot(a, b)
        EXPECT_SOAFLOAT1_EQ(dot, -16.25, -26.0, -40.0, -58.0)

        let length = length(a)
        EXPECT_SOAFLOAT1_EQ(length, 4.031129, 5.09902, 6.324555, 7.615773)

        let length2 = lengthSqr(a)
        EXPECT_SOAFLOAT1_EQ(length2, 16.25, 26.0, 40.0, 58.0)

        XCTAssertTrue(areAllFalse(isNormalized(a)))
        XCTAssertTrue(areAllFalse(isNormalizedEst(a)))
        let normalize = normalize(a)
        XCTAssertTrue(areAllTrue(isNormalized(normalize)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize)))
        EXPECT_SOAFLOAT2_EQ(normalize, 0.124034, 0.196116, 0.316227, 0.393919,
                0.992277, 0.980580, 0.9486832, 0.919145)

        let safe = SoaFloat2.x_axis()
        let normalize_safe = normalizeSafe(a, safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safe)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safe)))
        EXPECT_SOAFLOAT2_EQ(normalize, 0.124034, 0.196116, 0.316227, 0.393919,
                0.992277, 0.980580, 0.9486832, 0.919145)

        let normalize_safer = normalizeSafe(SoaFloat2.zero(), safe)
        XCTAssertTrue(areAllTrue(isNormalized(normalize_safer)))
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_safer)))
        EXPECT_SOAFLOAT2_EQ(normalize_safer, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)

        let lerp_0 = lerp(a, b, simd_float4.zero())
        EXPECT_SOAFLOAT2_EQ(lerp_0, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0)

        let lerp_1 = lerp(a, b, simd_float4.one())
        EXPECT_SOAFLOAT2_EQ(lerp_1, -0.5, -1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0)

        let lerp_0_5 = lerp(a, b, simd_float4.load1(0.5))
        EXPECT_SOAFLOAT2_EQ(lerp_0_5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    }

    func testSoaFloatComparison4() {
        let a = SoaFloat4(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(1.0, 5.0, 6.0, 7.0),
                z: simd_float4.load(2.0, 9.0, 10.0, 11.0),
                w: simd_float4.load(3.0, 13.0, 14.0, 15.0))
        let b = SoaFloat4(x: simd_float4.load(4.0, 3.0, 7.0, 3.0),
                y: simd_float4.load(2.0, -5.0, 6.0, 5.0),
                z: simd_float4.load(-6.0, 9.0, -10.0, 2.0),
                w: simd_float4.load(7.0, -8.0, 1.0, 5.0))
        let c = SoaFloat4(x: simd_float4.load(7.5, 12.0, 46.0, 31.0),
                y: simd_float4.load(1.0, 58.0, 16.0, 78.0),
                z: simd_float4.load(2.5, 9.0, 111.0, 22.0),
                w: simd_float4.load(8.0, 23.0, 41.0, 18.0))
        let min = min(a, b)
        EXPECT_SOAFLOAT4_EQ(min, 0.5, 1.0, 2.0, 3.0, 1.0, -5.0, 6.0, 5.0, -6.0, 9.0,
                -10.0, 2.0, 3.0, -8.0, 1.0, 5.0)

        let max = max(a, b)
        EXPECT_SOAFLOAT4_EQ(max, 4.0, 3.0, 7.0, 3.0, 2.0, 5.0, 6.0, 7.0, 2.0, 9.0,
                10.0, 11.0, 7.0, 13.0, 14.0, 15.0)

        EXPECT_SOAFLOAT4_EQ(
                clamp(a, SoaFloat4.load(
                        simd_float4.load(1.5, 5.0, -2.0, 24.0),
                        simd_float4.load(2.0, -5.0, 7.0, 1.0),
                        simd_float4.load(-3.0, 1.0, 200.0, 0.0),
                        simd_float4.load(-9.0, 15.0, 46.0, -1.0)),
                        c),
                1.5, 5.0, 2.0, 24.0, 1.0, 5.0, 7.0, 7.0, 2.0, 9.0, 111.0, 11.0, 3.0,
                15.0, 41.0, 15.0)

        EXPECT_SIMDINT_EQ(a < c, 0, 0, -1, -1)
        EXPECT_SIMDINT_EQ(a <= c, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(c <= c, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(c > a, 0, 0, -1, -1)
        EXPECT_SIMDINT_EQ(c >= a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a >= a, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(a == a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a == c, 0, 0, 0, 0)
        EXPECT_SIMDINT_EQ(a != b, -1, -1, -1, -1)
    }

    func testSoaFloatComparison3() {
        let a = SoaFloat3(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(1.0, 5.0, 6.0, 7.0),
                z: simd_float4.load(2.0, 9.0, 10.0, 11.0))
        let b = SoaFloat3(x: simd_float4.load(4.0, 3.0, 7.0, 3.0),
                y: simd_float4.load(2.0, -5.0, 6.0, 5.0),
                z: simd_float4.load(-6.0, 9.0, -10.0, 2.0))
        let c = SoaFloat3(x: simd_float4.load(7.5, 12.0, 46.0, 31.0),
                y: simd_float4.load(1.0, 58.0, 16.0, 78.0),
                z: simd_float4.load(2.5, 9.0, 111.0, 22.0))
        let min = min(a, b)
        EXPECT_SOAFLOAT3_EQ(min, 0.5, 1.0, 2.0, 3.0, 1.0, -5.0, 6.0, 5.0, -6.0, 9.0,
                -10.0, 2.0)

        let max = max(a, b)
        EXPECT_SOAFLOAT3_EQ(max, 4.0, 3.0, 7.0, 3.0, 2.0, 5.0, 6.0, 7.0, 2.0, 9.0,
                10.0, 11.0)

        EXPECT_SOAFLOAT3_EQ(
                clamp(a, SoaFloat3.load(
                        simd_float4.load(1.5, 5.0, -2.0, 24.0),
                        simd_float4.load(2.0, -5.0, 7.0, 1.0),
                        simd_float4.load(-3.0, 1.0, 200.0, 0.0)),
                        c),
                1.5, 5.0, 2.0, 24.0, 1.0, 5.0, 7.0, 7.0, 2.0, 9.0, 111.0, 11.0)

        EXPECT_SIMDINT_EQ(a < c, 0, 0, -1, -1)
        EXPECT_SIMDINT_EQ(a <= c, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(c <= c, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(c > a, 0, 0, -1, -1)
        EXPECT_SIMDINT_EQ(c >= a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a >= a, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(a == a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a == c, 0, 0, 0, 0)
        EXPECT_SIMDINT_EQ(a != b, -1, -1, -1, -1)
    }

    func testSoaFloatComparison2() {
        let a = SoaFloat2(x: simd_float4.load(0.5, 1.0, 2.0, 3.0),
                y: simd_float4.load(1.0, 5.0, 6.0, 7.0))
        let b = SoaFloat2(x: simd_float4.load(4.0, 3.0, 7.0, 3.0),
                y: simd_float4.load(2.0, -5.0, 6.0, 5.0))
        let c = SoaFloat2(x: simd_float4.load(7.5, 12.0, 46.0, 31.0),
                y: simd_float4.load(1.0, 58.0, 16.0, 78.0))
        let min = min(a, b)
        EXPECT_SOAFLOAT2_EQ(min, 0.5, 1.0, 2.0, 3.0, 1.0, -5.0, 6.0, 5.0)

        let max = max(a, b)
        EXPECT_SOAFLOAT2_EQ(max, 4.0, 3.0, 7.0, 3.0, 2.0, 5.0, 6.0, 7.0)

        EXPECT_SOAFLOAT2_EQ(
                clamp(a, SoaFloat2.load(simd_float4.load(1.5, 5.0, -2.0, 24.0),
                        simd_float4.load(2.0, -5.0, 7.0, 1.0)), c),
                1.5, 5.0, 2.0, 24.0, 1.0, 5.0, 7.0, 7.0)

        EXPECT_SIMDINT_EQ(a < c, 0, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a <= c, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(c <= c, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(c > a, 0, -1, -1, -1)
        EXPECT_SIMDINT_EQ(c >= a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a >= a, -1, -1, -1, -1)

        EXPECT_SIMDINT_EQ(a == a, -1, -1, -1, -1)
        EXPECT_SIMDINT_EQ(a == c, 0, 0, 0, 0)
        EXPECT_SIMDINT_EQ(a != b, -1, -1, -1, -1)
    }

    //MARK: - Soa Quaternion
    func testSoaQuaternionConstant() {
        EXPECT_SOAQUATERNION_EQ(SoaQuaternion.identity(), 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                1.0)
    }

    func testSoaQuaternionArithmetic() {
        let a = SoaQuaternion.load(
                simd_float4.load(0.70710677, 0.0, 0.0, 0.382683432),
                simd_float4.load(0.0, 0.0, 0.70710677, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 0.0),
                simd_float4.load(0.70710677, 1.0, 0.70710677, 0.9238795))
        let b = SoaQuaternion.load(
                simd_float4.load(0.0, 0.70710677, 0.0, -0.382683432),
                simd_float4.load(0.0, 0.0, 0.70710677, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 0.0),
                simd_float4.load(1.0, 0.70710677, 0.70710677, 0.9238795))
        let denorm =
                SoaQuaternion.load(simd_float4.load(0.5, 0.0, 2.0, 3.0),
                        simd_float4.load(4.0, 0.0, 6.0, 7.0),
                        simd_float4.load(8.0, 0.0, 10.0, 11.0),
                        simd_float4.load(12.0, 1.0, 14.0, 15.0))

        XCTAssertTrue(areAllTrue(isNormalized(a)))
        XCTAssertTrue(areAllTrue(isNormalized(b)))
        EXPECT_SIMDINT_EQ(isNormalized(denorm), 0, -1, 0, 0)

        let conjugate = conjugate(a)
        EXPECT_SOAQUATERNION_EQ(conjugate, -0.70710677, -0.0, -0.0, -0.382683432,
                -0.0, -0.0, -0.70710677, -0.0, -0.0, -0.0, -0.0, -0.0,
                0.70710677, 1.0, 0.70710677, 0.9238795)
        XCTAssertTrue(areAllTrue(isNormalized(conjugate)))

        let negate = -a
        EXPECT_SOAQUATERNION_EQ(negate, -0.70710677, 0.0, 0.0, -0.382683432, 0.0, 0.0,
                -0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, -0.70710677,
                -1.0, -0.70710677, -0.9238795)

        let add = a + b
        EXPECT_SOAQUATERNION_EQ(add, 0.70710677, 0.70710677, 0.0, 0.0, 0.0, 0.0,
                1.41421354, 0.0, 0.0, 0.0, 0.0, 0.0, 1.70710677,
                1.70710677, 1.41421354, 1.847759)

        let muls = a * simd_float4.load1(2.0)
        EXPECT_SOAQUATERNION_EQ(muls, 1.41421354, 0.0, 0.0, 0.765366864, 0.0, 0.0,
                1.41421354, 0.0, 0.0, 0.0, 0.0, 0.0, 1.41421354,
                2.0, 1.41421354, 1.847759)

        let mul0 = a * conjugate
        EXPECT_SOAQUATERNION_EQ(mul0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        XCTAssertTrue(areAllTrue(isNormalized(mul0)))

        let mul1 = conjugate * a
        EXPECT_SOAQUATERNION_EQ(mul1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        XCTAssertTrue(areAllTrue(isNormalized(mul1)))

        let dot = dot(a, b)
        EXPECT_SOAFLOAT1_EQ(dot, 0.70710677, 0.70710677, 1.0, 0.70710677)

        let normalize = normalize(denorm)
        XCTAssertTrue(areAllTrue(isNormalized(normalize)))
        EXPECT_SOAQUATERNION_EQ(normalize, 0.033389, 0.0, 0.1091089, 0.1492555,
                0.267112, 0.0, 0.3273268, 0.348263, 0.53422445, 0.0,
                0.545544, 0.547270, 0.80133667, 1.0, 0.763762,
                0.74627789)

        let normalize_est = normalizeEst(denorm)
        EXPECT_SOAQUATERNION_EQ_EST(normalize_est, 0.033389, 0.0, 0.1091089,
                0.1492555, 0.267112, 0.0, 0.3273268, 0.348263,
                0.53422445, 0.0, 0.545544, 0.547270, 0.80133667,
                1.0, 0.763762, 0.74627789)
        XCTAssertTrue(areAllTrue(isNormalizedEst(normalize_est)))

        let lerp_0 = lerp(a, b, simd_float4.zero())
        EXPECT_SOAQUATERNION_EQ(lerp_0, 0.70710677, 0.0, 0.0, 0.382683432, 0.0, 0.0,
                0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 0.70710677, 1.0,
                0.70710677, 0.9238795)

        let lerp_1 = lerp(a, b, simd_float4.one())
        EXPECT_SOAQUATERNION_EQ(lerp_1, 0.0, 0.70710677, 0.0, -0.382683432, 0.0, 0.0,
                0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.70710677,
                0.70710677, 0.9238795)

        let lerp_0_2 = lerp(a, b, simd_float4.load1(0.2))
        EXPECT_SOAQUATERNION_EQ(lerp_0_2, 0.565685416, 0.14142136, 0.0, 0.22961006,
                0.0, 0.0, 0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.76568544, 0.94142133, 0.70710677, 0.92387950)

        let lerp_m = lerp(a, b, simd_float4.load(0.0, 1.0, 1.0, 0.2))
        EXPECT_SOAQUATERNION_EQ(lerp_m, 0.70710677, 0.70710677, 0.0, 0.22961006, 0.0,
                0.0, 0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 0.70710677,
                0.70710677, 0.70710677, 0.92387950)

        let nlerp_0 = nlerp(a, b, simd_float4.zero())
        EXPECT_SOAQUATERNION_EQ(nlerp_0, 0.70710677, 0.0, 0.0, 0.382683432, 0.0, 0.0,
                0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 0.70710677, 1.0,
                0.70710677, 0.9238795)
        XCTAssertTrue(areAllTrue(isNormalized(nlerp_0)))

        let nlerp_1 = nlerp(a, b, simd_float4.one())
        EXPECT_SOAQUATERNION_EQ(nlerp_1, 0.0, 0.70710677, 0.0, -0.382683432, 0.0, 0.0,
                0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.70710677,
                0.70710677, 0.9238795)
        XCTAssertTrue(areAllTrue(isNormalized(nlerp_1)))

        let nlerp_0_2 = nlerp(a, b, simd_float4.load1(0.2))
        XCTAssertTrue(areAllTrue(isNormalized(nlerp_0_2)))
        EXPECT_SOAQUATERNION_EQ(nlerp_0_2, 0.59421712, 0.14855431, 0.0, 0.24119100,
                0.0, 0.0, 0.70710683, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.80430466, 0.98890430, 0.70710683, 0.97047764)
        XCTAssertTrue(areAllTrue(isNormalized(nlerp_0_2)))

        let nlerp_m = nlerp(a, b, simd_float4.load(0.0, 1.0, 1.0, 0.2))
        EXPECT_SOAQUATERNION_EQ(nlerp_m, 0.70710677, 0.70710677, 0.0, 0.24119100, 0.0,
                0.0, 0.70710677, 0.0, 0.0, 0.0, 0.0, 0.0, 0.70710677,
                0.70710677, 0.70710677, 0.97047764)
        XCTAssertTrue(areAllTrue(isNormalized(nlerp_m)))

        let nlerp_est_m = nlerpEst(a, b, simd_float4.load(0.0, 1.0, 1.0, 0.2))
        EXPECT_SOAQUATERNION_EQ_EST(nlerp_est_m, 0.70710677, 0.70710677, 0.0,
                0.24119100, 0.0, 0.0, 0.70710677, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.70710677, 0.70710677, 0.70710677,
                0.97047764)
        XCTAssertTrue(areAllTrue(isNormalizedEst(nlerp_est_m)))
    }
}
