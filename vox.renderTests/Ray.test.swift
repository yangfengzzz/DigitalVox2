//
//  Ray.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/14.
//

import XCTest
@testable import vox_render

class RayTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRayPlane() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let plane = Plane(Vector3(0, 1, 0), -3)

        XCTAssertEqual(ray.intersectPlane(plane: plane), -plane.distance)
    }

    func testRaySphere() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let sphere = BoundingSphere(Vector3(0, 5, 0), 1)

        XCTAssertEqual(ray.intersectSphere(sphere: sphere), 4)
    }

    func testRayBox() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let box = BoundingBox()
        BoundingBox.fromCenterAndExtent(center: Vector3(0, 20, 0), extent: Vector3(5, 5, 5), out: box)

        XCTAssertEqual(ray.intersectBox(box: box), 15)
    }

    func testRayGetPoint() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let out = Vector3()
        _ = ray.getPoint(distance: 10, out: out)

        XCTAssertEqual(Vector3.equals(left: out, right: Vector3(0, 10, 0)), true)
    }
}
