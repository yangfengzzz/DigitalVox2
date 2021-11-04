//
//  box.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class BoxTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoxValidity() {
        XCTAssertFalse(Box().is_valid())
        XCTAssertFalse(Box(VecFloat3(0.0, 1.0, 2.0), VecFloat3(0.0, -1.0, 2.0)).is_valid())
        XCTAssertTrue(Box(VecFloat3(0.0, -1.0, 2.0), VecFloat3(0.0, 1.0, 2.0)).is_valid())
        XCTAssertTrue(Box(VecFloat3(0.0, 1.0, 2.0), VecFloat3(0.0, 1.0, 2.0)).is_valid())
    }

    func testBoxInside() {
        let invalid = Box(VecFloat3(0.0, 1.0, 2.0), VecFloat3(0.0, -1.0, 2.0))
        XCTAssertFalse(invalid.is_valid())
        XCTAssertFalse(invalid.is_inside(VecFloat3(0.0, 1.0, 2.0)))
        XCTAssertFalse(invalid.is_inside(VecFloat3(0.0, -0.5, 2.0)))
        XCTAssertFalse(invalid.is_inside(VecFloat3(-1.0, -2.0, -3.0)))

        let valid = Box(VecFloat3(-1.0, -2.0, -3.0), VecFloat3(1.0, 2.0, 3.0))
        XCTAssertTrue(valid.is_valid())
        XCTAssertFalse(valid.is_inside(VecFloat3(0.0, -3.0, 0.0)))
        XCTAssertFalse(valid.is_inside(VecFloat3(0.0, 3.0, 0.0)))
        XCTAssertTrue(valid.is_inside(VecFloat3(-1.0, -2.0, -3.0)))
        XCTAssertTrue(valid.is_inside(VecFloat3(0.0, 0.0, 0.0)))
    }

    func testBoxMerge() {
        let invalid1 = Box(VecFloat3(0.0, 1.0, 2.0), VecFloat3(0.0, -1.0, 2.0))
        XCTAssertFalse(invalid1.is_valid())
        let invalid2 = Box(VecFloat3(0.0, -1.0, 2.0), VecFloat3(0.0, 1.0, -2.0))
        XCTAssertFalse(invalid2.is_valid())

        let valid1 = Box(VecFloat3(-1.0, -2.0, -3.0), VecFloat3(1.0, 2.0, 3.0))
        XCTAssertTrue(valid1.is_valid())
        let valid2 = Box(VecFloat3(0.0, 5.0, -8.0), VecFloat3(1.0, 6.0, 0.0))
        XCTAssertTrue(valid2.is_valid())

        // Both boxes are invalid.
        XCTAssertFalse(merge(invalid1, invalid2).is_valid())

        // One box is invalid.
        XCTAssertTrue(merge(invalid1, valid1).is_valid())
        XCTAssertTrue(merge(valid1, invalid1).is_valid())

        // Both boxes are valid.
        let merge = merge(valid1, valid2)
        EXPECT_FLOAT3_EQ(merge.min, -1.0, -2.0, -8.0)
        EXPECT_FLOAT3_EQ(merge.max, 1.0, 6.0, 3.0)
    }

    func testBoxTransform() {
        let a = Box(VecFloat3(1.0, 2.0, 3.0), VecFloat3(4.0, 5.0, 6.0))

        let ia = transformBox(matrix_float4x4.identity(), a)
        EXPECT_FLOAT3_EQ(ia.min, 1.0, 2.0, 3.0)
        EXPECT_FLOAT3_EQ(ia.max, 4.0, 5.0, 6.0)

        let ta = transformBox(matrix_float4x4.translation(simd_float4.load(2.0, -2.0, 3.0, 0.0)), a)
        EXPECT_FLOAT3_EQ(ta.min, 3.0, 0.0, 6.0)
        EXPECT_FLOAT3_EQ(ta.max, 6.0, 3.0, 9.0)

        let ra = transformBox(matrix_float4x4.fromAxisAngle(simd_float4.y_axis(), simd_float4.loadX(kPi)), a)
        EXPECT_FLOAT3_EQ(ra.min, -4.0, 2.0, -6.0)
        EXPECT_FLOAT3_EQ(ra.max, -1.0, 5.0, -3.0)
    }

    func testBoxBuild() {
        let points = [VecFloat3(0.0, 0.0, 0.0),
                      VecFloat3(1.0, -1.0, 0.0),
                      VecFloat3(0.0, 0.0, 46.0),
                      VecFloat3(-27.0, 0.0, 0.0),
                      VecFloat3(0.0, 58.0, 0.0)]

        // Builds from a single point
        let single_valid = Box(points[1])
        XCTAssertTrue(single_valid.is_valid())
        EXPECT_FLOAT3_EQ(single_valid.min, 1.0, -1.0, 0.0)
        EXPECT_FLOAT3_EQ(single_valid.max, 1.0, -1.0, 0.0)

        let multi_valid = Box(points)
        XCTAssertTrue(multi_valid.is_valid())
        EXPECT_FLOAT3_EQ(multi_valid.min, -27.0, -1.0, 0.0)
        EXPECT_FLOAT3_EQ(multi_valid.max, 1.0, 58.0, 46.0)
    }
}
