//
//  Vector2.test.swift
//  DigitalVox2Tests
//
//  Created by 杨丰 on 2021/9/1.
//

import XCTest
@testable import vox_render

class Vector2Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdd() {
        let a = Vector2(2, 3);
        let b = Vector2(-3, 5);
        let out = Vector2();

        Vector2.add(left: a, right: b, out: out);
        XCTAssertEqual(out.x, -1);
        XCTAssertEqual(out.y, 8);
    }
    
    func testSubtract() {
        let a =  Vector2(2, 3);
        let b =  Vector2(-3, 5);
        let out =  Vector2();

        Vector2.subtract(left: a, right: b, out: out);
        XCTAssertEqual(out.x, 5);
        XCTAssertEqual(out.y, -2);
    }
}
