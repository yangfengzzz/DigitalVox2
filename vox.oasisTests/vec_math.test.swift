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

    //MARK: - Vec Float(Done)
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

    func testVectorComparison4() {
        let a = VecFloat4(0.5, 1.0, 2.0, 3.0)
        let b = VecFloat4(4.0, 5.0, -6.0, 7.0)
        let c = VecFloat4(4.0, 5.0, 6.0, 7.0)
        let d = VecFloat4(4.0, 5.0, 6.0, 7.1)

        let min = min(a, b)
        EXPECT_FLOAT4_EQ(min, 0.5, 1.0, -6.0, 3.0)

        let max = max(a, b)
        EXPECT_FLOAT4_EQ(max, 4.0, 5.0, 2.0, 7.0)

        EXPECT_FLOAT4_EQ(clamp(a, VecFloat4(-12.0, 2.0, 9.0, 3.0), c), 0.5, 2.0, 6.0,
                3.0)

        XCTAssertTrue(a < c)
        XCTAssertTrue(a <= c)
        XCTAssertTrue(c <= c)

        XCTAssertTrue(c > a)
        XCTAssertTrue(c >= a)
        XCTAssertTrue(a >= a)

        XCTAssertTrue(a == a)
        XCTAssertTrue(a != b)

        XCTAssertTrue(compare(a, a, 0.0))
        XCTAssertTrue(compare(c, d, 0.2))
        XCTAssertFalse(compare(c, d, 0.05))
    }

    func testVectorComparison3() {
        let a = VecFloat3(0.5, -1.0, 2.0)
        let b = VecFloat3(4.0, 5.0, -6.0)
        let c = VecFloat3(4.0, 5.0, 6.0)
        let d = VecFloat3(4.0, 5.0, 6.1)

        let min = min(a, b)
        EXPECT_FLOAT3_EQ(min, 0.5, -1.0, -6.0)

        let max = max(a, b)
        EXPECT_FLOAT3_EQ(max, 4.0, 5.0, 2.0)

        EXPECT_FLOAT3_EQ(clamp(a, VecFloat3(-12.0, 2.0, 9.0), c), 0.5, 2.0, 6.0)

        XCTAssertTrue(a < c)
        XCTAssertTrue(a <= c)
        XCTAssertTrue(c <= c)

        XCTAssertTrue(c > a)
        XCTAssertTrue(c >= a)
        XCTAssertTrue(a >= a)

        XCTAssertTrue(a == a)
        XCTAssertTrue(a != b)

        XCTAssertTrue(compare(a, a, 1e-3))
        XCTAssertTrue(compare(c, d, 0.2))
        XCTAssertFalse(compare(c, d, 0.05))
    }

    func testVectorComparison2() {
        let a = VecFloat2(0.5, 1.0)
        let b = VecFloat2(4.0, -5.0)
        let c = VecFloat2(4.0, 5.0)
        let d = VecFloat2(4.0, 5.1)

        let min = min(a, b)
        EXPECT_FLOAT2_EQ(min, 0.5, -5.0)

        let max = max(a, b)
        EXPECT_FLOAT2_EQ(max, 4.0, 1.0)

        EXPECT_FLOAT2_EQ(clamp(a, VecFloat2(-12.0, 2.0), c), 0.5, 2.0)

        XCTAssertTrue(a < c)
        XCTAssertTrue(a <= c)
        XCTAssertTrue(c <= c)

        XCTAssertTrue(c > a)
        XCTAssertTrue(c >= a)
        XCTAssertTrue(a >= a)

        XCTAssertTrue(a == a)
        XCTAssertTrue(a != b)

        XCTAssertTrue(compare(a, a, 1e-3))
        XCTAssertTrue(compare(c, d, 0.2))
        XCTAssertFalse(compare(c, d, 0.05))
    }

    //MARK: - Vec Quaternion(Done)
    func testQuaternionConstant() {
        EXPECT_QUATERNION_EQ(VecQuaternion.identity(), 0.0, 0.0, 0.0, 1.0)
    }

    func testQuaternionAxisAngle() {
        // Identity
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), 0.0), 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT4_EQ(toAxisAngle(VecQuaternion.identity()), 1.0, 0.0, 0.0, 0.0)

        // Other axis angles
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2), 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT4_EQ(toAxisAngle(VecQuaternion(0.0, 0.70710677, 0.0, 0.70710677)), 0.0, 1.0, 0.0, kPi_2)

        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2), 0.0, -0.70710677, 0.0, 0.70710677)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(-VecFloat3.y_axis(), kPi_2), 0.0, -0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT4_EQ(toAxisAngle(VecQuaternion(0.0, -0.70710677, 0.0, 0.70710677)), 0.0, -1.0, 0.0, kPi_2)

        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), 3.0 * kPi_4), 0.0, 0.923879504, 0.0, 0.382683426)
        EXPECT_FLOAT4_EQ(toAxisAngle(VecQuaternion(0.0, 0.923879504, 0.0, 0.382683426)), 0.0, 1.0, 0.0, 3.0 * kPi_4)

        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisAngle(VecFloat3(0.819865, 0.033034, -0.571604), 1.123), 0.4365425, 0.017589169, -0.30435428, 0.84645736)
        EXPECT_FLOAT4_EQ(toAxisAngle(VecQuaternion(0.4365425, 0.017589169, -0.30435428, 0.84645736)), 0.819865, 0.033034, -0.571604, 1.123)
    }

    func testQuaternionAxisCosAngle() {
        // Identity
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisCosAngle(VecFloat3.y_axis(), 1.0), 0.0, 0.0, 0.0, 1.0)

        // Other axis angles
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisCosAngle(VecFloat3.y_axis(), cos(kPi_2)), 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisCosAngle(-VecFloat3.y_axis(), cos(kPi_2)), 0.0, -0.70710677, 0.0, 0.70710677)

        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisCosAngle(VecFloat3.y_axis(), cos(3.0 * kPi_4)), 0.0, 0.923879504, 0.0, 0.382683426)

        EXPECT_QUATERNION_EQ(VecQuaternion.fromAxisCosAngle(VecFloat3(0.819865, 0.033034, -0.571604), cos(1.123)), 0.4365425, 0.017589169, -0.30435428, 0.84645736)
    }

    func testQuaternionQuaternionEuler() {
        // Identity
        EXPECT_QUATERNION_EQ(VecQuaternion.fromEuler(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(toEuler(VecQuaternion.identity()), 0.0, 0.0, 0.0)

        // Heading
        EXPECT_QUATERNION_EQ(VecQuaternion.fromEuler(kPi_2, 0.0, 0.0), 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(toEuler(VecQuaternion(0.0, 0.70710677, 0.0, 0.70710677)), kPi_2, 0.0, 0.0)

        // Elevation
        EXPECT_QUATERNION_EQ(VecQuaternion.fromEuler(0.0, kPi_2, 0.0), 0.0, 0.0, 0.70710677, 0.70710677)
        EXPECT_FLOAT3_EQ(toEuler(VecQuaternion(0.0, 0.0, 0.70710677, 0.70710677)), 0.0, kPi_2, 0.0)

        // Bank
        EXPECT_QUATERNION_EQ(VecQuaternion.fromEuler(0.0, 0.0, kPi_2), 0.70710677, 0.0, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(toEuler(VecQuaternion(0.70710677, 0.0, 0.0, 0.70710677)), 0.0, 0.0, kPi_2)

        // Any rotation
        EXPECT_QUATERNION_EQ(VecQuaternion.fromEuler(kPi / 4.0, -kPi / 6.0, kPi_2), 0.56098551, 0.092295974, -0.43045932, 0.70105737)
        EXPECT_FLOAT3_EQ(toEuler(VecQuaternion(0.56098551, 0.092295974, -0.43045932, 0.70105737)), kPi / 4.0, -kPi / 6.0, kPi_2)
    }

    func testQuaternionFromVectors() {
        // Returns identity for a 0 length vector
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.zero(), VecFloat3.x_axis()), 0.0, 0.0, 0.0, 1.0)

        // pi/2 around y
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.z_axis(), VecFloat3.x_axis()), 0.0, 0.707106769, 0.0, 0.707106769)

        // Non unit pi/2 around y
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.z_axis() * 7.0, VecFloat3.x_axis()), 0.0, 0.707106769, 0.0, 0.707106769)

        // Minus pi/2 around y
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.x_axis(), VecFloat3.z_axis()), 0.0, -0.707106769, 0.0, 0.707106769)

        // pi/2 around x
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.y_axis(), VecFloat3.z_axis()), 0.707106769, 0.0, 0.0, 0.707106769)

        // Non unit pi/2 around x
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.y_axis() * 9.0, VecFloat3.z_axis() * 13.0), 0.707106769, 0.0, 0.0, 0.707106769)

        // pi/2 around z
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.x_axis(), VecFloat3.y_axis()), 0.0, 0.0, 0.707106769, 0.707106769)

        // pi/2 around z also
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3(0.707106769, 0.707106769, 0.0), VecFloat3(-0.707106769, 0.707106769, 0.0)), 0.0, 0.0, 0.707106769, 0.707106769)

        // Aligned vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.x_axis(), VecFloat3.x_axis()), 0.0, 0.0, 0.0, 1.0)

        // Non-unit aligned vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.x_axis(), VecFloat3.x_axis() * 2.0), 0.0, 0.0, 0.0, 1.0)

        // Opposed vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.x_axis(), -VecFloat3.x_axis()), 0.0, 1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(-VecFloat3.x_axis(), VecFloat3.x_axis()), 0.0, -1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.y_axis(), -VecFloat3.y_axis()), 0.0, 0.0, 1.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(-VecFloat3.y_axis(), VecFloat3.y_axis()), 0.0, 0.0, -1.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3.z_axis(), -VecFloat3.z_axis()), 0.0, -1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(-VecFloat3.z_axis(), VecFloat3.z_axis()), 0.0, 1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3(0.707106769, 0.707106769, 0.0), -VecFloat3(0.707106769, 0.707106769, 0.0)), -0.707106769, 0.707106769, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3(0.0, 0.707106769, 0.707106769), -VecFloat3(0.0, 0.707106769, 0.707106769)), 0.0, -0.707106769, 0.707106769, 0)

        // Non-unit opposed vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromVectors(VecFloat3(2.0, 2.0, 2.0), -VecFloat3(2.0, 2.0, 2.0)), 0.0, -0.707106769, 0.707106769, 0)
    }

    func testQuaternionFromUnitVectors() {
        // pi/2 around y
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.z_axis(), VecFloat3.x_axis()), 0.0, 0.707106769, 0.0, 0.707106769)

        // Minus pi/2 around y
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.x_axis(), VecFloat3.z_axis()), 0.0, -0.707106769, 0.0, 0.707106769)

        // pi/2 around x
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.y_axis(), VecFloat3.z_axis()), 0.707106769, 0.0, 0.0, 0.707106769)

        // pi/2 around z
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.x_axis(), VecFloat3.y_axis()), 0.0, 0.0, 0.707106769, 0.707106769)

        // pi/2 around z also
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3(0.707106769, 0.707106769, 0.0), VecFloat3(-0.707106769, 0.707106769, 0.0)), 0.0, 0.0, 0.707106769, 0.707106769)

        // Aligned vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.x_axis(), VecFloat3.x_axis()), 0.0, 0.0, 0.0, 1.0)

        // Opposed vectors
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.x_axis(), -VecFloat3.x_axis()), 0.0, 1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(-VecFloat3.x_axis(), VecFloat3.x_axis()), 0.0, -1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.y_axis(), -VecFloat3.y_axis()), 0.0, 0.0, 1.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(-VecFloat3.y_axis(), VecFloat3.y_axis()), 0.0, 0.0, -1.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3.z_axis(), -VecFloat3.z_axis()), 0.0, -1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(-VecFloat3.z_axis(), VecFloat3.z_axis()), 0.0, 1.0, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3(0.707106769, 0.707106769, 0.0), -VecFloat3(0.707106769, 0.707106769, 0.0)), -0.707106769, 0.707106769, 0.0, 0)
        EXPECT_QUATERNION_EQ(VecQuaternion.fromUnitVectors(VecFloat3(0.0, 0.707106769, 0.707106769), -VecFloat3(0.0, 0.707106769, 0.707106769)), 0.0, -0.707106769, 0.707106769, 0)
    }

    func testQuaternionCompare() {
        XCTAssertTrue(VecQuaternion.identity() == VecQuaternion(0.0, 0.0, 0.0, 1.0))
        XCTAssertTrue(VecQuaternion.identity() != VecQuaternion(1.0, 0.0, 0.0, 0.0))
        XCTAssertTrue(compare(VecQuaternion.identity(), VecQuaternion.identity(), cos(0.5 * 0.0)))
        XCTAssertTrue(compare(VecQuaternion.identity(), VecQuaternion.fromEuler(0.0, 0.0, kPi / 100.0), cos(0.5 * kPi / 50.0)))
        XCTAssertTrue(compare(VecQuaternion.identity(), -VecQuaternion.fromEuler(0.0, 0.0, kPi / 100.0), cos(0.5 * kPi / 50.0)))
        XCTAssertFalse(compare(VecQuaternion.identity(), VecQuaternion.fromEuler(0.0, 0.0, kPi / 100.0), cos(0.5 * kPi / 200.0)))
    }

    func testQuaternionArithmetic() {
        let a = VecQuaternion(0.70710677, 0.0, 0.0, 0.70710677)
        let b = VecQuaternion(0.0, 0.70710677, 0.0, 0.70710677)
        let c = VecQuaternion(0.0, 0.70710677, 0.0, -0.70710677)
        let denorm = VecQuaternion(1.414212, 0.0, 0.0, 1.414212)

        XCTAssertTrue(isNormalized(a))
        XCTAssertTrue(isNormalized(b))
        XCTAssertTrue(isNormalized(c))
        XCTAssertFalse(isNormalized(denorm))

        let conjugate = conjugate(a)
        EXPECT_QUATERNION_EQ(conjugate, -a.x, -a.y, -a.z, a.w)
        XCTAssertTrue(isNormalized(conjugate))

        let negate = -a
        EXPECT_QUATERNION_EQ(negate, -a.x, -a.y, -a.z, -a.w)
        XCTAssertTrue(isNormalized(negate))

        let add = a + b
        EXPECT_QUATERNION_EQ(add, 0.70710677, 0.70710677, 0.0, 1.41421354)

        let mul0 = a * conjugate
        EXPECT_QUATERNION_EQ(mul0, 0.0, 0.0, 0.0, 1.0)
        XCTAssertTrue(isNormalized(mul0))

        let muls = a * 2.0
        EXPECT_QUATERNION_EQ(muls, 1.41421354, 0.0, 0.0, 1.41421354)

        let mul1 = conjugate * a
        EXPECT_QUATERNION_EQ(mul1, 0.0, 0.0, 0.0, 1.0)
        XCTAssertTrue(isNormalized(mul1))

        let q1234 = VecQuaternion(1.0, 2.0, 3.0, 4.0)
        let q5678 = VecQuaternion(5.0, 6.0, 7.0, 8.0)
        let mul12345678 = q1234 * q5678
        EXPECT_QUATERNION_EQ(mul12345678, 24.0, 48.0, 48.0, -6.0)

        let normalize = normalize(denorm)
        XCTAssertTrue(isNormalized(normalize))
        EXPECT_QUATERNION_EQ(normalize, 0.7071068, 0.0, 0.0, 0.7071068)

        let normalize_safe = normalizeSafe(denorm, VecQuaternion.identity())
        XCTAssertTrue(isNormalized(normalize_safe))
        EXPECT_QUATERNION_EQ(normalize_safe, 0.7071068, 0.0, 0.0, 0.7071068)

        let normalize_safer = normalizeSafe(VecQuaternion(0.0, 0.0, 0.0, 0.0), VecQuaternion.identity())
        XCTAssertTrue(isNormalized(normalize_safer))
        EXPECT_QUATERNION_EQ(normalize_safer, 0.0, 0.0, 0.0, 1.0)

        let lerp_0 = lerp(a, b, 0.0)
        EXPECT_QUATERNION_EQ(lerp_0, a.x, a.y, a.z, a.w)

        let lerp_1 = lerp(a, b, 1.0)
        EXPECT_QUATERNION_EQ(lerp_1, b.x, b.y, b.z, b.w)

        let lerp_0_2 = lerp(a, b, 0.2)
        EXPECT_QUATERNION_EQ(lerp_0_2, 0.5656853, 0.1414213, 0.0, 0.7071068)

        let nlerp_0 = nlerp(a, b, 0.0)
        XCTAssertTrue(isNormalized(nlerp_0))
        EXPECT_QUATERNION_EQ(nlerp_0, a.x, a.y, a.z, a.w)

        let nlerp_1 = nlerp(a, b, 1.0)
        XCTAssertTrue(isNormalized(nlerp_1))
        EXPECT_QUATERNION_EQ(nlerp_1, b.x, b.y, b.z, b.w)

        let nlerp_0_2 = nlerp(a, b, 0.2)
        XCTAssertTrue(isNormalized(nlerp_0_2))
        EXPECT_QUATERNION_EQ(nlerp_0_2, 0.6172133, 0.1543033, 0.0, 0.7715167)

        let slerp_0 = slerp(a, b, 0.0)
        XCTAssertTrue(isNormalized(slerp_0))
        EXPECT_QUATERNION_EQ(slerp_0, a.x, a.y, a.z, a.w)

        let slerp_c_0 = slerp(a, c, 0.0)
        XCTAssertTrue(isNormalized(slerp_c_0))
        EXPECT_QUATERNION_EQ(slerp_c_0, a.x, a.y, a.z, a.w)

        let slerp_c_1 = slerp(a, c, 1.0)
        XCTAssertTrue(isNormalized(slerp_c_1))
        EXPECT_QUATERNION_EQ(slerp_c_1, c.x, c.y, c.z, c.w)

        let slerp_c_0_6 = slerp(a, c, 0.6)
        XCTAssertTrue(isNormalized(slerp_c_0_6))
        EXPECT_QUATERNION_EQ(slerp_c_0_6, 0.6067752, 0.7765344, 0.0, -0.1697592)

        let slerp_1 = slerp(a, b, 1.0)
        XCTAssertTrue(isNormalized(slerp_1))
        EXPECT_QUATERNION_EQ(slerp_1, b.x, b.y, b.z, b.w)

        let slerp_0_2 = slerp(a, b, 0.2)
        XCTAssertTrue(isNormalized(slerp_0_2))
        EXPECT_QUATERNION_EQ(slerp_0_2, 0.6067752, 0.1697592, 0.0, 0.7765344)

        let slerp_0_7 = slerp(a, b, 0.7)
        XCTAssertTrue(isNormalized(slerp_0_7))
        EXPECT_QUATERNION_EQ(slerp_0_7, 0.2523113, 0.5463429, 0.0, 0.798654)

        let dot = dot(a, b)
        XCTAssertEqual(dot, 0.5, accuracy: 1.0e-5)
    }

    func testQuaternionTransformVector() {
        // 0 length
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), 0.0), VecFloat3.zero()), 0, 0, 0)

        // Unit length
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), 0.0), VecFloat3.z_axis()), 0, 0, 1)
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2), VecFloat3.y_axis()), 0, 1, 0)
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2), VecFloat3.x_axis()), 0, 0, -1)
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2), VecFloat3.z_axis()), 1, 0, 0)

        // Non unit
        EXPECT_FLOAT3_EQ(transformVector(VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2), VecFloat3.x_axis() * 2), 0, 2, 0)
    }

    //MARK: - Vec Transform(Done)
    func testTransformConstant() {
        EXPECT_FLOAT3_EQ(VecTransform.identity().translation, 0.0, 0.0, 0.0)
        EXPECT_QUATERNION_EQ(VecTransform.identity().rotation, 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(VecTransform.identity().scale, 1.0, 1.0, 1.0)
    }
}
