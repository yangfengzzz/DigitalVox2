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

    //MARK: - Float Math
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

    //MARK: - Int Math
    func testLoadInt() {
        let iX = SimdInt4.loadX(15)
        EXPECT_SIMDINT_EQ(iX, 15, 0, 0, 0)

        let i1 = SimdInt4.load1(15)
        EXPECT_SIMDINT_EQ(i1, 15, 15, 15, 15)

        let i4 = SimdInt4.load(1, -1, 2, -3)
        EXPECT_SIMDINT_EQ(i4, 1, -1, 2, -3)

        let itX = SimdInt4.loadX(true)
        EXPECT_SIMDINT_EQ(itX, -1, 0, 0, 0)

        let ifX = SimdInt4.loadX(false)
        EXPECT_SIMDINT_EQ(ifX, 0, 0, 0, 0)

        let it1 = SimdInt4.load1(true)
        EXPECT_SIMDINT_EQ(it1, -1, -1, -1, -1)

        let if1 = SimdInt4.load1(false)
        EXPECT_SIMDINT_EQ(if1, 0, 0, 0, 0)

        let ibttff = SimdInt4.load(true, true, false, false)
        EXPECT_SIMDINT_EQ(ibttff, -1, -1, 0, 0)

        let ibftft = SimdInt4.load(false, true, false, true)
        EXPECT_SIMDINT_EQ(ibftft, 0, -1, 0, -1)
    }

    func testLoadIntPtr() {

    }

    func testGetInt() {
        let i = SimdInt4.load(1, 2, 3, 4)

        XCTAssertEqual(getX(i), 1)
        XCTAssertEqual(getY(i), 2)
        XCTAssertEqual(getZ(i), 3)
        XCTAssertEqual(getW(i), 4)
    }

    func testSetInt() {
        let a = SimdInt4.load(1, 2, 3, 4)
        let b = SimdInt4.load(5, 6, 7, 8)

        EXPECT_SIMDINT_EQ(setX(a, b), 5, 2, 3, 4)
        EXPECT_SIMDINT_EQ(setY(a, b), 1, 5, 3, 4)
        EXPECT_SIMDINT_EQ(setZ(a, b), 1, 2, 5, 4)
        EXPECT_SIMDINT_EQ(setW(a, b), 1, 2, 3, 5)

        EXPECT_SIMDINT_EQ(setI(a, b, 0), 5, 2, 3, 4)
        EXPECT_SIMDINT_EQ(setI(a, b, 1), 1, 5, 3, 4)
        EXPECT_SIMDINT_EQ(setI(a, b, 2), 1, 2, 5, 4)
        EXPECT_SIMDINT_EQ(setI(a, b, 3), 1, 2, 3, 5)
    }

    func testStoreIntPtr() {

    }

    func testConstantInt() {
        let zero = SimdInt4.zero()
        EXPECT_SIMDINT_EQ(zero, 0, 0, 0, 0)

        let one = SimdInt4.one()
        EXPECT_SIMDINT_EQ(one, 1, 1, 1, 1)

        let x_axis = SimdInt4.x_axis()
        EXPECT_SIMDINT_EQ(x_axis, 1, 0, 0, 0)

        let y_axis = SimdInt4.y_axis()
        EXPECT_SIMDINT_EQ(y_axis, 0, 1, 0, 0)

        let z_axis = SimdInt4.z_axis()
        EXPECT_SIMDINT_EQ(z_axis, 0, 0, 1, 0)

        let w_axis = SimdInt4.w_axis()
        EXPECT_SIMDINT_EQ(w_axis, 0, 0, 0, 1)

        let all_true = SimdInt4.all_true()
        EXPECT_SIMDINT_EQ(all_true, -1, -1, -1, -1)

        let all_false = SimdInt4.all_false()
        EXPECT_SIMDINT_EQ(all_false, 0, 0, 0, 0)

        let mask_sign = SimdInt4.mask_sign()
        EXPECT_SIMDINT_EQ(mask_sign, -2147483648, -2147483648, -2147483648, -2147483648)

        let mask_sign_xyz = SimdInt4.mask_sign_xyz()
        EXPECT_SIMDINT_EQ(mask_sign_xyz, -2147483648, -2147483648, -2147483648, 0x00000000)

        let mask_sign_w = SimdInt4.mask_sign_w()
        EXPECT_SIMDINT_EQ(mask_sign_w, 0x00000000, 0x00000000, 0x00000000, -2147483648)

        let mask_not_sign = SimdInt4.mask_not_sign()
        EXPECT_SIMDINT_EQ(mask_not_sign, 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)

        let mask_ffff = SimdInt4.mask_ffff()
        EXPECT_SIMDINT_EQ(mask_ffff, -1, -1, -1, -1)

        let mask_0000 = SimdInt4.mask_0000()
        EXPECT_SIMDINT_EQ(mask_0000, 0, 0, 0, 0)

        let mask_fff0 = SimdInt4.mask_fff0()
        EXPECT_SIMDINT_EQ(mask_fff0, -1, -1, -1, 0)

        let mask_f000 = SimdInt4.mask_f000()
        EXPECT_SIMDINT_EQ(mask_f000, -1, 0, 0, 0)

        let mask_0f00 = SimdInt4.mask_0f00()
        EXPECT_SIMDINT_EQ(mask_0f00, 0, -1, 0, 0)

        let mask_00f0 = SimdInt4.mask_00f0()
        EXPECT_SIMDINT_EQ(mask_00f0, 0, 0, -1, 0)

        let mask_000f = SimdInt4.mask_000f()
        EXPECT_SIMDINT_EQ(mask_000f, 0, 0, 0, -1)
    }

    func testSplatInt() {
        let i = SimdInt4.load(1, -1, 2, -3)

        let x = splatX(i)
        EXPECT_SIMDINT_EQ(x, 1, 1, 1, 1)

        let y = splatY(i)
        EXPECT_SIMDINT_EQ(y, -1, -1, -1, -1)

        let z = splatZ(i)
        EXPECT_SIMDINT_EQ(z, 2, 2, 2, 2)

        let w = splatW(i)
        EXPECT_SIMDINT_EQ(w, -3, -3, -3, -3)

        let s0123 = swizzle0123(i)
        EXPECT_SIMDINT_EQ(s0123, 1, -1, 2, -3)
    }

    func testFromFloat() {
        let f = simd_float4.load(0.0, 46.93, 46.26, -93.99)
        EXPECT_SIMDINT_EQ(SimdInt4.fromFloatRound(f), 0, 47, 46, -94)
        EXPECT_SIMDINT_EQ(SimdInt4.fromFloatTrunc(f), 0, 46, 46, -93)
    }

    func testArithmeticInt() {
        let a = SimdInt4.load(0, 1, 2, 3)
        let b = SimdInt4.load(4, 5, -6, 7)

        let hadd2 = hAdd2(a)
        EXPECT_SIMDINT_EQ(hadd2, 1, 1, 2, 3)

        let hadd3 = hAdd3(a)
        EXPECT_SIMDINT_EQ(hadd3, 3, 1, 2, 3)

        let hadd4 = hAdd4(a)
        EXPECT_SIMDINT_EQ(hadd4, 6, 1, 2, 3)

        let abs = abs(b)
        EXPECT_SIMDINT_EQ(abs, 4, 5, 6, 7)

        let sign = sign(b)
        EXPECT_SIMDINT_EQ(sign, 0, 0, -2147483648, 0)
    }

    func testCompareInt() {
        let a = SimdInt4.load(0, 1, 2, 3)
        let b = SimdInt4.load(4, 1, -6, 7)
        let c = SimdInt4.load(4, 5, 6, 7)

        let min = min(a, b)
        EXPECT_SIMDINT_EQ(min, 0, 1, -6, 3)

        let max = max(a, b)
        EXPECT_SIMDINT_EQ(max, 4, 1, 2, 7)

        let min0 = min0(b)
        EXPECT_SIMDINT_EQ(min0, 0, 0, -6, 0)

        let max0 = max0(b)
        EXPECT_SIMDINT_EQ(max0, 4, 1, 0, 7)

        EXPECT_SIMDINT_EQ(clamp(a, SimdInt4.load(-12, 2, 9, 3), c), 0, 2, 6, 3)

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

    func testMaskInt() {
        XCTAssertEqual(moveMask(SimdInt4.all_false()), 0x00000000)
        XCTAssertEqual(moveMask(SimdInt4.all_true()), 0x0000000f)
        XCTAssertEqual(moveMask(SimdInt4.mask_f000()), 0x00000001)
        XCTAssertEqual(moveMask(SimdInt4.mask_0f00()), 0x00000002)
        XCTAssertEqual(moveMask(SimdInt4.mask_00f0()), 0x00000004)
        XCTAssertEqual(moveMask(SimdInt4.mask_000f()), 0x00000008)
        XCTAssertEqual(moveMask(SimdInt4.load(-1, 0x00000000, -2147483647, 0x7fffffff)), 0x00000005)
        XCTAssertEqual(moveMask(SimdInt4.load(-1, 0x1000000f, -2147483647, -1879048194)), 0x0000000d)
        XCTAssertTrue(areAllFalse(SimdInt4.all_false()))
        XCTAssertFalse(areAllFalse(SimdInt4.all_true()))
        XCTAssertFalse(areAllFalse(SimdInt4.mask_000f()))

        XCTAssertTrue(areAllTrue(SimdInt4.all_true()))
        XCTAssertFalse(areAllTrue(SimdInt4.all_false()))
        XCTAssertFalse(areAllTrue(SimdInt4.mask_000f()))

        XCTAssertTrue(areAllFalse3(SimdInt4.all_false()))
        XCTAssertTrue(areAllFalse3(SimdInt4.mask_000f()))
        XCTAssertFalse(areAllFalse3(SimdInt4.all_true()))
        XCTAssertFalse(areAllFalse3(SimdInt4.mask_f000()))

        XCTAssertTrue(areAllTrue3(SimdInt4.all_true()))
        XCTAssertFalse(areAllTrue3(SimdInt4.all_false()))
        XCTAssertFalse(areAllTrue3(SimdInt4.mask_f000()))

        XCTAssertTrue(areAllFalse2(SimdInt4.all_false()))
        XCTAssertTrue(areAllFalse2(SimdInt4.mask_000f()))
        XCTAssertFalse(areAllFalse2(SimdInt4.all_true()))
        XCTAssertFalse(areAllFalse2(SimdInt4.mask_f000()))

        XCTAssertTrue(areAllTrue2(SimdInt4.all_true()))
        XCTAssertFalse(areAllTrue2(SimdInt4.all_false()))
        XCTAssertFalse(areAllTrue2(SimdInt4.mask_f000()))

        XCTAssertTrue(areAllFalse1(SimdInt4.all_false()))
        XCTAssertTrue(areAllFalse1(SimdInt4.mask_000f()))
        XCTAssertFalse(areAllFalse1(SimdInt4.all_true()))
        XCTAssertFalse(areAllFalse1(SimdInt4.mask_f000()))

        XCTAssertTrue(areAllTrue1(SimdInt4.all_true()))
        XCTAssertFalse(areAllTrue1(SimdInt4.all_false()))
        XCTAssertTrue(areAllTrue1(SimdInt4.mask_f000()))
    }

    func testLogicalInt() {
        let a = SimdInt4.load(-1, 0x00000000, -2147483647, 0x7fffffff)
        let b = SimdInt4.load(-2147483647, -1, 0x7fffffff, 0x00000000)
        let c = SimdInt4.load(0x01234567, -1985229329, 0x01234567, -1985229329)
        let cond = SimdInt4.load(-1, 0x00000000, -1, 0x00000000)

        let andm = and(a, b)
        EXPECT_SIMDINT_EQ(andm, -2147483647, 0x00000000, 0x00000001, 0x00000000)

        let andnm = andNot(a, b)
        EXPECT_SIMDINT_EQ(andnm, 0x7ffffffe, 0x00000000, -2147483648, 0x7fffffff)

        let orm = or(a, b)
        EXPECT_SIMDINT_EQ(orm, -1, -1, -1, 0x7fffffff)

        let xorm = xor(a, b)
        EXPECT_SIMDINT_EQ(xorm, 0x7ffffffe, -1, -2, 0x7fffffff)

        let select = select(cond, b, c)
        EXPECT_SIMDINT_EQ(select, -2147483647, -1985229329, 0x7fffffff, -1985229329)
    }

    func testShiftInt() {
        let a = SimdInt4.load(-1, 0x00000000, -2147483647, 0x7fffffff)

        let shift_l = shiftL(a, 3)
        EXPECT_SIMDINT_EQ(shift_l, -8, 0x00000000, 0x00000008, -8)

        let shift_r = shiftR(a, 3)
        EXPECT_SIMDINT_EQ(shift_r, -1, 0x00000000, -268435456, 0x0fffffff)

        let shift_ru = shiftRu(a, 3)
        EXPECT_SIMDINT_EQ(shift_ru, 0x1fffffff, 0x00000000, 0x10000000, 0x0fffffff)
    }

    func testTransposeFloat() {
        let src: [simd_float4] = [
            simd_float4.load(0.0, 1.0, 2.0, 3.0),
            simd_float4.load(4.0, 5.0, 6.0, 7.0),
            simd_float4.load(8.0, 9.0, 10.0, 11.0),
            simd_float4.load(12.0, 13.0, 14.0, 15.0)
        ]

        var t4x1 = [simd_float4()]
        transpose4x1(src, &t4x1)
        EXPECT_SIMDFLOAT_EQ(t4x1[0], 0.0, 4.0, 8.0, 12.0)

        var t1x4 = [simd_float4(), simd_float4(), simd_float4(), simd_float4()]
        transpose1x4(src, &t1x4)
        EXPECT_SIMDFLOAT_EQ(t1x4[0], 0.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t1x4[1], 1.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t1x4[2], 2.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t1x4[3], 3.0, 0.0, 0.0, 0.0)

        var t4x2 = [simd_float4(), simd_float4()]
        transpose4x2(src, &t4x2)
        EXPECT_SIMDFLOAT_EQ(t4x2[0], 0.0, 4.0, 8.0, 12.0)
        EXPECT_SIMDFLOAT_EQ(t4x2[1], 1.0, 5.0, 9.0, 13.0)

        var t2x4 = [simd_float4(), simd_float4(), simd_float4(), simd_float4()]
        transpose2x4(src, &t2x4)
        EXPECT_SIMDFLOAT_EQ(t2x4[0], 0.0, 4.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t2x4[1], 1.0, 5.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t2x4[2], 2.0, 6.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t2x4[3], 3.0, 7.0, 0.0, 0.0)

        var t4x3 = SoaFloat3()
        transpose4x3(src, &t4x3)
        EXPECT_SIMDFLOAT_EQ(t4x3.x, 0.0, 4.0, 8.0, 12.0)
        EXPECT_SIMDFLOAT_EQ(t4x3.y, 1.0, 5.0, 9.0, 13.0)
        EXPECT_SIMDFLOAT_EQ(t4x3.z, 2.0, 6.0, 10.0, 14.0)

        let soa = SoaFloat3(
                x: simd_float4.load(0.0, 1.0, 2.0, 3.0),
                y: simd_float4.load(4.0, 5.0, 6.0, 7.0),
                z: simd_float4.load(8.0, 9.0, 10.0, 11.0)
        )
        var t3x4 = [simd_float4(), simd_float4(), simd_float4(), simd_float4()]
        transpose3x4(soa, &t3x4)
        EXPECT_SIMDFLOAT_EQ(t3x4[0], 0.0, 4.0, 8.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t3x4[1], 1.0, 5.0, 9.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t3x4[2], 2.0, 6.0, 10.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(t3x4[3], 3.0, 7.0, 11.0, 0.0)

        var t4x4 = SoaQuaternion()
        transpose4x4(src, &t4x4)
        EXPECT_SIMDFLOAT_EQ(t4x4.x, 0.0, 4.0, 8.0, 12.0)
        EXPECT_SIMDFLOAT_EQ(t4x4.y, 1.0, 5.0, 9.0, 13.0)
        EXPECT_SIMDFLOAT_EQ(t4x4.z, 2.0, 6.0, 10.0, 14.0)
        EXPECT_SIMDFLOAT_EQ(t4x4.w, 3.0, 7.0, 11.0, 15.0)

        let src2 = SoaFloat4x4(cols: (
                SoaFloat4(
                        x: simd_float4.load(0.0, 16.0, 32.0, 48.0),
                        y: simd_float4.load(1.0, 17.0, 33.0, 49.0),
                        z: simd_float4.load(2.0, 18.0, 34.0, 50.0),
                        w: simd_float4.load(3.0, 19.0, 35.0, 51.0)),
                SoaFloat4(
                        x: simd_float4.load(4.0, 20.0, 36.0, 52.0),
                        y: simd_float4.load(5.0, 21.0, 37.0, 53.0),
                        z: simd_float4.load(6.0, 22.0, 38.0, 54.0),
                        w: simd_float4.load(7.0, 23.0, 39.0, 55.0)),
                SoaFloat4(
                        x: simd_float4.load(8.0, 24.0, 40.0, 56.0),
                        y: simd_float4.load(9.0, 25.0, 41.0, 57.0),
                        z: simd_float4.load(10.0, 26.0, 42.0, 58.0),
                        w: simd_float4.load(11.0, 27.0, 43.0, 59.0)),
                SoaFloat4(
                        x: simd_float4.load(12.0, 28.0, 44.0, 60.0),
                        y: simd_float4.load(13.0, 29.0, 45.0, 61.0),
                        z: simd_float4.load(14.0, 30.0, 46.0, 62.0),
                        w: simd_float4.load(15.0, 31.0, 47.0, 63.0))))
        var t16x16 = [simd_float4x4(), simd_float4x4(), simd_float4x4(), simd_float4x4()]
        transpose16x16(src2, &t16x16)
        EXPECT_SIMDFLOAT_EQ(t16x16[0].columns.0, 0.0, 1.0, 2.0, 3.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[0].columns.1, 4.0, 5.0, 6.0, 7.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[0].columns.2, 8.0, 9.0, 10.0, 11.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[0].columns.3, 12.0, 13.0, 14.0, 15.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[1].columns.0, 16.0, 17.0, 18.0, 19.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[1].columns.1, 20.0, 21.0, 22.0, 23.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[1].columns.2, 24.0, 25.0, 26.0, 27.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[1].columns.3, 28.0, 29.0, 30.0, 31.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[2].columns.0, 32.0, 33.0, 34.0, 35.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[2].columns.1, 36.0, 37.0, 38.0, 39.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[2].columns.2, 40.0, 41.0, 42.0, 43.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[2].columns.3, 44.0, 45.0, 46.0, 47.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[3].columns.0, 48.0, 49.0, 50.0, 51.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[3].columns.1, 52.0, 53.0, 54.0, 55.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[3].columns.2, 56.0, 57.0, 58.0, 59.0)
        EXPECT_SIMDFLOAT_EQ(t16x16[3].columns.3, 60.0, 61.0, 62.0, 63.0)
    }

    //MARK: - SimdQuaternion(Done)
    func testQuaternionConstant() {
        EXPECT_SIMDQUATERNION_EQ(SimdQuaternion.identity(), 0.0, 0.0, 0.0, 1.0)
    }

    func testQuaternionArithmetic() {
        let a = SimdQuaternion(xyzw: simd_float4.load(0.70710677, 0.0, 0.0, 0.70710677))
        let b = SimdQuaternion(xyzw: simd_float4.load(0.0, 0.70710677, 0.0, 0.70710677))
        let c = SimdQuaternion(xyzw: simd_float4.load(0.0, 0.70710677, 0.0, -0.70710677))
        let denorm = SimdQuaternion(xyzw: simd_float4.load(1.414212, 0.0, 0.0, 1.414212))
        let zero = SimdQuaternion(xyzw: simd_float4.zero())

        EXPECT_SIMDINT_EQ(isNormalized(a), -1, 0, 0, 0)
        EXPECT_SIMDINT_EQ(isNormalized(b), -1, 0, 0, 0)
        EXPECT_SIMDINT_EQ(isNormalized(c), -1, 0, 0, 0)
        EXPECT_SIMDINT_EQ(isNormalized(denorm), 0, 0, 0, 0)

        let conjugate = conjugate(a)
        EXPECT_SIMDQUATERNION_EQ(conjugate, -0.70710677, 0.0, 0.0, 0.70710677)

        let negate = -a
        EXPECT_SIMDQUATERNION_EQ(negate, -0.70710677, 0.0, 0.0, -0.70710677)

        let mul0 = a * conjugate
        EXPECT_SIMDQUATERNION_EQ(mul0, 0.0, 0.0, 0.0, 1.0)

        let mul1 = conjugate * a
        EXPECT_SIMDQUATERNION_EQ(mul1, 0.0, 0.0, 0.0, 1.0)

        let q1234 = SimdQuaternion(xyzw:
        simd_float4.load(1.0, 2.0, 3.0, 4.0))
        let q5678 = SimdQuaternion(xyzw:
        simd_float4.load(5.0, 6.0, 7.0, 8.0))
        let mul12345678 = q1234 * q5678
        EXPECT_SIMDQUATERNION_EQ(mul12345678, 24.0, 48.0, 48.0, -6.0)

        let norm = normalize(denorm)
        EXPECT_SIMDINT_EQ(isNormalized(norm), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ(norm, 0.7071068, 0.0, 0.0, 0.7071068)

        // EXPECT_ASSERTION(NormalizeSafe(denorm, zero), "_safer is not normalized")
        let norm_safe = normalizeSafe(denorm, b)
        EXPECT_SIMDINT_EQ(isNormalized(norm_safe), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ(norm_safe, 0.7071068, 0.0, 0.0, 0.7071068)
        let norm_safer = normalizeSafe(zero, b)
        EXPECT_SIMDINT_EQ(isNormalized(norm_safer), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ(norm_safer, 0.0, 0.70710677, 0.0, 0.70710677)

        let norm_est = normalizeEst(denorm)
        EXPECT_SIMDINT_EQ(isNormalizedEst(norm_est), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ_EST(norm_est, 0.7071068, 0.0, 0.0, 0.7071068)

        // EXPECT_ASSERTION(NormalizeSafe(denorm, zero), "_safer is not normalized")
        let norm_safe_est = normalizeSafeEst(denorm, b)
        EXPECT_SIMDINT_EQ(isNormalizedEst(norm_safe_est), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ_EST(norm_safe_est, 0.7071068, 0.0, 0.0, 0.7071068)
        let norm_safer_est = normalizeSafeEst(zero, b)
        EXPECT_SIMDINT_EQ(isNormalizedEst(norm_safer_est), -1, 0, 0, 0)
        EXPECT_SIMDQUATERNION_EQ_EST(norm_safer_est, 0.0, 0.70710677, 0.0, 0.70710677)
    }

    func testQuaternionFromVectors() {
        // Returns identity for a 0 length vector
        EXPECT_SIMDQUATERNION_EQ(SimdQuaternion.fromVectors(simd_float4.zero(),
                simd_float4.x_axis()),
                0.0, 0.0, 0.0, 1.0)

        // pi/2 around y
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.z_axis(),
                        simd_float4.x_axis()),
                0.0, 0.707106769, 0.0, 0.707106769)

        // Non unit pi/2 around y
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.z_axis(),
                        simd_float4.x_axis() *
                                simd_float4.load1(27.0)),
                0.0, 0.707106769, 0.0, 0.707106769)

        // Minus pi/2 around y
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        simd_float4.z_axis()),
                0.0, -0.707106769, 0.0, 0.707106769)

        // pi/2 around x
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.y_axis(),
                        simd_float4.z_axis()),
                0.707106769, 0.0, 0.0, 0.707106769)

        // pi/2 around z
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        simd_float4.y_axis()),
                0.0, 0.0, 0.707106769, 0.707106769)

        // pi/2 around z also
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(
                        simd_float4.load(0.707106769, 0.707106769, 0.0, 99.0),
                        simd_float4.load(-0.707106769, 0.707106769, 0.0, 93.0)),
                0.0, 0.0, 0.707106769, 0.707106769)

        // Non unit pi/2 around z also
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(
                        simd_float4.load(0.707106769, 0.707106769, 0.0, 99.0) *
                                simd_float4.load1(9.0),
                        simd_float4.load(-0.707106769, 0.707106769, 0.0, 93.0) *
                                simd_float4.load1(46.0)),
                0.0, 0.0, 0.707106769, 0.707106769)

        // Non-unit pi/2 around z
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        simd_float4.y_axis() *
                                simd_float4.load1(2.0)),
                0.0, 0.0, 0.707106769, 0.707106769)

        // Aligned vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        simd_float4.x_axis()),
                0.0, 0.0, 0.0, 1.0)

        // Non-unit aligned vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        simd_float4.x_axis() *
                                simd_float4.load1(2.0)),
                0.0, 0.0, 0.0, 1.0)

        // Opposed vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.x_axis(),
                        -simd_float4.x_axis()),
                0.0, 1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(-simd_float4.x_axis(),
                        simd_float4.x_axis()),
                0.0, -1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.y_axis(),
                        -simd_float4.y_axis()),
                0.0, 0.0, 1.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(-simd_float4.y_axis(),
                        simd_float4.y_axis()),
                0.0, 0.0, -1.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(simd_float4.z_axis(),
                        -simd_float4.z_axis()),
                0.0, -1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(-simd_float4.z_axis(),
                        simd_float4.z_axis()),
                0.0, 1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(
                        simd_float4.load(0.707106769, 0.707106769, 0.0, 93.0),
                        -simd_float4.load(0.707106769, 0.707106769, 0.0, 99.0)),
                -0.707106769, 0.707106769, 0.0, 0.0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(
                        simd_float4.load(0.0, 0.707106769, 0.707106769, 93.0),
                        -simd_float4.load(0.0, 0.707106769, 0.707106769, 99.0)),
                0.0, -0.707106769, 0.707106769, 0.0)

        // Non-unit opposed vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromVectors(
                        simd_float4.load(2.0, 2.0, 2.0, 0.0),
                        simd_float4.load(-2.0, -2.0, -2.0, 0.0)),
                0.0, -0.707106769, 0.707106769, 0)
    }

    func testQuaternionFromUnitVectors() {
        // pi/2 around y
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.z_axis(),
                        simd_float4.x_axis()),
                0.0, 0.707106769, 0.0, 0.707106769)

        // Minus pi/2 around y
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.x_axis(),
                        simd_float4.z_axis()),
                0.0, -0.707106769, 0.0, 0.707106769)

        // pi/2 around x
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.y_axis(),
                        simd_float4.z_axis()),
                0.707106769, 0.0, 0.0, 0.707106769)

        // pi/2 around z
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.x_axis(),
                        simd_float4.y_axis()),
                0.0, 0.0, 0.707106769, 0.707106769)

        // pi/2 around z also
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(
                        simd_float4.load(0.707106769, 0.707106769, 0.0, 99.0),
                        simd_float4.load(-0.707106769, 0.707106769, 0.0, 93.0)),
                0.0, 0.0, 0.707106769, 0.707106769)

        // Aligned vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.x_axis(),
                        simd_float4.x_axis()),
                0.0, 0.0, 0.0, 1.0)

        // Opposed vectors
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.x_axis(),
                        -simd_float4.x_axis()),
                0.0, 1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(-simd_float4.x_axis(),
                        simd_float4.x_axis()),
                0.0, -1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.y_axis(),
                        -simd_float4.y_axis()),
                0.0, 0.0, 1.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(-simd_float4.y_axis(),
                        simd_float4.y_axis()),
                0.0, 0.0, -1.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(simd_float4.z_axis(),
                        -simd_float4.z_axis()),
                0.0, -1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(-simd_float4.z_axis(),
                        simd_float4.z_axis()),
                0.0, 1.0, 0.0, 0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(
                        simd_float4.load(0.707106769, 0.707106769, 0.0, 93.0),
                        -simd_float4.load(0.707106769, 0.707106769, 0.0, 99.0)),
                -0.707106769, 0.707106769, 0.0, 0.0)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromUnitVectors(
                        simd_float4.load(0.0, 0.707106769, 0.707106769, 93.0),
                        -simd_float4.load(0.0, 0.707106769, 0.707106769, 99.0)),
                0.0, -0.707106769, 0.707106769, 0.0)
    }

    func testQuaternionAxisAngle() {
        // Identity
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisAngle(simd_float4.x_axis(), simd_float4.zero()),
                0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(toAxisAngle(SimdQuaternion.identity()), 1.0, 0.0, 0.0, 0.0)

        // Other axis angles
        let pi_2 = simd_float4.loadX(kPi_2)
        let qy_pi_2 = SimdQuaternion.fromAxisAngle(simd_float4.y_axis(), pi_2)
        EXPECT_SIMDQUATERNION_EQ(qy_pi_2, 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_SIMDFLOAT_EQ(toAxisAngle(qy_pi_2), 0.0, 1.0, 0.0, kPi_2)

        let qy_mpi_2 = SimdQuaternion.fromAxisAngle(simd_float4.y_axis(), -pi_2)
        EXPECT_SIMDQUATERNION_EQ(qy_mpi_2, 0.0, -0.70710677, 0.0, 0.70710677)
        EXPECT_SIMDFLOAT_EQ(toAxisAngle(qy_mpi_2), 0.0, -1.0, 0.0, kPi_2)  // q = -q
        let qmy_pi_2 = SimdQuaternion.fromAxisAngle(-simd_float4.y_axis(), pi_2)
        EXPECT_SIMDQUATERNION_EQ(qmy_pi_2, 0.0, -0.70710677, 0.0, 0.70710677)

        let any_axis = simd_float4.load(0.819865, 0.033034, -0.571604, 99.0)
        let any_angle = simd_float4.load(1.123, 99.0, 26.0, 93.0)
        let qany = SimdQuaternion.fromAxisAngle(any_axis, any_angle)
        EXPECT_SIMDQUATERNION_EQ(qany, 0.4365425, 0.017589169, -0.30435428, 0.84645736)
        EXPECT_SIMDFLOAT_EQ(toAxisAngle(qany), 0.819865, 0.033034, -0.571604, 1.123)
    }

    func testQuaternionAxisCosAngle() {
        // Identity
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisCosAngle(
                        simd_float4.y_axis(),
                        simd_float4.load(1.0, 99.0, 93.0, 5.0)),
                0.0, 0.0, 0.0, 1.0)

        // Other axis angles
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisCosAngle(
                        simd_float4.y_axis(),
                        simd_float4.load(cos(kPi_2), 99.0, 93.0, 5.0)),
                0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisCosAngle(
                        -simd_float4.y_axis(),
                        simd_float4.load(cos(kPi_2), 99.0, 93.0, 5.0)),
                0.0, -0.70710677, 0.0, 0.70710677)

        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisCosAngle(
                        simd_float4.y_axis(),
                        simd_float4.load(cos(3.0 * kPi_4), 99.0, 93.0, 5.0)),
                0.0, 0.923879504, 0.0, 0.382683426)

        EXPECT_SIMDQUATERNION_EQ(
                SimdQuaternion.fromAxisCosAngle(
                        simd_float4.load(0.819865, 0.033034, -0.571604, 99.0),
                        simd_float4.load(cos(1.123), 99.0, 93.0, 5.0)),
                0.4365425, 0.017589169, -0.30435428, 0.84645736)
    }

    func testQuaternionTransformVector() {
        // 0 length
        EXPECT_SIMDFLOAT3_EQ(transformVector(SimdQuaternion.fromAxisAngle(
                simd_float4.y_axis(),
                simd_float4.zero()),
                simd_float4.zero()),
                0, 0, 0)

        // Unit length
        EXPECT_SIMDFLOAT3_EQ(transformVector(SimdQuaternion.fromAxisAngle(
                simd_float4.y_axis(),
                simd_float4.zero()),
                simd_float4.z_axis()),
                0, 0, 1)

        let pi_2 = simd_float4.loadX(kPi_2)
        EXPECT_SIMDFLOAT3_EQ(transformVector(
                SimdQuaternion.fromAxisAngle(simd_float4.y_axis(), pi_2),
                simd_float4.y_axis()), 0, 1, 0)
        EXPECT_SIMDFLOAT3_EQ(transformVector(
                SimdQuaternion.fromAxisAngle(simd_float4.y_axis(), pi_2),
                simd_float4.x_axis()), 0, 0, -1)
        EXPECT_SIMDFLOAT3_EQ(transformVector(
                SimdQuaternion.fromAxisAngle(simd_float4.y_axis(), pi_2),
                simd_float4.z_axis()), 1, 0, 0)

        // Non unit
        EXPECT_SIMDFLOAT3_EQ(transformVector(
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), pi_2),
                simd_float4.x_axis() * simd_float4.load1(2.0)), 0, 2, 0)
    }

    //MARK: - simd_float4x4(Done)
    func testFloat4x4Constant() {
        let identity = simd_float4x4.identity()
        EXPECT_FLOAT4x4_EQ(identity, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
                1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
    }

    func testFloat4x4Arithmetic() {
        let m0 = simd_float4x4(columns: (simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0),
                simd_float4.load(12.0, 13.0, 14.0, 15.0)))
        let m1 = simd_float4x4(columns: (simd_float4.load(-0.0, -1.0, -2.0, -3.0),
                simd_float4.load(-4.0, -5.0, -6.0, -7.0),
                simd_float4.load(-8.0, -9.0, -10.0, -11.0),
                simd_float4.load(-12.0, -13.0, -14.0, -15.0)))
        let m2 = simd_float4x4(columns: (simd_float4.load(0.0, -1.0, 2.0, 3.0),
                simd_float4.load(-4.0, 5.0, 6.0, -7.0),
                simd_float4.load(8.0, -9.0, -10.0, 11.0),
                simd_float4.load(-12.0, 13.0, -14.0, 15.0)))
        let v = simd_float4.load(-0.0, -1.0, -2.0, -3.0)

        let mul_vector = m0 * v
        EXPECT_SIMDFLOAT_EQ(mul_vector, -56.0, -62.0, -68.0, -74.0)

        let transform_point = transformPoint(m0, v)
        EXPECT_SIMDFLOAT_EQ(transform_point, -8.0, -10.0, -12.0, -14.0)

        let transform_vector = transformVector(m0, v)
        EXPECT_SIMDFLOAT_EQ(transform_vector, -20.0, -23.0, -26.0, -29.0)

        let mul_mat = m0 * m1
        EXPECT_FLOAT4x4_EQ(mul_mat, -56.0, -62.0, -68.0, -74.0, -152.0, -174.0,
                -196.0, -218.0, -248.0, -286.0, -324.0, -362.0, -344.0,
                -398.0, -452.0, -506.0)

        let add_mat = m0 + m1
        EXPECT_FLOAT4x4_EQ(add_mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

        let sub_mat = m0 - m1
        EXPECT_FLOAT4x4_EQ(sub_mat, 0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0,
                18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0)

        let transpose = transpose(m0)
        EXPECT_FLOAT4x4_EQ(transpose, 0.0, 4.0, 8.0, 12.0, 1.0, 5.0, 9.0, 13.0, 2.0,
                6.0, 10.0, 14.0, 3.0, 7.0, 11.0, 15.0)

        // Invertible
        var dump = SimdInt4()
        let invert_ident = vox_oasis.invert(simd_float4x4.identity(), &dump)
        EXPECT_FLOAT4x4_EQ(invert_ident, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let invert = vox_oasis.invert(m2, &dump)
        EXPECT_FLOAT4x4_EQ(invert, 0.216667, 2.75, 1.6, 0.066666, 0.2, 2.5, 1.4,
                0.1, 0.25, 0.5, 0.25, 0.0, 0.233333, 0.5, 0.3, 0.03333)

        let invert_mul = m2 * invert
        EXPECT_FLOAT4x4_EQ(invert_mul, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        var invertible = SimdInt4()
        EXPECT_FLOAT4x4_EQ(vox_oasis.invert(m2, &invertible), 0.216667, 2.75, 1.6, 0.066666,
                0.2, 2.5, 1.4, 0.1, 0.25, 0.5, 0.25, 0.0, 0.233333, 0.5,
                0.3, 0.03333)
        XCTAssertTrue(areAllTrue1(invertible))

        // Non invertible

        var not_invertible = SimdInt4()
        EXPECT_FLOAT4x4_EQ(vox_oasis.invert(m0, &not_invertible), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        XCTAssertFalse(areAllTrue1(not_invertible))
    }

    func testFloat4x4Normal() {
        let not_orthogonal = simd_float4x4(columns: (simd_float4.load(1.0, 0.0, 0.0, 0.0),
                simd_float4.load(1.0, 0.0, 0.0, 0.0),
                simd_float4.load(0.0, 0.0, 1.0, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 1.0)))
        XCTAssertTrue(areAllTrue3(isNormalized(not_orthogonal)))
        XCTAssertTrue(areAllTrue3(isNormalized(simd_float4x4.scaling(simd_float4.load(1.0, -1.0, 1.0, 0.0)))))
        XCTAssertFalse(areAllTrue3(isNormalized(simd_float4x4.scaling(simd_float4.load(1.0, 46.0, 1.0, 0.0)))))
        XCTAssertTrue(areAllTrue3(isNormalized(simd_float4x4.identity())))
        XCTAssertTrue(areAllTrue3(isNormalized(simd_float4x4.fromAxisAngle(simd_float4.x_axis(), simd_float4.loadX(1.24)))))
        XCTAssertTrue(areAllTrue3(isNormalized(simd_float4x4.translation(
                simd_float4.load(46.0, 0.0, 0.0, 1.0)))))
    }

    func testFloat4x4Orthogonal() {
        let zero = simd_float4x4(columns: (simd_float4.load(0.0, 0.0, 0.0, 0.0),
                simd_float4.load(0.0, 1.0, 0.0, 0.0),
                simd_float4.load(0.0, 0.0, 1.0, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 1.0)))
        let not_orthogonal = simd_float4x4(columns: (
                simd_float4.load(1.0, 0.0, 0.0, 0.0),
                simd_float4.load(1.0, 0.0, 0.0, 0.0),
                simd_float4.load(0.0, 0.0, 1.0, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 1.0)))

        XCTAssertFalse(areAllTrue1(isOrthogonal(not_orthogonal)))
        XCTAssertFalse(areAllTrue1(isOrthogonal(zero)))

        let reflexion1x = simd_float4x4.scaling(simd_float4.load(-1.0, 1.0, 1.0, 0.0))
        XCTAssertFalse(areAllTrue1(isOrthogonal(reflexion1x)))
        let reflexion1y = simd_float4x4.scaling(simd_float4.load(1.0, -1.0, 1.0, 0.0))
        XCTAssertFalse(areAllTrue1(isOrthogonal(reflexion1y)))
        let reflexion1z = simd_float4x4.scaling(simd_float4.load(1.0, 1.0, -1.0, 0.0))
        XCTAssertFalse(areAllTrue1(isOrthogonal(reflexion1z)))
        let reflexion2x = simd_float4x4.scaling(simd_float4.load(1.0, -1.0, -1.0, 0.0))
        XCTAssertTrue(areAllTrue1(isOrthogonal(reflexion2x)))
        let reflexion2y = simd_float4x4.scaling(simd_float4.load(-1.0, 1.0, -1.0, 0.0))
        XCTAssertTrue(areAllTrue1(isOrthogonal(reflexion2y)))
        let reflexion2z = simd_float4x4.scaling(simd_float4.load(-1.0, -1.0, 1.0, 0.0))
        XCTAssertTrue(areAllTrue1(isOrthogonal(reflexion2z)))
        let reflexion3 = simd_float4x4.scaling(simd_float4.load(-1.0, -1.0, -1.0, 0.0))
        XCTAssertFalse(areAllTrue1(isOrthogonal(reflexion3)))

        XCTAssertTrue(areAllTrue1(isOrthogonal(simd_float4x4.identity())))
        XCTAssertTrue(areAllTrue1(isOrthogonal(simd_float4x4.translation(simd_float4.load(46.0, 0.0, 0.0, 1.0)))))
        XCTAssertTrue(areAllTrue1(isOrthogonal(simd_float4x4.fromAxisAngle(simd_float4.x_axis(), simd_float4.loadX(1.24)))))
    }

    func testFloat4x4Translate() {
        let v = simd_float4.load(-1.0, 1.0, 2.0, 3.0)
        let m0 = simd_float4x4(columns: (simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0),
                simd_float4.load(12.0, 13.0, 14.0, 15.0)))

        let translation = simd_float4x4.translation(v)
        EXPECT_FLOAT4x4_EQ(translation, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, -1.0, 1.0, 2.0, 1.0)

        let translate_mul = m0 * translation
        EXPECT_FLOAT4x4_EQ(translate_mul, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0,
                9.0, 10.0, 11.0, 32.0, 35.0, 38.0, 41.0)

        let translate = translate(m0, v)
        EXPECT_FLOAT4x4_EQ(translate, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0,
                9.0, 10.0, 11.0, 32.0, 35.0, 38.0, 41.0)
    }

    func testFloat4x4Scale() {
        let v = simd_float4.load(-1.0, 1.0, 2.0, 3.0)
        let m0 = simd_float4x4(columns: (simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0),
                simd_float4.load(12.0, 13.0, 14.0, 15.0)))

        let scaling = simd_float4x4.scaling(v)
        EXPECT_FLOAT4x4_EQ(scaling, -1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
                2.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let scale_mul = m0 * scaling
        EXPECT_FLOAT4x4_EQ(scale_mul, 0.0, -1.0, -2.0, -3.0, 4.0, 5.0, 6.0, 7.0, 16.0,
                18.0, 20.0, 22.0, 12.0, 13.0, 14.0, 15.0)

        let scale = scale(m0, v)
        EXPECT_FLOAT4x4_EQ(scale, 0.0, -1.0, -2.0, -3.0, 4.0, 5.0, 6.0, 7.0, 16.0,
                18.0, 20.0, 22.0, 12.0, 13.0, 14.0, 15.0)
    }

    func testFloat4x4ColumnMultiply() {
        let v = simd_float4.load(-1.0, -2.0, -3.0, -4.0)
        let m0 = matrix_float4x4(columns: (simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0),
                simd_float4.load(12.0, 13.0, 14.0, 15.0)))

        let column_multiply = columnMultiply(m0, v)
        EXPECT_FLOAT4x4_EQ(column_multiply, 0.0, -2.0, -6.0, -12.0, -4.0, -10.0,
                -18.0, -28.0, -8.0, -18.0, -30.0, -44.0, -12.0, -26.0,
                -42.0, -60.0)
    }

    func testFloat4x4Rotate() {
        let euler_identity = matrix_float4x4.fromEuler(simd_float4.load(0.0, 0.0, 0.0, 0.0))
        EXPECT_FLOAT4x4_EQ(euler_identity, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let euler = matrix_float4x4.fromEuler(simd_float4.load(kPi_2, 0.0, 0.0, 0.0))
        EXPECT_FLOAT4x4_EQ(euler, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        XCTAssertTrue(areAllTrue3(isNormalized(euler)))
        XCTAssertTrue(areAllTrue1(isOrthogonal(euler)))

        let quaternion_identity = matrix_float4x4.fromQuaternion(simd_float4.load(0.0, 0.0, 0.0, 1.0))
        EXPECT_FLOAT4x4_EQ(quaternion_identity, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        XCTAssertTrue(areAllTrue3(isNormalized(quaternion_identity)))
        XCTAssertTrue(areAllTrue1(isOrthogonal(quaternion_identity)))

        let quaternion = matrix_float4x4.fromQuaternion(simd_float4.load(0.0, 0.70710677, 0.0, 0.70710677))
        EXPECT_FLOAT4x4_EQ(quaternion, 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let axis_angle_identity = matrix_float4x4.fromAxisAngle(simd_float4.y_axis(), simd_float4.zero())
        EXPECT_FLOAT4x4_EQ(axis_angle_identity, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let axis_angle = matrix_float4x4.fromAxisAngle(simd_float4.y_axis(), simd_float4.loadX(kPi_2))
        EXPECT_FLOAT4x4_EQ(axis_angle, 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        XCTAssertTrue(areAllTrue3(isNormalized(axis_angle)))
        XCTAssertTrue(areAllTrue1(isOrthogonal(axis_angle)))
    }

    func testFloat4x4Affine() {
        let identity =
                matrix_float4x4.fromAffine(simd_float4.load(0.0, 0.0, 0.0, 0.0),
                        simd_float4.load(0.0, 0.0, 0.0, 1.0),
                        simd_float4.load(1.0, 1.0, 1.0, 1.0))
        EXPECT_FLOAT4x4_EQ(identity, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
                1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

        let affine = matrix_float4x4.fromAffine(
                simd_float4.load(-12.0, 46.0, 12.0, 9.0),
                simd_float4.load(0.0, 0.70710677, 0.0, 0.70710677),
                simd_float4.load(2.0, 46.0, 3.0, 1.0))
        EXPECT_FLOAT4x4_EQ(affine, 0.0, 0.0, -2.0, 0.0, 0.0, 46.0, 0.0, 0.0, 3.0, 0.0,
                0.0, 0.0, -12.0, 46.0, 12.0, 1.0)
        XCTAssertFalse(areAllTrue3(isNormalized(affine)))
        XCTAssertTrue(areAllTrue1(isOrthogonal(affine)))

        let affine_reflexion = matrix_float4x4.fromAffine(
                simd_float4.load(-12.0, 46.0, 12.0, 9.0),
                simd_float4.load(0.0, 0.70710677, 0.0, 0.70710677),
                simd_float4.load(2.0, -1.0, 3.0, 1.0))
        EXPECT_FLOAT4x4_EQ(affine_reflexion, 0.0, 0.0, -2.0, 0.0, 0.0, -1.0, 0.0, 0.0,
                3.0, 0.0, 0.0, 0.0, -12.0, 46.0, 12.0, 1.0)
        XCTAssertFalse(areAllTrue3(isNormalized(affine_reflexion)))
        XCTAssertFalse(areAllTrue1(isOrthogonal(affine_reflexion)))
    }

    func testFloat4x4ToQuaternion() {
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.identity()), 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(0.0, 0.0, 1.0, 0.0))),
                0.0, 0.0, 1.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(0.0, 1.0, 0.0, 0.0))),
                0.0, 1.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(1.0, 0.0, 0.0, 0.0))),
                1.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(0.70710677, 0.0, 0.0, 0.70710677))),
                0.70710677, 0.0, 0.0, 0.70710677)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(0.4365425, 0.017589169, -0.30435428, 0.84645736))),
                0.4365425, 0.017589169, -0.30435428, 0.84645736)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(0.56098551, -0.092295974, 0.43045932, 0.70105737))),
                0.56098551, -0.092295974, 0.43045932, 0.70105737)
        EXPECT_SIMDFLOAT_EQ(toQuaternion(matrix_float4x4.fromQuaternion(
                simd_float4.load(-0.6172133, -0.1543033, 0.0, 0.7715167))),
                -0.6172133, -0.1543033, 0.0, 0.7715167)
    }

    func testFloat4x4ToAffine() {
        var translate = simd_float4.zero()
        var rotate = simd_float4.zero()
        var scale = simd_float4.zero()

        XCTAssertFalse(toAffine(
                matrix_float4x4.scaling(simd_float4.load(0.0, 0.0, 1.0, 0.0)),
                &translate, &rotate, &scale))
        XCTAssertFalse(toAffine(
                matrix_float4x4.scaling(simd_float4.load(1.0, 0.0, 0.0, 0.0)),
                &translate, &rotate, &scale))
        XCTAssertFalse(toAffine(
                matrix_float4x4.scaling(simd_float4.load(0.0, 1.0, 0.0, 0.0)),
                &translate, &rotate, &scale))

        XCTAssertTrue(toAffine(matrix_float4x4.identity(), &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 1.0, 1.0, 1.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(0.0, 1.0, 1.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 0.0, 1.0, 1.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(1.0, 0.0, 1.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 1.0, 0.0, 1.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(1.0, 1.0, 0.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 1.0, 1.0, 0.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.translation(
                        simd_float4.load(46.0, 69.0, 58.0, 1.0)) *
                        matrix_float4x4.scaling(simd_float4.load(2.0, 3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 46.0, 69.0, 58.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, 3.0, 4.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.translation(
                        simd_float4.load(46.0, -69.0, -58.0, 1.0)) *
                        matrix_float4x4.scaling(simd_float4.load(-2.0, 3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 46.0, -69.0, -58.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 1.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, -3.0, 4.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(2.0, -3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, -3.0, 4.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(2.0, 3.0, -4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 1.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, -3.0, 4.0, 1.0)

        // This one is not a reflexion.
        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(-2.0, -3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 1.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, 3.0, 4.0, 1.0)

        // This one is not a reflexion.
        XCTAssertTrue(toAffine(
                matrix_float4x4.scaling(simd_float4.load(2.0, -3.0, -4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 1.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, 3.0, 4.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.translation(
                        simd_float4.load(46.0, -69.0, -58.0, 1.0)) *
                        matrix_float4x4.fromQuaternion(simd_float4.load(-0.6172133, -0.1543033, 0.0, 0.7715167)) *
                        matrix_float4x4.scaling(simd_float4.load(2.0, 3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 46.0, -69.0, -58.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, -0.6172133, -0.1543033, 0.0, 0.7715167)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, 3.0, 4.0, 1.0)

        XCTAssertTrue(toAffine(
                matrix_float4x4.translation(
                        simd_float4.load(46.0, -69.0, -58.0, 1.0)) *
                        matrix_float4x4.fromQuaternion(simd_float4.load(0.70710677, 0.0, 0.0, 0.70710677)) *
                        matrix_float4x4.scaling(simd_float4.load(2.0, -3.0, 4.0, 0.0)),
                &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 46.0, -69.0, -58.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.70710677, 0.0, 0.0, 0.70710677)
        EXPECT_SIMDFLOAT_EQ(scale, 2.0, -3.0, 4.0, 1.0)

        let trace = simd_float4x4(columns: (
                simd_float4.load(-0.916972, 0.0, -0.398952, 0.0),
                simd_float4.load(0.0, -1, 0.0, 0.0),
                simd_float4.load(-0.398952, 0, 0.916972, 0.0),
                simd_float4.load(0.0, 0.0, 0.0, 1.0)))
        XCTAssertTrue(toAffine(trace, &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, -0.20375007, 0.0, 0.97902298, 0.0)
        EXPECT_SIMDFLOAT_EQ(scale, 1.0, 1.0, 1.0, 1.0)

        let small = simd_float4x4(columns: (
                simd_float4.load(0.000907520065, 0.0, 0.0, 0.0),
                simd_float4.load(0.0, 0.000959928846, 0.0, 0.0),
                simd_float4.load(0.0, 0.0, 0.0159599986, 0.0),
                simd_float4.load(0.00649994006, 0.00719946623, -0.000424541620, 0.999999940)))
        XCTAssertTrue(toAffine(small, &translate, &rotate, &scale))
        EXPECT_SIMDFLOAT_EQ(translate, 0.00649994006, 0.00719946623, -0.000424541620, 1.0)
        EXPECT_SIMDFLOAT_EQ(rotate, 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scale, 0.000907520065, 0.000959928846, 0.0159599986, 1.0)
    }
}
