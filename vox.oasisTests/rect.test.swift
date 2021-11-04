//
//  rect.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class RectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRectInt() {
        let rect = RectInt(10, 20, 30, 40)

        XCTAssertEqual(rect.right(), 40)
        XCTAssertEqual(rect.top(), 60)

        XCTAssertTrue(rect.is_inside(10, 20))
        XCTAssertTrue(rect.is_inside(39, 59))

        XCTAssertFalse(rect.is_inside(9, 20))
        XCTAssertFalse(rect.is_inside(10, 19))
        XCTAssertFalse(rect.is_inside(40, 59))
        XCTAssertFalse(rect.is_inside(39, 60))
    }

    func testRectFloat() {
        let rect = RectFloat(10.0, 20.0, 30.0, 40.0)

        XCTAssertEqual(rect.right(), 40.0)
        XCTAssertEqual(rect.top(), 60.0)

        XCTAssertTrue(rect.is_inside(10.0, 20.0))
        XCTAssertTrue(rect.is_inside(39.0, 59.0))

        XCTAssertFalse(rect.is_inside(9.0, 20.0))
        XCTAssertFalse(rect.is_inside(10.0, 19.0))
        XCTAssertFalse(rect.is_inside(40.0, 59.0))
        XCTAssertFalse(rect.is_inside(39.0, 60.0))
    }

}
