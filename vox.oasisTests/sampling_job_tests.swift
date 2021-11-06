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

    }

    func testSampling1Track0Key() {

    }

    func testSampling1Track1Key() {

    }

    func testSampling1Track2Keys() {

    }

    func testSampling4Track2Keys() {

    }

    func testCache() {

    }

    func testCacheResize() {

    }
}
