//
//  animation_builder_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AnimationBuilderTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        do {  // Building an empty Animation fails because animation duration
            // must be >= 0.
            var raw_animation = RawAnimation()
            raw_animation.duration = -1.0 // Negative duration.
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building an empty Animation fails because animation duration
            // must be >= 0.
            var raw_animation = RawAnimation()
            raw_animation.duration = 0.0  // Invalid duration.
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building an animation with too much tracks fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(),
                    count: SoaSkeleton.Constants.kMaxJoints.rawValue + 1)
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building default animation succeeds.
            let raw_animation = RawAnimation()
            XCTAssertEqual(raw_animation.duration, 1.0)
            XCTAssertTrue(raw_animation.validate())

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
        }

        do {  // Building an animation with max joints succeeds.
            var raw_animation = RawAnimation()
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(),
                    count: SoaSkeleton.Constants.kMaxJoints.rawValue)
            XCTAssertEqual(raw_animation.num_tracks(), SoaSkeleton.Constants.kMaxJoints.rawValue)
            XCTAssertTrue(raw_animation.validate())

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
        }
    }

    func testBuild() {

    }

    func testName() {

    }

    func testSort() {

    }
}
