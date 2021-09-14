//
//  Color.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/14.
//

import XCTest
@testable import vox_render

class ColorTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let color1 = Color(1, 0.5, 0.5, 1)
        let color2 = Color()
        color2.r = 1
        color2.g = 0.5
        color2.b = 0.5
        color2.a = 1

        XCTAssertEqual(Color.equals(left: color1, right: color2), true)
    }

    func testSetValue() {
        let color1 = Color(1, 0.5, 0.5, 1)
        let color2 = Color()
        _ = color2.setValue(r: 1, g: 0.5, b: 0.5, a: 1)

        XCTAssertEqual(Color.equals(left: color1, right: color2), true)
    }

    func testScale() {
        let color1 = Color(0.5, 0.5, 0.5, 0.5)
        let color2 = Color(1, 1, 1, 1)

        _ = color1.scale(s: 2)
        XCTAssertEqual(color1.r, color2.r)
        XCTAssertEqual(color1.g, color2.g)
        XCTAssertEqual(color1.b, color2.b)
        XCTAssertEqual(color1.a, color2.a)

        Color.scale(left: color1, s: 0.5, out: color2)
        XCTAssertEqual(color2.r, 0.5)
        XCTAssertEqual(color2.g, 0.5)
        XCTAssertEqual(color2.b, 0.5)
        XCTAssertEqual(color2.a, 0.5)
    }

    func testAdd() {
        let color1 = Color(1, 0, 0, 0)
        let color2 = Color(0, 1, 0, 0)

        _ = color1.add(color: color2)
        XCTAssertEqual(color1.r, 1)
        XCTAssertEqual(color1.g, 1)
        XCTAssertEqual(color1.b, 0)
        XCTAssertEqual(color1.a, 0)

        Color.add(left: color1, right: Color(0, 0, 1, 0), out: color2)
        XCTAssertEqual(color2.r, 1)
        XCTAssertEqual(color2.g, 1)
        XCTAssertEqual(color2.b, 1)
        XCTAssertEqual(color2.a, 0)
    }

    func testClone() {
        let a = Color()
        let b = a.clone()

        XCTAssertEqual(Color.equals(left: a, right: b), true)
    }

    func testCloneTo() {
        let a = Color()
        let out = Color()

        a.cloneTo(target: out)
        XCTAssertEqual(Color.equals(left: a, right: out), true)
    }

    func testLinearAndGamma() {
        let fixColor = { (color: Color) in
            color.r = floor(color.r * 1000) / 1000
            color.g = floor(color.g * 1000) / 1000
            color.b = floor(color.b * 1000) / 1000
        }

        let colorLinear = Color()
        let colorGamma = Color()
        let colorNewLinear = Color()

        for _ in 0..<100 {
            colorLinear.r = Float.random(in: 0..<1)
            colorLinear.g = Float.random(in: 0..<1)
            colorLinear.b = Float.random(in: 0..<1)
            fixColor(colorLinear)

            _ = colorLinear.toGamma(out: colorGamma)
            _ = colorGamma.toLinear(out: colorNewLinear)

            fixColor(colorLinear)
            fixColor(colorNewLinear)

            XCTAssertEqual(simd_distance(colorLinear.elements, colorNewLinear.elements) < 1.0e-3, true)
        }
    }
}
