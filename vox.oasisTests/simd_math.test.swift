//
//  simd_math.test.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class SimdMathTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadFloat() {
        let fX = simd_float4.loadX(15.0)
        EXPECT_SIMDFLOAT_EQ(fX, 15.0, 0.0, 0.0, 0.0)

        let f1 = simd_float4.load1(15.0)
        EXPECT_SIMDFLOAT_EQ(f1, 15.0, 15.0, 15.0, 15.0)

        let f4 = simd_float4.load(1.0, -1.0, 2.0, -3.0)
        EXPECT_SIMDFLOAT_EQ(f4, 1.0, -1.0, 2.0, -3.0)
    }

    func testGetFloat() {
        let f = simd_float4.load(1.0, 2.0, 3.0, 4.0)

        XCTAssertEqual(getX(f), 1.0)
        XCTAssertEqual(getY(f), 2.0)
        XCTAssertEqual(getZ(f), 3.0)
        XCTAssertEqual(getW(f), 4.0)
    }

    func testSetFloat() {
        let a = simd_float4.load(1.0, 2.0, 3.0, 4.0)
        let b = simd_float4.load(5.0, 6.0, 7.0, 8.0)

        EXPECT_SIMDFLOAT_EQ(setX(a, b), 5.0, 2.0, 3.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setY(a, b), 1.0, 5.0, 3.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setZ(a, b), 1.0, 2.0, 5.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setW(a, b), 1.0, 2.0, 3.0, 5.0)

        EXPECT_SIMDFLOAT_EQ(setI(a, b, 0), 5.0, 2.0, 3.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setI(a, b, 1), 1.0, 5.0, 3.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setI(a, b, 2), 1.0, 2.0, 5.0, 4.0)
        EXPECT_SIMDFLOAT_EQ(setI(a, b, 3), 1.0, 2.0, 3.0, 5.0)
    }

    func testConstantFloat() {
        let zero = simd_float4.zero()
        EXPECT_SIMDFLOAT_EQ(zero, 0.0, 0.0, 0.0, 0.0)

        let one = simd_float4.one()
        EXPECT_SIMDFLOAT_EQ(one, 1.0, 1.0, 1.0, 1.0)

        let x_axis = simd_float4.x_axis()
        EXPECT_SIMDFLOAT_EQ(x_axis, 1.0, 0.0, 0.0, 0.0)

        let y_axis = simd_float4.y_axis()
        EXPECT_SIMDFLOAT_EQ(y_axis, 0.0, 1.0, 0.0, 0.0)

        let z_axis = simd_float4.z_axis()
        EXPECT_SIMDFLOAT_EQ(z_axis, 0.0, 0.0, 1.0, 0.0)

        let w_axis = simd_float4.w_axis()
        EXPECT_SIMDFLOAT_EQ(w_axis, 0.0, 0.0, 0.0, 1.0)
    }

    func testSplatFloat() {
        let f = simd_float4.load(1.0, -1.0, 2.0, -3.0)

        let x = splatX(f)
        EXPECT_SIMDFLOAT_EQ(x, 1.0, 1.0, 1.0, 1.0)

        let y = splatY(f)
        EXPECT_SIMDFLOAT_EQ(y, -1.0, -1.0, -1.0, -1.0)

        let z = splatZ(f)
        EXPECT_SIMDFLOAT_EQ(z, 2.0, 2.0, 2.0, 2.0)

        let w = splatW(f)
        EXPECT_SIMDFLOAT_EQ(w, -3.0, -3.0, -3.0, -3.0)

        let s0123 = swizzle0123(f)
        EXPECT_SIMDFLOAT_EQ(s0123, 1.0, -1.0, 2.0, -3.0)

        let s0011 = swizzle0011(f)
        EXPECT_SIMDFLOAT_EQ(s0011, 1.0, 1.0, -1.0, -1.0)

        let s2233 = swizzle2233(f)
        EXPECT_SIMDFLOAT_EQ(s2233, 2.0, 2.0, -3.0, -3.0)

        let s0101 = swizzle0101(f)
        EXPECT_SIMDFLOAT_EQ(s0101, 1.0, -1.0, 1.0, -1.0)

        let s2323 = swizzle2323(f)
        EXPECT_SIMDFLOAT_EQ(s2323, 2.0, -3.0, 2.0, -3.0)
    }

    func testFromInt() {
        let i = SimdInt4.load(0, 46, -93, 9926429)
        EXPECT_SIMDFLOAT_EQ(simd_float4.fromInt(i), 0.0, 46.0, -93.0, 9926429.0)
    }

    func testArithmeticFloat() {
        let a = simd_float4.load(0.50, 1.0, 2.0, 3.0)
        let b = simd_float4.load(4.0, 5.0, -6.0, 0.0)
        let c = simd_float4.load(-8.0, 9.0, 10.0, 11.0)

        let add = a + b
        EXPECT_SIMDFLOAT_EQ(add, 4.5, 6.0, -4.0, 3.0)

        let sub = a - b
        EXPECT_SIMDFLOAT_EQ(sub, -3.5, -4.0, 8.0, 3.0)

        let neg = -b
        EXPECT_SIMDFLOAT_EQ(neg, -4.0, -5.0, 6.0, -0.0)

        let mul = a * b
        EXPECT_SIMDFLOAT_EQ(mul, 2.0, 5.0, -12.0, 0.0)

        let div = a / b
        EXPECT_SIMDFLOAT3_EQ(div, 0.5 / 4.0, 1.0 / 5.0, -2.0 / 6.0)

        let madd = mAdd(a, b, c)
        EXPECT_SIMDFLOAT_EQ(madd, -6.0, 14.0, -2.0, 11.0)

        let msub = mSub(a, b, c)
        EXPECT_SIMDFLOAT_EQ(msub, 10.0, -4.0, -22.0, -11.0)

        let nmadd = nMAdd(a, b, c)
        EXPECT_SIMDFLOAT_EQ(nmadd, -10.0, 4.0, 22.0, 11.0)

        let nmsub = nMSub(a, b, c)
        EXPECT_SIMDFLOAT_EQ(nmsub, 6.0, -14.0, 2.0, -11.0)

        let divx = divX(a, b)
        EXPECT_SIMDFLOAT_EQ(divx, 0.5 / 4.0, 1.0, 2.0, 3.0)

        let hadd2 = hAdd2(a)
        EXPECT_SIMDFLOAT_EQ(hadd2, 1.5, 1.0, 2.0, 3.0)

        let hadd3 = hAdd3(a)
        EXPECT_SIMDFLOAT_EQ(hadd3, 3.5, 1.0, 2.0, 3.0)

        let hadd4 = hAdd4(a)
        XCTAssertEqual(getX(hadd4), 6.5)

        let dot2 = dot2(a, b)
        XCTAssertEqual(getX(dot2), 7.0)

        let dot3 = dot3(a, b)
        XCTAssertEqual(getX(dot3), -5.0)

        let dot4 = dot4(a, b)
        XCTAssertEqual(getX(dot4), -5.0)

        let cross = cross3(simd_float4.load(1.0, -2.0, 3.0, 46.0),
                simd_float4.load(4.0, 5.0, 6.0, 27.0))
        XCTAssertEqual(getX(cross), -27.0)
        XCTAssertEqual(getY(cross), 6.0)
        XCTAssertEqual(getZ(cross), 13.0)

        let rcp = rcpEst(b)
        EXPECT_SIMDFLOAT3_EQ_EST(rcp, 1.0 / 4.0, 1.0 / 5.0, -1.0 / 6.0)

        let rcpnr = rcpEstNR(b)
        EXPECT_SIMDFLOAT3_EQ(rcpnr, 1.0 / 4.0, 1.0 / 5.0, -1.0 / 6.0)

        let rcpxnr = rcpEstXNR(b)
        XCTAssertEqual(getX(rcpxnr), 1.0 / 4.0, accuracy: 1.0e-6)

        let rcpx = rcpEstX(b)
        EXPECT_SIMDFLOAT_EQ_EST(rcpx, 1.0 / 4.0, 5.0, -6.0, 0.0)

        let sqrt = sqrt(a)
        EXPECT_SIMDFLOAT_EQ(sqrt, 0.7071068, 1.0, 1.4142135, 1.7320508)

        let sqrtx = sqrtX(b)
        EXPECT_SIMDFLOAT_EQ(sqrtx, 2.0, 5.0, -6.0, 0.0)

        let rsqrt = rSqrtEst(b)
        EXPECT_SIMDFLOAT2_EQ_EST(rsqrt, 1.0 / 2.0, 1.0 / 2.23606798)

        let rsqrtnr = rSqrtEstNR(b)
        EXPECT_SIMDFLOAT2_EQ_EST(rsqrtnr, 1.0 / 2.0, 1.0 / 2.23606798)

        let rsqrtx = rSqrtEstX(a)
        EXPECT_SIMDFLOAT_EQ_EST(rsqrtx, 1.0 / 0.7071068, 1.0, 2.0, 3.0)

        let rsqrtxnr = rSqrtEstXNR(a)
        XCTAssertEqual(getX(rsqrtxnr), 1.0 / 0.7071068)

        let abs = abs(b)
        EXPECT_SIMDFLOAT_EQ(abs, 4.0, 5.0, 6.0, 0.0)

        let sign: SimdInt4 = sign(b)
        EXPECT_SIMDINT_EQ(sign, 0, 0, -2147483648, 0)
    }

    func testLengthFloat() {
        let f = simd_float4.load(1.0, 2.0, 4.0, 8.0)

        let len2 = length2(f)
        XCTAssertEqual(getX(len2), 2.236068)

        let len3 = length3(f)
        XCTAssertEqual(getX(len3), 4.5825758)

        let len4 = length4(f)
        XCTAssertEqual(getX(len4), 9.2195444)

        let len2sqr = length2Sqr(f)
        XCTAssertEqual(getX(len2sqr), 5.0)

        let len3sqr = length3Sqr(f)
        XCTAssertEqual(getX(len3sqr), 21.0)

        let len4sqr = length4Sqr(f)
        XCTAssertEqual(getX(len4sqr), 85.0)
    }

    func testNormalizeFloat() {
        let f = simd_float4.load(10, 20, 40, 80)
        let unit = simd_float4.x_axis()
        let zero = simd_float4.zero()

        EXPECT_SIMDINT_EQ(isNormalized2(f), 0, 0, 0, 0)
        let norm2 = normalize2(f)
        EXPECT_SIMDFLOAT_EQ(norm2, 0.44721359, 0.89442718, 40, 80)
        EXPECT_SIMDINT_EQ(isNormalized2(norm2), -1, 0, 0, 0)

        let norm_est2 = normalizeEst2(f)
        EXPECT_SIMDFLOAT_EQ_EST(norm_est2, 0.44721359, 0.89442718, 40, 80)
        EXPECT_SIMDINT_EQ(isNormalizedEst2(norm_est2), -1, 0, 0, 0)

        EXPECT_SIMDINT_EQ(isNormalized3(f), 0, 0, 0, 0)
        let norm3 = normalize3(f)
        EXPECT_SIMDFLOAT_EQ(norm3, 0.21821788, 0.43643576, 0.87287152, 80)
        EXPECT_SIMDINT_EQ(isNormalized3(norm3), -1, 0, 0, 0)

        let norm_est3 = normalizeEst3(f)
        EXPECT_SIMDFLOAT_EQ_EST(norm_est3, 0.21821788, 0.43643576, 0.87287152, 80)
        EXPECT_SIMDINT_EQ(isNormalizedEst3(norm_est3), -1, 0, 0, 0)

        EXPECT_SIMDINT_EQ(isNormalized4(f), 0, 0, 0, 0)
        let norm4 = normalize4(f)
        EXPECT_SIMDFLOAT_EQ(norm4, 0.1084652, 0.2169304, 0.4338609, 0.86772186)
        EXPECT_SIMDINT_EQ(isNormalized4(norm4), -1, 0, 0, 0)

        let norm_est4 = normalizeEst4(f)
        EXPECT_SIMDFLOAT_EQ_EST(norm_est4, 0.1084652, 0.2169304, 0.4338609, 0.86772186)
        EXPECT_SIMDINT_EQ(isNormalizedEst4(norm_est4), -1, 0, 0, 0)

        let safe2 = normalizeSafe2(f, unit)
        EXPECT_SIMDFLOAT_EQ(safe2, 0.4472136, 0.8944272, 40, 80)
        EXPECT_SIMDINT_EQ(isNormalized2(safe2), -1, 0, 0, 0)
        let safer2 = normalizeSafe2(zero, unit)
        EXPECT_SIMDFLOAT_EQ(safer2, 1.0, 0.0, 0.0, 0.0)
        let safe_est2 = normalizeSafeEst2(f, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safe_est2, 0.4472136, 0.8944272, 40, 80)
        EXPECT_SIMDINT_EQ(isNormalizedEst2(safe_est2), -1, 0, 0, 0)
        let safer_est2 = normalizeSafeEst2(zero, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safer_est2, 1.0, 0.0, 0.0, 0.0)

        let safe3 = normalizeSafe3(f, unit)
        EXPECT_SIMDFLOAT_EQ(safe3, 0.21821788, 0.43643576, 0.87287152, 80)
        EXPECT_SIMDINT_EQ(isNormalized3(safe3), -1, 0, 0, 0)
        let safer3 = normalizeSafe3(zero, unit)
        EXPECT_SIMDFLOAT_EQ(safer3, 1.0, 0.0, 0.0, 0.0)
        let safe_est3 = normalizeSafeEst3(f, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safe_est3, 0.21821788, 0.43643576, 0.87287152, 80)
        EXPECT_SIMDINT_EQ(isNormalizedEst3(safe_est3), -1, 0, 0, 0)
        let safer_est3 = normalizeSafeEst3(zero, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safer_est3, 1.0, 0.0, 0.0, 0.0)

        let safe4 = normalizeSafe4(f, unit)
        EXPECT_SIMDFLOAT_EQ(safe4, 0.1084652, 0.2169305, 0.433861, 0.8677219)
        EXPECT_SIMDINT_EQ(isNormalized4(safe4), -1, 0, 0, 0)
        let safer4 = normalizeSafe4(zero, unit)
        EXPECT_SIMDFLOAT_EQ(safer4, 1.0, 0.0, 0.0, 0.0)
        let safe_est4 = normalizeSafeEst4(f, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safe_est4, 0.1084652, 0.2169305, 0.433861, 0.8677219)
        EXPECT_SIMDINT_EQ(isNormalizedEst4(safe_est4), -1, 0, 0, 0)
        let safer_est4 = normalizeSafeEst4(zero, unit)
        EXPECT_SIMDFLOAT_EQ_EST(safer_est4, 1.0, 0.0, 0.0, 0.0)
    }

    func testCompareFloat() {
        let a = simd_float4.load(0.5, 1.0, 2.0, 3.0)
        let b = simd_float4.load(4.0, 1.0, -6.0, 7.0)
        let c = simd_float4.load(4.0, 5.0, 6.0, 7.0)

        let min = min(a, b)
        EXPECT_SIMDFLOAT_EQ(min, 0.5, 1.0, -6.0, 3.0)

        let max = max(a, b)
        EXPECT_SIMDFLOAT_EQ(max, 4.0, 1.0, 2.0, 7.0)

        let min0 = min0(b)
        EXPECT_SIMDFLOAT_EQ(min0, 0.0, 0.0, -6.0, 0.0)

        let max0 = max0(b)
        EXPECT_SIMDFLOAT_EQ(max0, 4.0, 1.0, 0.0, 7.0)

        EXPECT_SIMDFLOAT_EQ(clamp(a, simd_float4.load(-12.0, 2.0, 9.0, 3.0), c), 0.5, 2.0, 6.0, 3.0)

        let eq1 = cmpEq(a, b)
        EXPECT_SIMDINT_EQ(eq1, 0, -1, 0, 0)

        let eq2 = cmpEq(a, a)
        EXPECT_SIMDINT_EQ(eq2, -1, -1, -1, -1)

        let neq1 = cmpNe(a, b)
        EXPECT_SIMDINT_EQ(neq1, -1, 0, -1, -1)

        let neq2 = cmpNe(a, a)
        EXPECT_SIMDINT_EQ(neq2, 0, 0, 0, 0)

        let lt = cmpLt(a, b)
        EXPECT_SIMDINT_EQ(lt, -1, 0, 0, -1)

        let le = cmpLe(a, b)
        EXPECT_SIMDINT_EQ(le, -1, -1, 0, -1)

        let gt = cmpGt(a, b)
        EXPECT_SIMDINT_EQ(gt, 0, 0, -1, 0)

        let ge = cmpGe(a, b)
        EXPECT_SIMDINT_EQ(ge, 0, -1, -1, 0)
    }

    func testLerpFloat() {
        let a = simd_float4.load(0.0, 1.0, 2.0, 4.0)
        let b = simd_float4.load(0.0, -1.0, -2.0, -4.0)
        let zero = simd_float4.load1(0.0)
        let one = simd_float4.load1(1.0)

        let lerp0 = lerp(a, b, zero)
        EXPECT_SIMDFLOAT_EQ(lerp0, 0.0, 1.0, 2.0, 4.0)

        let lerp1 = lerp(a, b, one)
        EXPECT_SIMDFLOAT_EQ(lerp1, 0.0, -1.0, -2.0, -4.0)

        let lhalf = lerp(a, b, simd_float4.load1(0.5))
        EXPECT_SIMDFLOAT_EQ(lhalf, 0.0, 0.0, 0.0, 0.0)

        let lmixed = lerp(a, b, simd_float4.load(0.0, -1.0, 0.5, 2.0))
        EXPECT_SIMDFLOAT_EQ(lmixed, 0.0, 3.0, 0.0, -12.0)
    }

    func testTrigonometryFloat() {
        let angle = simd_float4.load(kPi, kPi / 6.0, -kPi_2, 5.0 * kPi_2)
        let cos = simd_float4.load(-1.0, 0.86602539, 0.0, 0.0)
        let sin = simd_float4.load(0.0, 0.5, -1.0, 1.0)

        let angle_tan = simd_float4.load(0.0, kPi / 6.0, -kPi / 3.0, 9.0 * kPi / 4.0)
        let tan = simd_float4.load(0.0, 0.57735, -1.73205, 1.0)

        EXPECT_SIMDFLOAT_EQ(vox_oasis.cos(angle), -1.0, 0.86602539, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.cos(angle + simd_float4.load1(k2Pi)), -1.0,
                0.86602539, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.cos(angle + simd_float4.load1(k2Pi * 12.0)), -1.0,
                0.86602539, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.cos(angle - simd_float4.load1(k2Pi * 24.0)), -1.0,
                0.86602539, 0.0, 0.0)

        EXPECT_SIMDFLOAT_EQ(cosX(angle), -1.0, kPi / 6.0, -kPi_2,
                5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                cosX(angle + simd_float4.loadX(k2Pi)), -1.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                cosX(angle + simd_float4.loadX(k2Pi * 12.0)), -1.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                cosX(angle - simd_float4.loadX(k2Pi * 24.0)), -1.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)

        EXPECT_SIMDFLOAT_EQ(vox_oasis.sin(angle), 0.0, 0.5, -1.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.sin(angle + simd_float4.load1(k2Pi)), 0.0, 0.5,
                -1.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.sin(angle + simd_float4.load1(k2Pi * 12.0)), 0.0,
                0.5, -1.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(vox_oasis.sin(angle - simd_float4.load1(k2Pi * 24.0)), 0.0,
                0.5, -1.0, 1.0)

        EXPECT_SIMDFLOAT_EQ(sinX(angle), 0.0, kPi / 6.0, -kPi_2,
                5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                sinX(angle + simd_float4.loadX(k2Pi)), 0.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                sinX(angle + simd_float4.loadX(k2Pi * 12.0)), 0.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)
        EXPECT_SIMDFLOAT_EQ(
                sinX(angle - simd_float4.loadX(k2Pi * 24.0)), 0.0,
                kPi / 6.0, -kPi_2, 5.0 * kPi_2)

        EXPECT_SIMDFLOAT_EQ(aCos(cos), kPi, kPi / 6.0, kPi_2, kPi_2)
        EXPECT_SIMDFLOAT_EQ(aCosX(cos), kPi, 0.86602539, 0.0, 0.0)

        EXPECT_SIMDFLOAT_EQ(aSin(sin), 0.0, kPi / 6.0, -kPi_2, kPi_2)
        EXPECT_SIMDFLOAT_EQ(aSinX(sin), 0.0, 0.5, -1.0, 1.0)

        EXPECT_SIMDFLOAT_EQ(vox_oasis.tan(angle_tan), 0.0, 0.57735, -1.73205, 1.0)
        EXPECT_SIMDFLOAT_EQ(tanX(angle_tan), 0.0, kPi / 6.0, -kPi / 3.0, 9.0 * kPi / 4.0)

        EXPECT_SIMDFLOAT_EQ(aTan(tan), 0.0, kPi / 6.0, -kPi / 3.0, kPi / 4.0)
        EXPECT_SIMDFLOAT_EQ(aTanX(tan), 0.0, 0.57735, -1.73205, 1.0)
    }

    func testLogicalFloat() {
        let a = simd_float4.load(0.0, 1.0, 2.0, 3.0)
        let b = simd_float4.load(1.0, -1.0, -3.0, -4.0)
        let mbool = SimdInt4.load(-1, 0, 0, -1)
        let mbit = SimdInt4.load(-1, 0, -2147483648, 0x7fffffff)
        let mfloat = simd_float4.load(1.0, 0.0, -0.0, 3.0)

        let select = select(mbool, a, b)
        EXPECT_SIMDFLOAT_EQ(select, 0.0, -1.0, -3.0, 3.0)

        let andm = and(b, mbit)
        EXPECT_SIMDFLOAT_EQ(andm, 1.0, 0.0, 0.0, 4.0)

        let andnm = andNot(b, mbit)
        EXPECT_SIMDFLOAT_EQ(andnm, 0.0, -1.0, 3.0, -0.0)

        let andf = and(b, mfloat)
        EXPECT_SIMDFLOAT_EQ(andf, 1.0, 0.0, -0.0, 2.0)

        let orm = or(a, mbit)
        XCTAssertEqual(math.floatCastU32(getX(orm)), 0xffffffff)
        XCTAssertEqual(getY(orm), 1.0)
        XCTAssertEqual(getZ(orm), -2.0)
        XCTAssertTrue(math.floatCastI32(getW(orm)) == 0x7fffffff)

        let ormf = or(a, mfloat)
        EXPECT_SIMDFLOAT_EQ(ormf, 1.0, 1.0, -2.0, 3.0)

        let xorm = xor(a, mbit)
        XCTAssertTrue(math.floatCastU32(getX(xorm)) == 0xffffffff)
        XCTAssertEqual(getY(xorm), 1.0)
        XCTAssertEqual(getZ(xorm), -2.0)
        XCTAssertTrue(math.floatCastU32(getW(xorm)) == 0x3fbfffff)

        let xormf = xor(a, mfloat)
        EXPECT_SIMDFLOAT_EQ(xormf, 1.0, 1.0, -2.0, 0.0)
    }

    func testHalf() {
        // 0
        XCTAssertEqual(math.floatToHalf(0.0), 0)
        XCTAssertEqual(math.halfToFloat(0), 0.0)
        XCTAssertEqual(math.floatToHalf(-0.0), 0x8000)
        XCTAssertEqual(math.halfToFloat(0x8000), -0.0)
        XCTAssertEqual(math.floatToHalf(0), 0)
        XCTAssertEqual(math.floatToHalf(0), 0)
        XCTAssertEqual(math.floatToHalf(0), 0)

        // 1
        XCTAssertEqual(math.floatToHalf(1.0), 0x3c00)
        XCTAssertEqual(math.halfToFloat(0x3c00), 1.0)
        XCTAssertEqual(math.floatToHalf(-1.0), 0xbc00)
        XCTAssertEqual(math.halfToFloat(0xbc00), -1.0)

        // Bounds
        XCTAssertEqual(math.floatToHalf(65504.0), 0x7bff)
        XCTAssertEqual(math.floatToHalf(-65504.0), 0xfbff)

        // Min, Max, Infinity
        XCTAssertEqual(math.floatToHalf(10e-16), 0)
        XCTAssertEqual(math.floatToHalf(10e+16), 0x7c00)
        XCTAssertEqual(math.halfToFloat(0x7c00), Float.infinity)
        XCTAssertEqual(math.floatToHalf(Float.greatestFiniteMagnitude), 0x7c00)
        XCTAssertEqual(math.floatToHalf(Float.infinity), 0x7c00)
        XCTAssertEqual(math.floatToHalf(-10e+16), 0xfc00)
        XCTAssertEqual(math.floatToHalf(-Float.infinity), 0xfc00)
        XCTAssertEqual(math.floatToHalf(-Float.greatestFiniteMagnitude), 0xfc00)
        XCTAssertEqual(math.halfToFloat(0xfc00), -Float.infinity)

        // Nan
        XCTAssertEqual(math.floatToHalf(Float.nan), 0x7e00)
        XCTAssertEqual(math.floatToHalf(Float.signalingNaN), 0x7e00)
        // According to the IEEE standard, NaN values have the odd property that
        // comparisons involving them are always false
        XCTAssertFalse(math.halfToFloat(0x7e00) == math.halfToFloat(0x7e00))

        // Random tries in range [10e-4,10e4].
        var pow: Float = -4.0
        while pow <= 4.0 {
            let max: Float = powf(10.0, pow)
            // Expect a 1/1000 precision over floats.
            let precision = max / 1000.0

            let n = 1000
            for i in 0..<n {
                let frand = max * (2.0 * Float(i) / Float(n) - 1.0)

                let h = math.floatToHalf(frand)
                let f = math.halfToFloat(h)
                XCTAssertEqual(frand, f, accuracy: precision)
            }

            pow += 1.0
        }
    }

    func testSimdHalf() {
        // 0
        EXPECT_SIMDINT_EQ(math.floatToHalf(simd_float4.load(0.0, -0.0, 0, 0)),
                0, 0x00008000, 0, 0)
        EXPECT_SIMDFLOAT_EQ(
                math.halfToFloat(SimdInt4.load(0, 0x00008000, 0, 0)),
                0.0, -0.0, 0.0, 0.0)

        // 1
        EXPECT_SIMDINT_EQ(math.floatToHalf(
                simd_float4.load(1.0, -1.0, 0.0, -0.0)),
                0x00003c00, 0x0000bc00, 0, 0x00008000)
        EXPECT_SIMDFLOAT_EQ(math.halfToFloat(SimdInt4.load(
                0x3c00, 0xbc00, 0, 0x00008000)),
                1.0, -1.0, 0.0, -0.0)

        // Bounds
        EXPECT_SIMDINT_EQ(math.floatToHalf(simd_float4.load(
                65504.0, -65504.0, 65604.0, -65604.0)),
                0x00007bff, 0x0000fbff, 0x00007c00, 0x0000fc00)

        // Min, Max, Infinity
        EXPECT_SIMDINT_EQ(math.floatToHalf(simd_float4.load(
                10e-16, 10e+16, Float.greatestFiniteMagnitude, Float.infinity)),
                0, 0x00007c00, 0x00007c00, 0x00007c00)
        EXPECT_SIMDINT_EQ(math.floatToHalf(simd_float4.load(
                -10e-16, -10e+16, -Float.greatestFiniteMagnitude,
                -Float.greatestFiniteMagnitude)),
                0x00008000, 0x0000fc00, 0x0000fc00, 0x0000fc00)

        // Nan
        EXPECT_SIMDINT_EQ(math.floatToHalf(simd_float4.load(Float.nan, Float.signalingNaN, 0, 0)),
                0x00007e00, 0x00007e00, 0, 0)

        // Inf and NAN
        let infnan = math.halfToFloat(SimdInt4.load(0x00007c00, 0x0000fc00, 0x00007e00, 0))
        XCTAssertEqual(getX(infnan), Float.infinity)
        XCTAssertEqual(getY(infnan), -Float.infinity)
        XCTAssertFalse(getZ(infnan) == getZ(infnan))

        // Random tries in range [10e-4,10e4].
        var pow: Float = -4.0
        while pow <= 4.0 {
            let max = powf(10.0, pow)
            // Expect a 1/1000 precision over floats.
            let precision = max / 1000.0

            let n = 1000
            for i in 0..<n {
                let frand = simd_float4.load(
                        max * (0.5 * Float(i) / Float(n) - 0.025), max * (1.0 * Float(i) / Float(n) - 0.5),
                        max * (1.5 * Float(i) / Float(n) - 0.75), max * (2.0 * Float(i) / Float(n) - 1.0))

                let h = math.floatToHalf(frand)
                let f = math.halfToFloat(h)

                XCTAssertEqual(getX(frand), getX(f), accuracy: precision)
                XCTAssertEqual(getY(frand), getY(f), accuracy: precision)
                XCTAssertEqual(getZ(frand), getZ(f), accuracy: precision)
                XCTAssertEqual(getW(frand), getW(f), accuracy: precision)
            }

            pow += 1.0
        }
    }
}
