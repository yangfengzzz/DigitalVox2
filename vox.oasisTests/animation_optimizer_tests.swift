//
//  animation_optimizer_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AnimationOptimizerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        let optimizer = AnimationOptimizer()

        do {  // nullptr output.
            let input = RawAnimation()
            XCTAssertTrue(input.validate())
        }

        do {  // Invalid input animation.
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let skeleton_builder = SkeletonBuilder()
            let skeleton = skeleton_builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)

            var input = RawAnimation()
            input.duration = -1.0
            XCTAssertFalse(input.validate())

            // Builds animation
            var output = RawAnimation()
            output.duration = -1.0
            output.tracks = [RawAnimation.JointTrack()]
            XCTAssertFalse(optimizer.eval(input, skeleton!, &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }

        do {  // Invalid skeleton.
            let skeleton = SoaSkeleton()

            var input = RawAnimation()
            input.tracks = [RawAnimation.JointTrack()]
            XCTAssertTrue(input.validate())

            // Builds animation
            var output = RawAnimation()
            XCTAssertFalse(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }
    }

    func testName() {
        // Prepares a skeleton.
        let raw_skeleton = RawSkeleton()
        let skeleton_builder = SkeletonBuilder()
        let skeleton = skeleton_builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)

        let optimizer = AnimationOptimizer()

        var input = RawAnimation()
        input.name = "Test_Animation"
        input.duration = 1.0

        XCTAssertTrue(input.validate())

        var output = RawAnimation()
        XCTAssertTrue(optimizer.eval(input, skeleton!, &output))
        XCTAssertEqual(output.num_tracks(), 0)
        XCTAssertEqual(output.name, "Test_Animation")
    }

    func testOptimize() {

    }

    func testOptimizeOverride() {

    }
}
