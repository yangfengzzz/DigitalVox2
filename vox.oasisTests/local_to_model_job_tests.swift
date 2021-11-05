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
        let output: NSMutableArray = .init(array: [simd_float4x4](repeating: simd_float4x4(), count: 5))

        // Default job
        do {
            let job = LocalToModelJob()
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run())
        }

        // nullptr output
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[0..<1]
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run())
        }
        // nullptr input
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.output = output
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run())
        }
        // Null skeleton.
        do {
            let job = LocalToModelJob()
            job.input = input[0..<1]
            job.output = output
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run())
        }
        // Invalid input range: too small.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[0..<0]
            job.output = output
            XCTAssertFalse(job.validate())
            XCTAssertFalse(job.run())
        }
        // Valid job.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid job with root matrix.
        do {
            let job = LocalToModelJob()
            let v = simd_float4.load(4.0, 3.0, 2.0, 1.0)
            let world = simd_float4x4.translation(v)
            job.skeleton = skeleton
            job.root = world
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid out-of-bound from.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 93
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid out-of-bound from.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = -93
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid out-of-bound to.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = 93
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid out-of-bound to.
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.from = -93
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid job with empty skeleton.
        do {
            let job = LocalToModelJob()
            job.skeleton = empty_skeleton
            job.input = input[0..<0]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
        }
        // Valid job. Bigger input & output
        do {
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
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
            let output: NSMutableArray = .init(array: [simd_float4x4](repeating: simd_float4x4(), count: 6))
            let job = LocalToModelJob()
            job.skeleton = skeleton
            job.input = input[...]
            job.output = output
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run())
            EXPECT_FLOAT4x4_EQ(output[0] as! simd_float4x4,
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[1] as! simd_float4x4,
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    2.0, 2.0, 2.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[2] as! simd_float4x4,
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    1.0, 0.0, 0.0, 0.0,
                    6.0, 4.0, 1.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[3] as! simd_float4x4,
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    0.0, 0.0, 0.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[4] as! simd_float4x4,
                    10.0, 0.0, 0.0, 0.0,
                    0.0, 10.0, 0.0, 0.0,
                    0.0, 0.0, 10.0, 0.0,
                    120.0, 460.0, -120.0, 1.0)
            EXPECT_FLOAT4x4_EQ(output[5] as! simd_float4x4,
                    -1.0, 0.0, 0.0, 0.0,
                    0.0, -1.0, 0.0, 0.0,
                    0.0, 0.0, -1.0, 0.0,
                    0.0, 0.0, 0.0, 1.0)
        }
    }
}
