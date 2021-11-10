//
//  blending_job_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/10.
//

import XCTest
@testable import vox_oasis

class BlendingJobTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJobValidity() {
        let identity = SoaTransform.identity()
        let zero = simd_float4.zero()
        var layers = [BlendingJob.Layer(), BlendingJob.Layer()]
        let bind_poses = [identity, identity, identity]
        let input_transforms = [identity, identity, identity]
        var output_transforms = [identity, identity, identity]
        let joint_weights = [zero, zero, zero]

        layers[0].transform = input_transforms[...]
        layers[1].transform = input_transforms[0..<2]

        do {  // Empty/default job.
            let job = BlendingJob()
            XCTAssertFalse(job.validate())
        }

        do {  // Invalid output.
            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
        }
        do {  // Layers are optional.
            let job = BlendingJob()
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<2]))
        }
        do {  // Invalid bind pose.
            let job = BlendingJob()
            job.layers = layers[0..<2]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<2]))
        }
        do {  // Invalid layer input range, too small.
            var invalid_layers = [BlendingJob.Layer(), BlendingJob.Layer()]
            invalid_layers[0].transform = input_transforms[0..<1]
            invalid_layers[1].transform = input_transforms[0..<2]

            let job = BlendingJob()
            job.layers = invalid_layers[...]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<2]))
        }
        do {  // Invalid output range, smaller output.
            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(sjob.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<1]))
        }

        do {  // Invalid smaller input.
            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<3]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<3]))
        }

        do {  // Invalid threshold.
            let job = BlendingJob()
            job.threshold = 0.0
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<2]))
        }

        do {  // Invalid joint weights range.
            layers[0].joint_weights = joint_weights[0..<1]

            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<2]))
        }

        do {  // Valid job.
            layers[0].joint_weights = ArraySlice()

            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<2]))
        }

        do {  // Valid joint weights range.
            layers[0].joint_weights = joint_weights[0..<2]

            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<2]))
        }

        do {  // Valid job, bigger output.
            layers[0].joint_weights = joint_weights[0..<2]

            let job = BlendingJob()
            job.layers = layers[0..<2]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<3]))
        }

        do {  // Valid no layers.
            let job = BlendingJob()
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<2]))
        }
    }

    func testJobValidityAdditive() {
        let identity = SoaTransform.identity()
        let zero = simd_float4.zero()
        var layers = [BlendingJob.Layer(), BlendingJob.Layer()]
        var additive_layers = [BlendingJob.Layer(), BlendingJob.Layer()]

        let bind_poses = [identity, identity, identity]
        let input_transforms = [identity, identity, identity]
        var output_transforms = [identity, identity, identity]
        let joint_weights = [zero, zero, zero]

        layers[0].transform = input_transforms[...]
        layers[1].transform = input_transforms[...]

        additive_layers[0].transform = input_transforms[...]
        additive_layers[1].transform = input_transforms[...]

        do {  // Valid additive job, no normal blending.
            let job = BlendingJob()
            job.additive_layers = additive_layers[...]
            job.bind_pose = bind_poses[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[...]))
        }

        do {  // Valid additive job, with normal blending also.
            let job = BlendingJob()
            job.layers = layers[...]
            job.additive_layers = additive_layers[...]
            job.bind_pose = bind_poses[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[...]))
        }

        do {  // Invalid layer input range, too small.
            var invalid_layers = [BlendingJob.Layer(), BlendingJob.Layer()]
            invalid_layers[0].transform = input_transforms[0..<1]
            invalid_layers[1].transform = input_transforms[0..<2]

            let job = BlendingJob()
            job.layers = layers[...]
            job.additive_layers = invalid_layers[...]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output_transforms[0..<2]))
        }

        do {  // Valid additive job, with per-joint weights.
            layers[0].joint_weights = joint_weights[0..<2]

            let job = BlendingJob()
            job.additive_layers = additive_layers[...]
            job.bind_pose = bind_poses[0..<2]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output_transforms[0..<2]))
        }
    }

    func testEmpty() {
        let identity = SoaTransform.identity()

        // Initialize bind pose.
        var bind_poses = [identity, identity]
        bind_poses[0].translation = SoaFloat3.load(
                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0))
        bind_poses[0].scale = SoaFloat3.load(
                simd_float4.load(0.0, 10.0, 20.0, 30.0),
                simd_float4.load(40.0, 50.0, 60.0, 70.0),
                simd_float4.load(80.0, 90.0, 100.0, 110.0))
        bind_poses[1].translation = bind_poses[0].translation * simd_float4.load(2.0, 2.0, 2.0, 2.0)
        bind_poses[1].scale = bind_poses[0].scale * simd_float4.load(2.0, 2.0, 2.0, 2.0)

        let job = BlendingJob()
        job.bind_pose = bind_poses[...]
        var output_transforms = [SoaTransform.identity(), SoaTransform.identity()]

        XCTAssertTrue(job.validate())
        XCTAssertTrue(job.run(&output_transforms[...]))

        EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, 0.0, 1.0, 2.0, 3.0, 4.0,
                5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0)
        EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 0.0, 10.0, 20.0, 30.0, 40.0,
                50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0)
        EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, 0.0, 2.0, 4.0, 6.0, 8.0,
                10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0)
        EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 0.0, 20.0, 40.0, 60.0, 80.0,
                100.0, 120.0, 140.0, 160.0, 180.0, 200.0, 220.0)
    }

    func testWeight() {
        let identity = SoaTransform.identity()

        // Initialize inputs.
        var input_transforms = [[identity, identity], [identity, identity]]
        input_transforms[0][0].translation = SoaFloat3.load(
                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0))
        input_transforms[0][1].translation = SoaFloat3.load(
                simd_float4.load(12.0, 13.0, 14.0, 15.0),
                simd_float4.load(16.0, 17.0, 18.0, 19.0),
                simd_float4.load(20.0, 21.0, 22.0, 23.0))
        input_transforms[1][0].translation = -input_transforms[0][0].translation
        input_transforms[1][1].translation = -input_transforms[0][1].translation

        // Initialize bind pose.
        var bind_poses = [identity, identity]
        bind_poses[0].scale = SoaFloat3.load(
                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0))
        bind_poses[1].scale =
                bind_poses[0].scale * simd_float4.load(2.0, 2.0, 2.0, 2.0)

        do {
            var layers = [BlendingJob.Layer(), BlendingJob.Layer()]
            layers[0].transform = input_transforms[0][...]
            layers[1].transform = input_transforms[1][...]

            var output_transforms = [SoaTransform.identity(), SoaTransform.identity()]

            let job = BlendingJob()
            job.layers = layers[...]
            job.bind_pose = bind_poses[...]

            // Weight 0 (a bit less must give the same result) for the first layer,
            // 1 for the second.
            layers[0].weight = -0.07
            layers[1].weight = 1.0

            XCTAssertTrue(job.run(&output_transforms[...]))

            EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, -0.0, -1.0, -2.0,
                    -3.0, -4.0, -5.0, -6.0, -7.0, -8.0, -9.0, -10.0, -11.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, -12.0, -13.0, -14.0,
                    -15.0, -16.0, -17.0, -18.0, -19.0, -20.0, -21.0, -22.0,
                    -23.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)

            // Weight 1 for the first layer, 0 for the second.
            layers[0].weight = 1.0
            layers[1].weight = 1e-27  // Very low weight value.

            XCTAssertTrue(job.run(&output_transforms[...]))

            EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, 0.0, 1.0, 2.0, 3.0,
                    4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, 12.0, 13.0, 14.0,
                    15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)

            // Weight .5 for both layers.
            layers[0].weight = 0.5
            layers[1].weight = 0.5

            XCTAssertTrue(job.run(&output_transforms[...]))

            EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, 0.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        }
    }

    func testJointWeights() {
        let identity = SoaTransform.identity()

        // Initialize inputs.
        var input_transforms = [[identity, identity], [identity, identity]]
        input_transforms[0][0].translation = SoaFloat3.load(
                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0))
        input_transforms[0][1].translation = SoaFloat3.load(
                simd_float4.load(12.0, 13.0, 14.0, 15.0),
                simd_float4.load(16.0, 17.0, 18.0, 19.0),
                simd_float4.load(20.0, 21.0, 22.0, 23.0))
        input_transforms[1][0].translation = -input_transforms[0][0].translation
        input_transforms[1][1].translation = -input_transforms[0][1].translation
        let joint_weights = [
            [simd_float4.load(1.0, 1.0, 0.0, 0.0),
             simd_float4.load(1.0, 0.0, 1.0, 1.0)],
            [simd_float4.load(1.0, 1.0, 1.0, 0.0),
             simd_float4.load(0.0, 1.0, 1.0, 1.0)]]
        // Initialize bind pose.
        var bind_poses = [identity, identity]
        bind_poses[0].translation = SoaFloat3.load(
                simd_float4.load(10.0, 11.0, 12.0, 13.0),
                simd_float4.load(14.0, 15.0, 16.0, 17.0),
                simd_float4.load(18.0, 19.0, 20.0, 21.0))
        bind_poses[0].scale = SoaFloat3.load(
                simd_float4.load(0.0, 1.0, 2.0, 3.0),
                simd_float4.load(4.0, 5.0, 6.0, 7.0),
                simd_float4.load(8.0, 9.0, 10.0, 11.0))
        bind_poses[1].scale = bind_poses[0].scale * simd_float4.load(2.0, 2.0, 2.0, 2.0)

        var layers = [BlendingJob.Layer(), BlendingJob.Layer()]
        layers[0].transform = input_transforms[0][...]
        layers[0].joint_weights = joint_weights[0][...]
        layers[1].transform = input_transforms[1][...]
        layers[1].joint_weights = joint_weights[1][...]

        do {  // Weight .5 for both layers.
            var output_transforms = [SoaTransform.identity(), SoaTransform.identity(), SoaTransform.identity()]

            let job = BlendingJob()
            job.layers = layers[...]
            job.bind_pose = bind_poses[...]

            layers[0].weight = 0.5
            layers[1].weight = 0.5

            XCTAssertTrue(job.run(&output_transforms[...]))

            EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, 0.0, 0.0, -2.0, 13.0,
                    0.0, 0.0, -6.0, 17.0, 0.0, 0.0, -10.0, 21.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 1.0, 1.0, 1.0, 3.0, 1.0,
                    1.0, 1.0, 7.0, 1.0, 1.0, 1.0, 11.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, 12.0, -13.0, 0.0, 0.0,
                    16.0, -17.0, 0.0, 0.0, 20.0, -21.0, 0.0, 0.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 1.0, 1.0, 1.0, 1.0, 1.0,
                    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        }
        do {  // Null weight for the first layer.
            var output_transforms = [SoaTransform.identity(), SoaTransform.identity()]

            let job = BlendingJob()
            job.layers = layers[...]
            job.bind_pose = bind_poses[...]

            layers[0].weight = 0.0
            layers[1].weight = 1.0

            XCTAssertTrue(job.run(&output_transforms[...]))

            EXPECT_SOAFLOAT3_EQ(output_transforms[0].translation, -0.0, -1.0, -2.0,
                    13.0, -4.0, -5.0, -6.0, 17.0, -8.0, -9.0, -10.0, 21.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[0].scale, 1.0, 1.0, 1.0, 3.0, 1.0,
                    1.0, 1.0, 7.0, 1.0, 1.0, 1.0, 11.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].translation, 0.0, -13.0, -14.0,
                    -15.0, 0.0, -17.0, -18.0, -19.0, 0.0, -21.0, -22.0, -23.0)
            EXPECT_SOAFLOAT3_EQ(output_transforms[1].scale, 0.0, 1.0, 1.0, 1.0, 8.0,
                    1.0, 1.0, 1.0, 16.0, 1.0, 1.0, 1.0)
        }

    }

    func testNormalize() {

    }

    func testThreshold() {

    }

    func testAdditiveWeight() {

    }

    func testAdditiveJointWeight() {

    }
}
