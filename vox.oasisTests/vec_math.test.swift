//
//  vec_math.test.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class VecMathTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVectorLoad4() throws {
        EXPECT_FLOAT4_EQ(VecFloat4(46.0), 46.0, 46.0, 46.0, 46.0)
        EXPECT_FLOAT4_EQ(VecFloat4(-1.0, 0.0, 1.0, 2.0), -1.0, 0.0, 1.0, 2.0)
        let f3 = VecFloat3(-1.0, 0.0, 1.0)
        EXPECT_FLOAT4_EQ(VecFloat4(f3, 2.0), -1.0, 0.0, 1.0, 2.0)
        let f2 = VecFloat2(-1.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4(f2, 1.0, 2.0), -1.0, 0.0, 1.0, 2.0)
    }

    func testVectorLoad3() {
        EXPECT_FLOAT3_EQ(VecFloat3(46.0), 46.0, 46.0, 46.0)
        EXPECT_FLOAT3_EQ(VecFloat3(-1.0, 0.0, 1.0), -1.0, 0.0, 1.0)
        let f2 = VecFloat2(-1.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3(f2, 1.0), -1.0, 0.0, 1.0)
    }

    func testVectorLoad2() {
        EXPECT_FLOAT2_EQ(VecFloat2(46.0), 46.0, 46.0)
        EXPECT_FLOAT2_EQ(VecFloat2(-1.0, 0.0), -1.0, 0.0)
    }

    func testVectorConstant4() {
        EXPECT_FLOAT4_EQ(VecFloat4.zero(), 0.0, 0.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.one(), 1.0, 1.0, 1.0, 1.0)
        EXPECT_FLOAT4_EQ(VecFloat4.x_axis(), 1.0, 0.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.y_axis(), 0.0, 1.0, 0.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.z_axis(), 0.0, 0.0, 1.0, 0.0)
        EXPECT_FLOAT4_EQ(VecFloat4.w_axis(), 0.0, 0.0, 0.0, 1.0)
    }

    func testVectorConstant3() {
        EXPECT_FLOAT3_EQ(VecFloat3.zero(), 0.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.one(), 1.0, 1.0, 1.0)
        EXPECT_FLOAT3_EQ(VecFloat3.x_axis(), 1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.y_axis(), 0.0, 1.0, 0.0)
        EXPECT_FLOAT3_EQ(VecFloat3.z_axis(), 0.0, 0.0, 1.0)
    }

    func testVectorConstant2() {
        EXPECT_FLOAT2_EQ(VecFloat2.zero(), 0.0, 0.0)
        EXPECT_FLOAT2_EQ(VecFloat2.one(), 1.0, 1.0)
        EXPECT_FLOAT2_EQ(VecFloat2.x_axis(), 1.0, 0.0)
        EXPECT_FLOAT2_EQ(VecFloat2.y_axis(), 0.0, 1.0)
    }
}
