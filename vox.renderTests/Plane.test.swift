//
//  Plane.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/14.
//

import XCTest
@testable import vox_render

class PlaneTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let point1 = Vector3(0, 1, 0)
        let point2 = Vector3(0, 1, 1)
        let point3 = Vector3(1, 1, 0)
        let plane1 = Plane()
        Plane.fromPoints(point0: point1, point1: point2, point2: point3, out: plane1)
        let plane2 = Plane(Vector3(0, 1, 0), -1)

        XCTAssertEqual(plane1.distance - plane2.distance, 0)
        _ = plane1.normalize()
        _ = plane2.normalize()
        XCTAssertEqual(Vector3.equals(left: plane1.normal, right: plane2.normal), true)
    }

    func testClone() {
        let plane1 = Plane(Vector3(0, 1, 0), -1)
        let plane2 = plane1.clone()
        XCTAssertEqual(plane1.distance - plane2.distance, 0)

        let plane3 = Plane()
        plane1.cloneTo(target: plane3)
        XCTAssertEqual(plane1.distance - plane3.distance, 0)
    }
}
