//
//  additive_animation_builder_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AdditiveAnimationBuilderTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        let builder = AdditiveAnimationBuilder()

        do {  // nullptr output.
            let input = RawAnimation()
            XCTAssertTrue(input.validate())
        }

        do {  // Invalid input animation.
            var input = RawAnimation()
            input.duration = -1.0
            XCTAssertFalse(input.validate())

            // Builds animation
            var output = RawAnimation()
            output.duration = -1.0
            output.tracks = [RawAnimation.JointTrack()]
            XCTAssertFalse(builder.eval(input, &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }

        do {  // Invalid input animation with custom refpose
            var input = RawAnimation()
            input.duration = 1.0
            input.tracks = [RawAnimation.JointTrack()]

            // Builds animation
            var output = RawAnimation()
            output.duration = -1.0
            output.tracks = [RawAnimation.JointTrack()]

            let empty_ref_pose_range: [VecTransform] = []

            XCTAssertFalse(builder.eval(input, empty_ref_pose_range[...], &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }
    }

    func testBuild() {
        let builder = AdditiveAnimationBuilder()

        var input = RawAnimation()
        input.duration = 1.0
        input.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack(), RawAnimation.JointTrack()]

        // First track is empty
        do {
            // input.tracks[0]
        }

        // 2nd track
        // 1 key at the beginning
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(2.0, 3.0, 4.0))
            input.tracks[1].translations.append(key)
        }
        do {
            let key = RawAnimation.RotationKey(0.0, VecQuaternion(0.70710677, 0.0, 0.0, 0.70710677))
            input.tracks[1].rotations.append(key)
        }
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(5.0, 6.0, 7.0))
            input.tracks[1].scales.append(key)
        }

        // 3rd track
        // 2 keys after the beginning
        do {
            let key0 = RawAnimation.TranslationKey(0.5, VecFloat3(2.0, 3.0, 4.0))
            input.tracks[2].translations.append(key0)
            let key1 = RawAnimation.TranslationKey(0.7, VecFloat3(20.0, 30.0, 40.0))
            input.tracks[2].translations.append(key1)
        }
        do {
            let key0 = RawAnimation.RotationKey(0.5, VecQuaternion(0.70710677, 0.0, 0.0, 0.70710677))
            input.tracks[2].rotations.append(key0)
            let key1 = RawAnimation.RotationKey(0.7, VecQuaternion(-0.70710677, 0.0, 0.0, 0.70710677))
            input.tracks[2].rotations.append(key1)
        }
        do {
            let key0 = RawAnimation.ScaleKey(0.5, VecFloat3(5.0, 6.0, 7.0))
            input.tracks[2].scales.append(key0)
            let key1 = RawAnimation.ScaleKey(0.7, VecFloat3(50.0, 60.0, 70.0))
            input.tracks[2].scales.append(key1)
        }

        // Builds animation with very little tolerance.
        do {
            var output = RawAnimation()
            XCTAssertTrue(builder.eval(input, &output))
            XCTAssertEqual(output.num_tracks(), 3)

            // 1st track.
            do {
                XCTAssertEqual(output.tracks[0].translations.count, 0)
                XCTAssertEqual(output.tracks[0].rotations.count, 0)
                XCTAssertEqual(output.tracks[0].scales.count, 0)
            }

            // 2nd track.
            do {
                let translations = output.tracks[1].translations
                XCTAssertEqual(translations.count, 1)
                XCTAssertEqual(translations[0].time, 0.0)
                EXPECT_FLOAT3_EQ(translations[0].value, 0.0, 0.0, 0.0)
                let rotations = output.tracks[1].rotations
                XCTAssertEqual(rotations.count, 1)
                XCTAssertEqual(rotations[0].time, 0.0)
                EXPECT_QUATERNION_EQ(rotations[0].value, 0.0, 0.0, 0.0, 1.0)
                let scales = output.tracks[1].scales
                XCTAssertEqual(scales.count, 1)
                XCTAssertEqual(scales[0].time, 0.0)
                EXPECT_FLOAT3_EQ(scales[0].value, 1.0, 1.0, 1.0)
            }

            // 3rd track.
            do {
                let translations = output.tracks[2].translations
                XCTAssertEqual(translations.count, 2)
                XCTAssertEqual(translations[0].time, 0.5)
                EXPECT_FLOAT3_EQ(translations[0].value, 0.0, 0.0, 0.0)
                XCTAssertEqual(translations[1].time, 0.7)
                EXPECT_FLOAT3_EQ(translations[1].value, 18.0, 27.0, 36.0)
                let rotations = output.tracks[2].rotations
                XCTAssertEqual(rotations.count, 2)
                XCTAssertEqual(rotations[0].time, 0.5)
                EXPECT_QUATERNION_EQ(rotations[0].value, 0.0, 0.0, 0.0, 1.0)
                XCTAssertEqual(rotations[1].time, 0.7)
                EXPECT_QUATERNION_EQ(rotations[1].value, -1.0, 0.0, 0.0, 0.0)
                let scales = output.tracks[2].scales
                XCTAssertEqual(scales.count, 2)
                XCTAssertEqual(scales[0].time, 0.5)
                EXPECT_FLOAT3_EQ(scales[0].value, 1.0, 1.0, 1.0)
                XCTAssertEqual(scales[1].time, 0.7)
                EXPECT_FLOAT3_EQ(scales[1].value, 10.0, 10.0, 10.0)
            }
        }
    }
}
