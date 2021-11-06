//
//  raw_animation_utils_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class RawAnimationUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSamplingTrackEmpty() {
        let track = RawAnimation.JointTrack()
        var output = VecTransform.identity()

        XCTAssertTrue(sampleTrack(track, 0.0, &output))

        EXPECT_FLOAT3_EQ(output.translation, 0.0, 0.0, 0.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(output.scale, 1.0, 1.0, 1.0)
    }

    func testSamplingTrackInvalid() {
        // Key order
        do {
            var track = RawAnimation.JointTrack()

            let t0 = RawAnimation.TranslationKey(0.9, VecFloat3(1.0, 2.0, 4.0))
            track.translations.append(t0)
            let t1 = RawAnimation.TranslationKey(0.1, VecFloat3(2.0, 4.0, 8.0))
            track.translations.append(t1)

            var output = VecTransform.identity()
            XCTAssertFalse(sampleTrack(track, 0.0, &output))
        }

        // Negative time
        do {
            var track = RawAnimation.JointTrack()

            let t0 = RawAnimation.TranslationKey(-1.0, VecFloat3(1.0, 2.0, 4.0))
            track.translations.append(t0)

            var output = VecTransform.identity()
            XCTAssertFalse(sampleTrack(track, 0.0, &output))
        }
    }

    func testSamplingTrack() {
        var track = RawAnimation.JointTrack()

        let t0 = RawAnimation.TranslationKey(0.1, VecFloat3(1.0, 2.0, 4.0))
        track.translations.append(t0)
        let t1 = RawAnimation.TranslationKey(0.9, VecFloat3(2.0, 4.0, 8.0))
        track.translations.append(t1)

        let r0 = RawAnimation.RotationKey(0.0, VecQuaternion(0.70710677, 0.0, 0.0, 0.70710677))
        track.rotations.append(r0)
        // /!\ Negated (other hemisphepre) quaternion
        let r1 = RawAnimation.RotationKey(0.5, -VecQuaternion(0.0, 0.70710677, 0.0, 0.70710677))
        track.rotations.append(r1)
        let r2 = RawAnimation.RotationKey(1.0, VecQuaternion(0.0, 0.70710677, 0.0, 0.70710677))
        track.rotations.append(r2)

        let s0 = RawAnimation.ScaleKey(0.5, VecFloat3(-1.0, -2.0, -4.0))
        track.scales.append(s0)

        var output = VecTransform.identity()

        // t = -.1
        XCTAssertTrue(sampleTrack(track, -0.1, &output))
        EXPECT_FLOAT3_EQ(output.translation, 1.0, 2.0, 4.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.70710677, 0.0, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t = 0
        XCTAssertTrue(sampleTrack(track, 0.0, &output))
        EXPECT_FLOAT3_EQ(output.translation, 1.0, 2.0, 4.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.70710677, 0.0, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t = .1
        XCTAssertTrue(sampleTrack(track, 0.1, &output))
        EXPECT_FLOAT3_EQ(output.translation, 1.0, 2.0, 4.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.6172133, 0.1543033, 0.0, 0.7715167)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t = .4999999
        XCTAssertTrue(sampleTrack(track, 0.4999999, &output))
        EXPECT_FLOAT3_EQ(output.translation, 1.5, 3.0, 6.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t = .5
        XCTAssertTrue(sampleTrack(track, 0.5, &output))
        EXPECT_FLOAT3_EQ(output.translation, 1.5, 3.0, 6.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t = .75
        XCTAssertTrue(sampleTrack(track, 0.75, &output))
        // Fixed up based on dot with previous quaternion
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, -0.70710677, 0.0, -0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t= .9
        XCTAssertTrue(sampleTrack(track, 0.9, &output))
        EXPECT_FLOAT3_EQ(output.translation, 2.0, 4.0, 8.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, -0.70710677, 0.0, -0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t= 1.
        XCTAssertTrue(sampleTrack(track, 1.0, &output))
        EXPECT_FLOAT3_EQ(output.translation, 2.0, 4.0, 8.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)

        // t= 1.1
        XCTAssertTrue(sampleTrack(track, 1.1, &output))
        EXPECT_FLOAT3_EQ(output.translation, 2.0, 4.0, 8.0)
        EXPECT_QUATERNION_EQ(output.rotation, 0.0, 0.70710677, 0.0, 0.70710677)
        EXPECT_FLOAT3_EQ(output.scale, -1.0, -2.0, -4.0)
    }

    func testSamplingAnimation() {
        // Building an Animation with unsorted keys fails.
        var raw_animation = RawAnimation()
        raw_animation.duration = 2.0
        raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

        let a = RawAnimation.TranslationKey(0.2, VecFloat3(-1.0, 0.0, 0.0))
        raw_animation.tracks[0].translations.append(a)

        let b = RawAnimation.TranslationKey(0.0, VecFloat3(2.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(b)
        let c = RawAnimation.TranslationKey(0.2, VecFloat3(6.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(c)
        let d = RawAnimation.TranslationKey(0.4, VecFloat3(8.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(d)

        var output = [VecTransform.identity(), VecTransform.identity()]

        // Too small
        do {
            var small = [VecTransform.identity()]
            XCTAssertFalse(sampleAnimation(raw_animation, 0.0, &small[...]))
        }

        // Invalid, cos track are longer than duration
        do {
            raw_animation.duration = 0.1
            XCTAssertFalse(sampleAnimation(raw_animation, 0.0, &output[...]))
            raw_animation.duration = 2.0
        }

        XCTAssertTrue(sampleAnimation(raw_animation, -0.1, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_QUATERNION_EQ(output[0].rotation, 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(output[0].scale, 1.0, 1.0, 1.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 2.0, 0.0, 0.0)
        EXPECT_QUATERNION_EQ(output[1].rotation, 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(output[1].scale, 1.0, 1.0, 1.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 0.0, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 2.0, 0.0, 0.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 0.2, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 6.0, 0.0, 0.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 0.3, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 7.0, 0.0, 0.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 0.4, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 8.0, 0.0, 0.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 2.0, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 8.0, 0.0, 0.0)

        XCTAssertTrue(sampleAnimation(raw_animation, 3.0, &output[...]))
        EXPECT_FLOAT3_EQ(output[0].translation, -1.0, 0.0, 0.0)
        EXPECT_FLOAT3_EQ(output[1].translation, 8.0, 0.0, 0.0)
    }

    func testFixedRateSamplingTime() {
        do {  // From 0
            let it = FixedRateSamplingTime(1.0, 30.0)
            XCTAssertEqual(it.num_keys(), 31)

            XCTAssertEqual(it.time(0), 0.0)
            XCTAssertEqual(it.time(1), 1.0 / 30.0)
            XCTAssertEqual(it.time(2), 2.0 / 30.0)
            XCTAssertEqual(it.time(29), 29.0 / 30.0, accuracy: 1.0e-5)
            XCTAssertEqual(it.time(30), 1.0)
        }

        do {  // Offset
            let it = FixedRateSamplingTime(3.0, 100.0)
            XCTAssertEqual(it.num_keys(), 301)

            XCTAssertEqual(it.time(0), 0.0)
            XCTAssertEqual(it.time(1), 1.0 / 100.0)
            XCTAssertEqual(it.time(2), 2.0 / 100.0)
            XCTAssertEqual(it.time(299), 299.0 / 100.0)
            XCTAssertEqual(it.time(300), 3.0)
        }

        do {  // Ceil
            let it = FixedRateSamplingTime(1.001, 30.0)
            XCTAssertEqual(it.num_keys(), 32)

            XCTAssertEqual(it.time(0), 0.0)
            XCTAssertEqual(it.time(1), 1.0 / 30.0)
            XCTAssertEqual(it.time(2), 2.0 / 30.0)
            XCTAssertEqual(it.time(29), 29.0 / 30.0, accuracy: 1.0e-5)
            XCTAssertEqual(it.time(30), 1.0)
            XCTAssertEqual(it.time(31), 1.001)
        }

        do {  // Long
            let it = FixedRateSamplingTime(1000.0, 30.0)
            XCTAssertEqual(it.num_keys(), 30001)

            XCTAssertEqual(it.time(0), 0.0)
            XCTAssertEqual(it.time(1), 1.0 / 30.0)
            XCTAssertEqual(it.time(2), 2.0 / 30.0)
            XCTAssertEqual(it.time(29999), 29999.0 / 30.0, accuracy: 1.0e-4)
            XCTAssertEqual(it.time(30000), 1000.0)
        }
    }
}
