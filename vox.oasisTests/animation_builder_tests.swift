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
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        do {  // Building an Animation with unsorted keys fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            // Adds 2 unordered keys
            let first_key = RawAnimation.TranslationKey(0.8, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)
            let second_key = RawAnimation.TranslationKey(0.2, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(second_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with invalid key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            // Adds a key with a time greater than animation duration.
            let first_key = RawAnimation.TranslationKey(2.0, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with unsorted key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

            // Adds 2 unsorted keys.
            let first_key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)
            let second_key = RawAnimation.TranslationKey(0.1, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(second_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with equal key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

            // Adds 2 unsorted keys.
            let key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(key)
            raw_animation.tracks[0].translations.append(key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building a valid Animation with empty tracks succeeds.
            var raw_animation = RawAnimation()
            raw_animation.duration = 46.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 46)

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }
            XCTAssertEqual(anim.duration(), 46.0)
            XCTAssertEqual(anim.num_tracks(), 46)
        }

        do {  // Building a valid Animation with 1 track succeeds.
            var raw_animation = RawAnimation()
            raw_animation.duration = 46.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            let first_key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }
            XCTAssertEqual(anim.duration(), 46.0)
            XCTAssertEqual(anim.num_tracks(), 1)
        }
    }

    func testName() {

    }

    func testSort() {

    }
}
