//
//  Matrix.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/13.
//

import Foundation

import XCTest
@testable import vox_render

class MatrixTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticMultiply() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = Matrix(m11: 16, m12: 15, m13: 14, m14: 13,
                m21: 12, m22: 11, m23: 10, m24: 9,
                m31: 8.88, m32: 7, m33: 6, m34: 5,
                m41: 4, m42: 3, m43: 2, m44: 1)
        let out = Matrix()

        Matrix.multiply(left: a, right: b, out: out)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 386, m12: 456.599976, m13: 506.799988, m14: 560,
                        m21: 274, m22: 325, m23: 361.600006, m24: 400,
                        m31: 162.880005, m32: 195.1600004, m33: 219.304001, m34: 243.520004,
                        m41: 50, m42: 61.7999992, m43: 71.1999969, m44: 80)
        ), true)
    }
}
