//
//  Vector3.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/13.
//

import XCTest
@testable import vox_render

class Vector3Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Vector3(2, 3, 4)
        let b = Vector3(-3, 5, 0)
        let out = Vector3()

        Vector3.add(left: a, right: b, out: out)
        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
        XCTAssertEqual(out.z, 4)
    }
}
