//
//  Matrix3x3.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/13.
//

import XCTest
@testable import vox_oasis

class Matrix3x3Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)
        let out = Matrix3x3()

        Matrix3x3.add(left: a, right: b, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out,
                right: Matrix3x3(m11: 10, m12: 10, m13: 10,
                        m21: 10, m22: 10, m23: 10,
                        m31: 10, m32: 10, m33: 10)), true)
    }

    func testStaticSubtract() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)
        let out = Matrix3x3()

        Matrix3x3.subtract(left: a, right: b, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: -8, m12: -6, m13: -4,
                m21: -2, m22: 0, m23: 2,
                m31: 4, m32: 6, m33: 8)), true)
    }

    func testStaticMultiply() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)
        let out = Matrix3x3()

        Matrix3x3.multiply(left: a, right: b, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 90, m12: 114, m13: 138,
                m21: 54, m22: 69, m23: 84,
                m31: 18, m32: 24, m33: 30)), true)
    }

    func testStaticEquals() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: 9)
        let c = Matrix3x3(m11: 9, m12: 8, m13: 7, m21: 6, m22: 5, m23: 4, m31: 3, m32: 2, m33: 1)

        XCTAssertEqual(Matrix3x3.equals(left: a, right: b), true)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: c), false)
    }

    func testStaticLerp() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let c = Matrix3x3()
        Matrix3x3.lerp(start: a, end: b, t: 0.78, out: c)

        XCTAssertEqual(Matrix3x3.equals(left: a, right: b), true)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: c), true)
    }

    func testStaticFromXXX() {
        let out = Matrix3x3()
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12)

        // Matrix
        _ = out.setValueByMatrix(a: a)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 5, m22: 6, m23: 7,
                m31: 9, m32: 10, m33: 11)), true)

        // quat
        let q = Quaternion(1, 2, 3, 4)
        Matrix3x3.rotationQuaternion(quaternion: q, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: -25, m12: 28, m13: -10,
                m21: -20, m22: -19, m23: 20,
                m31: 22, m32: 4, m33: -9)), true)

        // scaling
        let scale = Vector2(1, 2)
        Matrix3x3.scaling(s: scale, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 0, m13: 0,
                m21: 0, m22: 2, m23: 0,
                m31: 0, m32: 0, m33: 1)), true)

        // translation
        let translation = Vector2(2, 3)
        Matrix3x3.translation(translation: translation, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 0, m13: 0,
                m21: 0, m22: 1, m23: 0,
                m31: 2, m32: 3, m33: 1)), true)
    }

    func testStaticInvert() {
        let out = Matrix3x3()
        let mat3 = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 2, m22: 2, m23: 4,
                m31: 3, m32: 1, m33: 3)

        Matrix3x3.invert(a: mat3, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: -1.5, m13: 1,
                m21: 3, m22: -3, m23: 1,
                m31: -2, m32: 2.5, m33: -1)), true)
    }

    func testStaticNormalMatrix() {
        let out = Matrix3x3()
        let mat4 = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12)

        Matrix3x3.normalMatrix(mat4: mat4, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 0, m13: 0,
                m21: 0, m22: 1, m23: 0,
                m31: 0, m32: 0, m33: 1)), true)
    }

    func testStaticRotate() {
        let out = Matrix3x3()
        let mat3 = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        Matrix3x3.rotate(a: mat3, r: Float.pi / 3, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out,
                right: Matrix3x3(m11: 3.964101552963257, m12: 5.330127239227295, m13: 6.696152210235596,
                        m21: 1.133974552154541, m22: 0.7679491639137268, m23: 0.4019237756729126,
                        m31: 7, m32: 8, m33: 9)), true)
    }

    func testStaticScale() {
        let out = Matrix3x3()
        let mat3 = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        Matrix3x3.scale(m: mat3, s: Vector2(1, 2), out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 8, m22: 10, m23: 12,
                m31: 7, m32: 8, m33: 9)), true)
    }

    func testStaticTranslate() {
        let out = Matrix3x3()
        let mat3 = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        Matrix3x3.translate(m: mat3, translation: Vector2(1, 2), out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 16, m32: 20, m33: 24)), true)
    }

    func testStaticTranspose() {
        let out = Matrix3x3()
        let mat3 = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        Matrix3x3.transpose(a: mat3, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 4, m13: 7,
                m21: 2, m22: 5, m23: 8,
                m31: 3, m32: 6, m33: 9)), true)
        Matrix3x3.transpose(a: out, out: out)
        XCTAssertEqual(Matrix3x3.equals(left: out, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)), true)
    }

    func testSetValue() {
        let a = Matrix3x3()
        _ = a.setValue(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)), true)
    }

    func testSetValueByxxx() {
        let a = Matrix3x3()
        _ = a.setValueByArray(array: [1, 2, 3, 4, 5, 6, 7, 8, 9])
        let b = Matrix3x3()
        _ = b.setValueByMatrix(a: Matrix(m11: 1, m12: 2, m13: 3, m14: 0,
                m21: 4, m22: 5, m23: 6, m24: 0,
                m31: 7, m32: 8, m33: 9, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1))
        let c = Matrix3x3()
        var arr = [Float](repeating: 0, count: 9)
        a.toArray(out: &arr)
        _ = c.setValueByArray(array: arr)

        XCTAssertEqual(Matrix3x3.equals(left: a, right: b), true)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: c), true)
        XCTAssertEqual(Matrix3x3.equals(left: b, right: c), true)
    }

    func testClone() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = a.clone()

        XCTAssertEqual(Matrix3x3.equals(left: a, right: b), true)
    }

    func testCloneTo() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let out = Matrix3x3()

        a.cloneTo(target: out)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: out), true)
    }

    func testAdd() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)

        _ = a.add(right: b)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 10, m12: 10, m13: 10,
                m21: 10, m22: 10, m23: 10,
                m31: 10, m32: 10, m33: 10)), true)
    }

    func testSubtract() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)

        _ = a.subtract(right: b)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: -8, m12: -6, m13: -4,
                m21: -2, m22: 0, m23: 2,
                m31: 4, m32: 6, m33: 8)), true)
    }

    func testMultiply() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        let b = Matrix3x3(m11: 9, m12: 8, m13: 7,
                m21: 6, m22: 5, m23: 4,
                m31: 3, m32: 2, m33: 1)

        _ = a.multiply(right: b)
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 90, m12: 114, m13: 138,
                m21: 54, m22: 69, m23: 84,
                m31: 18, m32: 24, m33: 30)), true)
    }

    func testDeterminant() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)
        XCTAssertEqual(a.determinant(), 0)
    }

    func testInvert() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 2, m22: 2, m23: 4,
                m31: 3, m32: 1, m33: 3)

        _ = a.invert()
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: -1.5, m13: 1,
                m21: 3, m22: -3, m23: 1,
                m31: -2, m32: 2.5, m33: -1)), true)
    }

    func testRotate() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        _ = a.rotate(r: Float.pi / 3)
        XCTAssertEqual(Matrix3x3.equals(left: a,
                right: Matrix3x3(m11: 3.964101552963257, m12: 5.330127239227295, m13: 6.696152210235596,
                        m21: 1.133974552154541, m22: 0.7679491639137268, m23: 0.4019237756729126,
                        m31: 7, m32: 8, m33: 9)), true)
    }

    func testScale() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        _ = a.scale(s: Vector2(1, 2))
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 8, m22: 10, m23: 12,
                m31: 7, m32: 8, m33: 9)), true)
    }

    func testTranslate() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)

        _ = a.translate(translation: Vector2(1, 2))
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 16, m32: 20, m33: 24)), true)
    }

    func testTranspose() {
        let a = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: 9)

        _ = a.transpose()
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: 4, m13: 7,
                m21: 2, m22: 5, m23: 8,
                m31: 3, m32: 6, m33: 9)), true)
        _ = a.transpose()
        XCTAssertEqual(Matrix3x3.equals(left: a, right: Matrix3x3(m11: 1, m12: 2, m13: 3,
                m21: 4, m22: 5, m23: 6,
                m31: 7, m32: 8, m33: 9)), true)
    }
}
