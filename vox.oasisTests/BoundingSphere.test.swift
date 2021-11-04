//
//  BoundingSphere.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/14.
//


import XCTest
@testable import vox_oasis

class BoundingSphereTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let sphere1 = BoundingSphere()
        let sphere2 = BoundingSphere()

        // Create a same sphere by different param.
        let points = [
            Vector3(0, 0, 0),
            Vector3(-1, 0, 0),
            Vector3(0, 0, 0),
            Vector3(0, 1, 0),
            Vector3(1, 1, 1),
            Vector3(0, 0, 1),
            Vector3(-1, -0.5, -0.5),
            Vector3(0, -0.5, -0.5),
            Vector3(1, 0, -1),
            Vector3(0, -1, 0)
        ]
        BoundingSphere.fromPoints(points: points, out: sphere1)

        let box = BoundingBox(Vector3(-1, -1, -1), Vector3(1, 1, 1))
        BoundingSphere.fromBox(box: box, out: sphere2)

        let center1 = sphere1.center
        let radius1 = sphere1.radius
        let center2 = sphere2.center
        let radius2 = sphere2.radius
        XCTAssertEqual(Vector3.equals(left: center1, right: center2), true)
        XCTAssertEqual(radius1, radius2)
    }

    func testClone() {
        let a = BoundingSphere(Vector3(0, 0, 0), 3)
        let b = a.clone()
        XCTAssertEqual(Vector3.equals(left: a.center, right: b.center), true)
        XCTAssertEqual(a.radius, b.radius)
    }

    func testCloneTo() {
        let a = BoundingSphere(Vector3(0, 0, 0), 3)
        let out = BoundingSphere()
        a.cloneTo(target: out)
        XCTAssertEqual(Vector3.equals(left: a.center, right: out.center), true)
        XCTAssertEqual(a.radius, out.radius)
    }
}
