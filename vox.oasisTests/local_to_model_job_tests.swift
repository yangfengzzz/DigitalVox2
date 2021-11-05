//
//  local_to_model_job_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/5.
//

import XCTest
@testable import vox_oasis

class LocalToModelTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJobValidity() {
        var raw_skeleton = RawSkeleton()
        let builder = SkeletonBuilder()

        // Empty skeleton.
        let empty_skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(empty_skeleton != nil)
        guard let empty_skeleton = empty_skeleton else {
            return
        }

        // Adds 2 joints.
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "root"
        root.children = [RawSkeleton.Joint()]

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        let input = [SoaTransform.identity(), SoaTransform.identity()]
        var output = [simd_float4x4](repeating: simd_float4x4(), count: 5)

        // Default job
        do {
            let job = LocalToModelJob()
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }
        // nullptr input
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[..<2]))
        }
        // Null skeleton.
        do {
            let job = LocalToModelJob()
            job.input = input[0..<1]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[..<4]))
        }
        // Invalid output range: end < begin.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[0..<1]
            XCTAssertTrue(job.validate())
            XCTAssertFalse(job.run(&output[..<1]))
        }
        // Invalid output range: too small.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[0..<1]
            XCTAssertTrue(job.validate())
            XCTAssertFalse(job.run(&output[..<1]))
        }
        // Invalid input range: too small.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[0..<0]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run(&output[...]))
        }
        // Valid job.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid job with root matrix.
        do {
            let job = LocalToModelJob()
            let v = simd_float4.load(4.0, 3.0, 2.0, 1.0)
            let world = simd_float4x4.translation(v)
            job.skeleton = skeleton
            job.root = world
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid out-of-bound from.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 93
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid out-of-bound from.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = -93
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid out-of-bound to.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 93
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid out-of-bound to.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = -93
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<2]))
        }
        // Valid job with empty skeleton.
        do {
            let job = LocalToModelJob()
            job.skeleton = empty_skeleton
            job.input = input[0..<0]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[..<0]))
        }
        // Valid job. Bigger input & output
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
        }
    }

    func testTransformation() {
        // Builds the skeleton
        /*
         6 joints
           j0
          /  \
         j1  j3
          |  / \
         j2 j4 j5
        */
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "j0"

        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[0].name = "j1"
        root.children[1].name = "j3"

        root.children[0].children = [RawSkeleton.Joint()]
        root.children[0].children[0].name = "j2"

        root.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[1].children[0].name = "j4"
        root.children[1].children[1].name = "j5"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 6)

        let builder = SkeletonBuilder()
        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        // Initializes an input transformation.
        let input: [SoaTransform] = [
            // Stores up to 8 inputs, needs 6.
            SoaTransform(translation: SoaFloat3(
                    x: simd_float4.load(2.0, 0.0, 1.0, -2.0),
                    y: simd_float4.load(2.0, 0.0, 2.0, -2.0),
                    z: simd_float4.load(2.0, 0.0, 4.0, -2.0)),
                    rotation: SoaQuaternion(
                            x: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            y: simd_float4.load(0.0, 0.70710677, 0.0, 0.0),
                            z: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            w: simd_float4.load(1.0, 0.70710677, 1.0, 1.0)),
                    scale: SoaFloat3(x
                    : simd_float4.load(1.0, 1.0, 1.0, 10.0),
                            y: simd_float4.load(1.0, 1.0, 1.0, 10.0),
                            z: simd_float4.load(1.0, 1.0, 1.0, 10.0))),
            SoaTransform(translation: SoaFloat3(
                    x: simd_float4.load(12.0, 0.0, 0.0, 0.0),
                    y: simd_float4.load(46.0, 0.0, 0.0, 0.0),
                    z: simd_float4.load(-12.0, 0.0, 0.0, 0.0)),
                    rotation: SoaQuaternion(
                            x: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            y: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            z: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            w: simd_float4.load(1.0, 1.0, 1.0, 1.0)),
                    scale: SoaFloat3(
                            x: simd_float4.load(1.0, -0.1, 1.0, 1.0),
                            y: simd_float4.load(1.0, -0.1, 1.0, 1.0),
                            z: simd_float4.load(1.0, -0.1, 1.0, 1.0)))
        ]

        do {
            // Prepares the job with root == nullptr (default identity matrix)
            var output = [simd_float4x4](repeating: simd_float4x4(), count: 6)
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
            EXPECT_FLOAT4x4_EQ(output[0],
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1],
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2],
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    6.0, 4.0, 1.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3],
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4],
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    120.0, 460.0, -120.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5],
                    -1.0, 0.0, 0.0, 0.0,
                    0.0, -1.0, 0.0, 0.0,
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 0.0, 0.0, 1.0)
        }

        do {
            // Prepares the job with root == Translation(4,3,2,1)
            var output = [simd_float4x4](repeating: simd_float4x4(), count: 6)
            let v = simd_float4.load(4.0, 3.0, 2.0, 1.0)
            let world = simd_float4x4.translation(v)
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.root = world
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))
            EXPECT_FLOAT4x4_EQ(output[0],
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    6.0, 5.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1],
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    6.0, 5.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2],
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    10.0, 7.0, 3.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3],
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    4.0, 3.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4],
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    124.0, 463.0, -118.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5],
                    -1.0, 0.0, 0.0, 0.0,
                    0.0, -1.0, 0.0, 0.0,
                    0.0, 0.0, -1.0, 0.0,
                    4.0, 3.0, 2.0, 1.0)
        }
    }

    func testTransformationFromTo() {
        // Builds the skeleton
        /*
         6 joints
               *
             /   \
           j0    j7
          /  \
         j1  j3
          |  / \
         j2 j4 j6
             |
            j5
        */
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let j0 = raw_skeleton.roots[0]
        j0.name = "j0"
        let j7 = raw_skeleton.roots[1]
        j7.name = "j7"

        j0.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[0].name = "j1"
        j0.children[1].name = "j3"

        j0.children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].name = "j2"

        j0.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[1].children[0].name = "j4"
        j0.children[1].children[1].name = "j6"

        j0.children[1].children[0].children = [RawSkeleton.Joint()]
        j0.children[1].children[0].children[0].name = "j5"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 8)

        let builder = SkeletonBuilder()
        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        // Initializes an input transformation.
        let input: [SoaTransform] = [
            // Stores up to 8 inputs, needs 7.
            //                             j0   j1   j2    j3
            SoaTransform(translation: SoaFloat3(x: simd_float4.load(2.0, 0.0, -2.0, 1.0),
                    y: simd_float4.load(2.0, 0.0, -2.0, 2.0),
                    z: simd_float4.load(2.0, 0.0, -2.0, 4.0)),
                    rotation: SoaQuaternion(x: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            y: simd_float4.load(0.0, 0.70710677, 0.0, 0.0),
                            z: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            w: simd_float4.load(1.0, 0.70710677, 1.0, 1.0)),
                    scale: SoaFloat3(x: simd_float4.load(1.0, 1.0, 10.0, 1.0),
                            y: simd_float4.load(1.0, 1.0, 10.0, 1.0),
                            z: simd_float4.load(1.0, 1.0, 10.0, 1.0))),
            //                             j4    j5   j6   j7.
            SoaTransform(translation: SoaFloat3(x: simd_float4.load(12.0, 0.0, 3.0, 6.0),
                    y: simd_float4.load(46.0, 0.0, 4.0, 7.0),
                    z: simd_float4.load(-12.0, 0.0, 5.0, 8.0)),
                    rotation: SoaQuaternion(x: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            y: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            z: simd_float4.load(0.0, 0.0, 0.0, 0.0),
                            w: simd_float4.load(1.0, 1.0, 1.0, 1.0)),
                    scale: SoaFloat3(x: simd_float4.load(1.0, -0.1, 1.0, 1.0),
                            y: simd_float4.load(1.0, -0.1, 1.0, 1.0),
                            z: simd_float4.load(1.0, -0.1, 1.0, 1.0)))
        ]

        var output = [simd_float4x4](repeating: simd_float4x4(), count: 8)
        let job_full = LocalToModelJob()
        do {  // Intialize whole hierarchy output
            job_full.skeleton = skeleton
            job_full.from = SoaSkeleton.Constants.kNoParent.rawValue
            job_full.input = input[...]
            XCTAssertTrue(job_full.validate())
            XCTAssertTrue(job_full.run(&output[...]))
            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 7.0, 8.0, 1.0)
        }

        do {  // Updates from j0, j7 shouldn't be updated
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 0
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j7, j0-6 shouldn't be updated
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 7
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 7.0, 8.0, 1.0)
        }

        do {  // Updates from j1, j1-2 should be updated
            XCTAssertTrue(job_full.run(&output[...]))
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 1
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j3, j3-6 should be updated
            XCTAssertTrue(job_full.run(&output[...]))
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 3
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j5, j5 should only be updated
            XCTAssertTrue(job_full.run(&output[...]))
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 5
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j6, j6 should only be updated
            XCTAssertTrue(job_full.run(&output[...]))
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 6
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j0 to j2,
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 0
            job.to = 2
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j0 to j6, j7 shouldn't be updated
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 0
            job.to = 6
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j0 to past end, j7 shouldn't be updated
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 0
            job.to = 46
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 0.0, 0.0, -10.0, 0.0, 0.0, 10.0, 0.0, 0.0,
                    10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 3.0, 4.0, 6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], -0.1, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0,
                    0.0, -0.1, 0.0, 15.0, 50.0, -6.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 6.0, 8.0, 11.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from j0 to nowehere, nothing should be updated
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 0
            job.to = -99
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

        do {  // Updates from out-of-range value, nothing should be updated
            XCTAssertTrue(job_full.run(&output[...]))
            output[0] = matrix_float4x4.identity()
            output[1] = matrix_float4x4.identity()
            output[2] = matrix_float4x4.identity()
            output[3] = matrix_float4x4.identity()
            output[4] = matrix_float4x4.identity()
            output[5] = matrix_float4x4.identity()
            output[6] = matrix_float4x4.identity()
            output[7] = matrix_float4x4.identity()

            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 93
            job.input = input[...]
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&output[...]))

            EXPECT_FLOAT4x4_EQ(output[0], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[6], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[7], 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        }

    }
}
