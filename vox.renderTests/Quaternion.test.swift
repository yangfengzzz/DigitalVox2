//
//  Quaternion.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/13.
//

import XCTest
@testable import vox_render

class QuaternionTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Quaternion(2, 3, 4, 1)
        let b = Quaternion(-3, 5, 0, 2)
        let out = Quaternion()

        Quaternion.add(left: a, right: b, out: out)
        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
        XCTAssertEqual(out.z, 4)
        XCTAssertEqual(out.w, 3)
    }

    func testMultiply() {
        let a = Quaternion(2, 3, 4, 1)
        let b = Quaternion(-3, 5, 0, 2)
        let out = Quaternion()

        Quaternion.multiply(left: a, right: b, out: out)
        XCTAssertEqual(out.x, -19)
        XCTAssertEqual(out.y, -1)
        XCTAssertEqual(out.z, 27)
        XCTAssertEqual(out.w, -7)
    }

    func testConjugate() {
        let a = Quaternion(2, 3, 4, 5)
        let out = Quaternion()

        Quaternion.conjugate(a: a, out: out)
        XCTAssertEqual(out.x, -2)
        XCTAssertEqual(out.y, -3)
        XCTAssertEqual(out.z, -4)
        XCTAssertEqual(out.w, 5)
    }

    func testDot() {
        let a = Quaternion(2, 3, 1, 1)
        let b = Quaternion(-4, 5, 1, 1)

        XCTAssertEqual(Quaternion.dot(left: a, right: b), 9)
        XCTAssertEqual(a.dot(quat: b), 9)
    }

    func testEquals() {
        let a = Quaternion(1, 2, 3, 4)
        let b = Quaternion(1 + MathUtil.zeroTolerance * 0.9, 2, 3, 4)

        XCTAssertEqual(Quaternion.equals(left: a, right: b), true)
    }

    func testRotationAxisAngle() {
        let a = Vector3(3, 7, 5)
        let b = Vector3()
        let out = Quaternion()
        Quaternion.rotationAxisAngle(axis: a, rad: Float.pi / 3, out: out)
        let rad = out.getAxisAngle(out: b)

        XCTAssertEqual(MathUtil.equals(rad, Float.pi / 3), true)
        XCTAssertEqual(Vector3.equals(left: b.normalize(), right: a.normalize()), true)
    }

    func testRotationEuler() {
        let out1 = Quaternion()
        let out2 = Quaternion()
        Quaternion.rotationEuler(x: 0, y: Float.pi / 3, z: Float.pi / 2, out: out1)
        Quaternion.rotationYawPitchRoll(yaw: 0, pitch: Float.pi / 3, roll: Float.pi / 2, out: out2)

        let a = out1.toEuler(out: Vector3())
        let b = out2.toYawPitchRoll(out: Vector3())
        XCTAssertEqual(Vector3.equals(left: a, right: Vector3(0, Float.pi / 3, Float.pi / 2)), true)
        XCTAssertEqual(Vector3.equals(left: b, right: Vector3(0, Float.pi / 3, Float.pi / 2)), true)
    }

    func testRotationMatrix3x3() {
        let a1 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: 9)
        let a2 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: -5, m23: 6, m31: 7, m32: 8, m33: -9)
        let a3 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: -9)
        let a4 = Matrix3x3(m11: -7, m12: 2, m13: 3, m21: 4, m22: -5, m23: 6, m31: 7, m32: 8, m33: 9)
        let out = Quaternion()

        Quaternion.rotationMatrix3x3(m: a1, out: out)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(-0.25, 0.5, -0.25, 2)), true)
        Quaternion.rotationMatrix3x3(m: a2, out: out)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(2, 0.75, 1.25, -0.25)), true)
        Quaternion.rotationMatrix3x3(m: a3, out: out)
        XCTAssertEqual(
                Quaternion.equals(
                        left: out,
                        right: Quaternion(0.8017837257372732, 1.8708286933869707, 1.8708286933869709, 0.5345224838248488)
                ), true)
        Quaternion.rotationMatrix3x3(m: a4, out: out)
        XCTAssertEqual(
                Quaternion.equals(
                        left: out,
                        right: Quaternion(1.066003581778052, 1.4924050144892729, 2.345207879911715, -0.21320071635561041)
                ), true)
    }
}
