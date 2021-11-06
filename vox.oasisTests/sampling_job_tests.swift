//
//  sampling_job_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class SamplingJobTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJobValidity() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 1.0
        raw_animation.tracks = [RawAnimation.JointTrack()]

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        // Allocates cache.
        let cache = SamplingCache(1)

        do {  // Empty/default job
            let job = SamplingJob()
            XCTAssertFalse(job.validate())
        }

        do {  // Invalid output
            let job = SamplingJob()
            job.animation = animation
            job.cache = cache
            XCTAssertTrue(job.validate())
        }

        do {  // Invalid animation.
            var output = [SoaTransform.identity()]

            let job = SamplingJob()
            job.cache = cache
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }

        do {  // Invalid cache.
            var output = [SoaTransform.identity()]

            let job = SamplingJob()
            job.animation = animation
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }

        do {  // Invalid cache size.
            let zero_cache = SamplingCache(0)
            var output = [SoaTransform.identity()]

            let job = SamplingJob()
            job.animation = animation
            job.cache = zero_cache
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }

        do {  // Invalid job with smaller output.
            var output: [SoaTransform] = []
            let job = SamplingJob()
            job.ratio = 2155.0  // Any time ratio can be set, it's clamped in unit interval.
            job.animation = animation
            job.cache = cache
            XCTAssertTrue(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }

        do {  // Valid job.
            var output = [SoaTransform.identity()]
            let job = SamplingJob()
            job.ratio = 2155.0  // Any time can be set.
            job.animation = animation
            job.cache = cache
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
        }

        do {  // Valid job with bigger cache.
            let big_cache = SamplingCache(2)
            var output = [SoaTransform.identity()]
            let job = SamplingJob()
            job.ratio = 2155.0  // Any time can be set.
            job.animation = animation
            job.cache = big_cache
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
        }

        do {  // Valid job with bigger output.
            var output = [SoaTransform.identity(), SoaTransform.identity()]
            let job = SamplingJob()
            job.ratio = 2155.0  // Any time can be set.
            job.animation = animation
            job.cache = cache
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
        }

        do {  // Default animation.
            var output = [SoaTransform.identity()]
            let default_animation = SoaAnimation()
            let job = SamplingJob()
            job.animation = default_animation
            job.cache = cache
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
        }
    }

    func testSampling() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        // Building an Animation with unsorted keys fails.
        var raw_animation = RawAnimation()
        raw_animation.duration = 1.0
        raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 4)

        let cache = SamplingCache(4)

        // Raw animation inputs.
        //     0                 1
        // -----------------------
        // 0 - |  A              |
        // 1 - |                 |
        // 2 - B  C   D   E      F
        // 3 - |  G       H      |

        // Final animation.
        //     0                 1
        // -----------------------
        // 0 - A-1               4
        // 1 - 1                 5
        // 2 - B2 C6  D8 E10    F11
        // 3 - 3  G7     H9      12

        struct Result {
            var sample_time: Float
            var trans: [Float]
        }

        let result: [Result] = [
            Result(sample_time: -0.2, trans: [-1.0, 0.0, 2.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.0, trans: [-1.0, 0.0, 2.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.0000001, trans: [-1.0, 0.0, 2.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.1, trans: [-1.0, 0.0, 4.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.2, trans: [-1.0, 0.0, 6.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.3, trans: [-1.0, 0.0, 7.0, 7.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.4, trans: [-1.0, 0.0, 8.0, 8.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.3999999, trans: [-1.0, 0.0, 8.0, 8.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.4000001, trans: [-1.0, 0.0, 8.0, 8.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.5, trans: [-1.0, 0.0, 9.0, 8.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.6, trans: [-1.0, 0.0, 10.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.9999999, trans: [-1.0, 0.0, 11.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 1.0, trans: [-1.0, 0.0, 11.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 1.000001, trans: [-1.0, 0.0, 11.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.5, trans: [-1.0, 0.0, 9.0, 8.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.9999999, trans: [-1.0, 0.0, 11.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
            Result(sample_time: 0.0000001, trans: [-1.0, 0.0, 2.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        ]

        let a = RawAnimation.TranslationKey(0.2, VecFloat3(-1.0, 0.0, 0.0))
        raw_animation.tracks[0].translations.append(a)

        let b = RawAnimation.TranslationKey(0.0, VecFloat3(2.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(b)
        let c = RawAnimation.TranslationKey(0.2, VecFloat3(6.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(c)
        let d = RawAnimation.TranslationKey(0.4, VecFloat3(8.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(d)
        let e = RawAnimation.TranslationKey(0.6, VecFloat3(10.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(e)
        let f = RawAnimation.TranslationKey(1.0, VecFloat3(11.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(f)

        let g = RawAnimation.TranslationKey(0.2, VecFloat3(7.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(g)
        let h = RawAnimation.TranslationKey(0.6, VecFloat3(9.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(h)

        // Builds animation
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache

        for i in 0..<result.count {
            output[0] = SoaTransform.identity()
            job.ratio = result[i].sample_time / animation.duration()
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_SOAFLOAT3_EQ_EST(
                    output[0].translation, result[i].trans[0], result[i].trans[1],
                    result[i].trans[2], result[i].trans[3], result[i].trans[4],
                    result[i].trans[5], result[i].trans[6], result[i].trans[7],
                    result[i].trans[8], result[i].trans[9], result[i].trans[10],
                    result[i].trans[11])
            EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0)
        }
    }

    func testSamplingNoTrack() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0

        let cache = SamplingCache(1)

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        let test_output = [SoaTransform.identity()]
        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.ratio = 0.0
        job.animation = animation
        job.cache = cache
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))

        // Tests output.
        XCTAssertEqual(test_output[0].translation.x, output[0].translation.x)
        XCTAssertEqual(test_output[0].translation.y, output[0].translation.y)
        XCTAssertEqual(test_output[0].translation.z, output[0].translation.z)

        XCTAssertEqual(test_output[0].rotation.x, output[0].rotation.x)
        XCTAssertEqual(test_output[0].rotation.y, output[0].rotation.y)
        XCTAssertEqual(test_output[0].rotation.z, output[0].rotation.z)
        XCTAssertEqual(test_output[0].rotation.w, output[0].rotation.w)

        XCTAssertEqual(test_output[0].scale.x, output[0].scale.x)
        XCTAssertEqual(test_output[0].scale.y, output[0].scale.y)
        XCTAssertEqual(test_output[0].scale.z, output[0].scale.z)
    }

    func testSampling1Track0Key() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0
        raw_animation.tracks = [RawAnimation.JointTrack()]  // Adds a joint.

        let cache = SamplingCache(1)

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache

        var t: Float = -0.2
        while t < 1.2 {
            output[0] = .identity()
            job.ratio = t
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0)

            t += 0.1
        }
    }

    func testSampling1Track1Key() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0
        raw_animation.tracks = [RawAnimation.JointTrack()]  // Adds a joint.

        let cache = SamplingCache(1)

        let tkey = RawAnimation.TranslationKey(0.3, VecFloat3(1.0, -1.0, 5.0))
        raw_animation.tracks[0].translations.append(tkey)  // Adds a key.

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache

        var t: Float = -0.2
        while t < 1.2 {
            output[0] = .identity()
            job.ratio = t
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, -1.0,
                    0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0)
            EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0)

            t += 0.1
        }
    }

    func testSampling1Track2Keys() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0
        raw_animation.tracks = [RawAnimation.JointTrack()]  // Adds a joint.

        let cache = SamplingCache(1)

        let tkey0 = RawAnimation.TranslationKey(0.5, VecFloat3(1.0, 2.0, 4.0))
        raw_animation.tracks[0].translations.append(tkey0)  // Adds a key.
        let tkey1 = RawAnimation.TranslationKey(0.8, VecFloat3(2.0, 4.0, 8.0))
        raw_animation.tracks[0].translations.append(tkey1)  // Adds a key.

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache

        // Samples at t = 0.
        job.ratio = 0.0
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, 2.0, 0.0,
                0.0, 0.0, 4.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Samples at t = tkey0.
        job.ratio = tkey0.time / animation.duration()
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, 2.0, 0.0,
                0.0, 0.0, 4.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Samples at t = tkey1.
        job.ratio = tkey1.time / animation.duration()
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 2.0, 0.0, 0.0, 0.0, 4.0, 0.0,
                0.0, 0.0, 8.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Samples at t = end.
        job.ratio = 1.0
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 2.0, 0.0, 0.0, 0.0, 4.0, 0.0,
                0.0, 0.0, 8.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Samples at tkey0.time < t < tkey1.time.
        job.ratio = (tkey0.time / animation.duration() + tkey1.time / animation.duration()) / 2.0
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.5, 0.0, 0.0, 0.0, 3.0, 0.0,
                0.0, 0.0, 6.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

    }

    func testSampling4Track2Keys() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 1.0
        raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 4)  // Adds a joint.

        let cache = SamplingCache(1)

        let tkey00 = RawAnimation.TranslationKey(0.5, VecFloat3(1.0, 2.0, 4.0))
        raw_animation.tracks[0].translations.append(tkey00)  // Adds a key.
        let tkey01 = RawAnimation.TranslationKey(0.8, VecFloat3(2.0, 4.0, 8.0))
        raw_animation.tracks[0].translations.append(tkey01)  // Adds a key.

        // This quaternion will be negated as the builder ensures that the first key
        // is in identity quaternion hemisphere.
        let rkey10 = RawAnimation.RotationKey(0.0, VecQuaternion(0.0, 0.0, 0.0, -1.0))
        raw_animation.tracks[1].rotations.append(rkey10)  // Adds a key.
        let rkey11 = RawAnimation.RotationKey(1.0, VecQuaternion(0.0, 1.0, 0.0, 0.0))
        raw_animation.tracks[1].rotations.append(rkey11)  // Adds a key.

        let skey20 = RawAnimation.ScaleKey(0.5, VecFloat3(0.0, 0.0, 0.0))
        raw_animation.tracks[2].scales.append(skey20)  // Adds a key.
        let skey21 = RawAnimation.ScaleKey(0.8, VecFloat3(-1.0, -1.0, -1.0))
        raw_animation.tracks[2].scales.append(skey21)  // Adds a key.

        let tkey30 = RawAnimation.TranslationKey(0.0, VecFloat3(-1.0, -2.0, -4.0))
        raw_animation.tracks[3].translations.append(tkey30)  // Adds a key.
        let tkey31 = RawAnimation.TranslationKey(1.0, VecFloat3(-2.0, -4.0, -8.0))
        raw_animation.tracks[3].translations.append(tkey31)  // Adds a key.

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache

        // Samples at t = 0.
        job.ratio = 0.0
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, -1.0, 2.0, 0.0,
                0.0, -2.0, 4.0, 0.0, 0.0, -4.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0,
                1.0, 1.0, 1.0, 0.0, 1.0)

        // Samples at t = tkey00.
        job.ratio = tkey00.time / animation.duration()
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, -1.5, 2.0, 0.0,
                0.0, -3.0, 4.0, 0.0, 0.0, -6.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.7071067, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
                0.7071067, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0,
                1.0, 1.0, 1.0, 0.0, 1.0)

        // Samples at t = end.
        job.ratio = 1.0
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 2.0, 0.0, 0.0, -2.0, 4.0, 0.0,
                0.0, -4.0, 8.0, 0.0, 0.0, -8.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, -1.0,
                1.0, 1.0, 1.0, -1.0, 1.0)
    }

    func testCache() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0
        raw_animation.tracks = [RawAnimation.JointTrack()]  // Adds a joint.
        let empty_key = RawAnimation.TranslationKey(0.0, RawAnimation.TranslationKey.identity())
        raw_animation.tracks[0].translations.append(empty_key)

        let cache = SamplingCache(1)
        var animations: [SoaAnimation?] = [nil, nil]

        do {
            let tkey = RawAnimation.TranslationKey(0.3, VecFloat3(1.0, -1.0, 5.0))
            raw_animation.tracks[0].translations[0] = tkey

            let builder = AnimationBuilder()
            animations[0] = builder.eval(raw_animation)
            XCTAssertTrue(animations[0] != nil)
        }
        do {
            let tkey = RawAnimation.TranslationKey(0.3, VecFloat3(-1.0, 1.0, -5.0))
            raw_animation.tracks[0].translations[0] = tkey

            let builder = AnimationBuilder()
            animations[1] = builder.eval(raw_animation)
            XCTAssertTrue(animations[1] != nil)
        }

        var output = [SoaTransform.identity()]

        let job = SamplingJob()
        job.animation = animations[0]
        job.cache = cache
        job.ratio = 0.0

        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, -1.0, 0.0,
                0.0, 0.0, 5.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Re-uses cache.
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, -1.0, 0.0,
                0.0, 0.0, 5.0, 0.0, 0.0, 0.0)

        // Invalidates cache.
        cache.invalidate()

        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 0.0, 0.0, 0.0, -1.0, 0.0,
                0.0, 0.0, 5.0, 0.0, 0.0, 0.0)

        // Changes animation.
        job.animation = animations[1]
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, -1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, -5.0, 0.0, 0.0, 0.0)
        EXPECT_SOAQUATERNION_EQ_EST(output[0].rotation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        EXPECT_SOAFLOAT3_EQ_EST(output[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0)

        // Invalidates and changes animation.
        job.animation = animations[1]
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))
        EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, -1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, -5.0, 0.0, 0.0, 0.0)
    }

    func testCacheResize() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 46.0
        raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 7)

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        // Empty cache by default
        let cache = SamplingCache()

        var output = [SoaTransform](repeating: SoaTransform.identity(), count: 7)

        let job = SamplingJob()
        job.animation = animation
        job.cache = cache
        job.ratio = 0.0

        // Cache is too small
        XCTAssertFalse(job.validate())

        // Cache is ok.
        cache.resize(7)
        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output[...]))

        // Cache is too small
        cache.resize(1)
        XCTAssertFalse(job.validate())
    }
}
