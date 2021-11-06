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
            var output:[SoaTransform] = []
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
}
