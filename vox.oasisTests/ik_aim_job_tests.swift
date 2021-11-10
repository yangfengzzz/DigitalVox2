//
//  ik_aim_job_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/10.
//

import XCTest
@testable import vox_oasis

class IKAimJobTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJobValidity() {
        let joint = simd_float4x4.identity()
        var quat = SimdQuaternion()

        do {  // Default is invalid
            let job = IKAimJob()
            XCTAssertFalse(job.validate())
        }

        do {  // Invalid joint matrix
            let job = IKAimJob()
            job.joint = joint
            XCTAssertTrue(job.validate())
        }

        do {  // Invalid output
            let job = IKAimJob()
            XCTAssertFalse(job.validate())
        }

        do {  // Invalid non normalized forward vector.
            let job = IKAimJob()
            job.forward = simd_float4.load(0.5, 0.0, 0.0, 0.0)
            XCTAssertFalse(job.validate())
        }

        do {  // Valid
            let job = IKAimJob()
            job.joint = joint
            var reached = false
            XCTAssertTrue(job.validate())
            XCTAssertTrue(job.run(&quat, &reached))
        }
    }

    func testCorrection() {
        var quat = SimdQuaternion()

        let job = IKAimJob()
        var reached = false

        // Test will be executed with different root transformations
        let parents = [
            simd_float4x4.identity(), // No root transformation
            simd_float4x4.translation(simd_float4.y_axis()), // Up
            simd_float4x4.fromEuler(simd_float4.load(kPi / 3.0, 0.0, 0.0, 0.0)), // Rotated
            simd_float4x4.scaling(simd_float4.load(2.0, 2.0, 2.0, 0.0)), // Uniformly scaled
            simd_float4x4.scaling(simd_float4.load(1.0, 2.0, 1.0, 0.0)), // Non-uniformly scaled
            simd_float4x4.scaling(simd_float4.load(-3.0, -3.0, -3.0, 0.0))  // Mirrored
        ]

        for i in 0..<parents.count {
            let parent = parents[i]
            job.joint = parent

            // These are in joint local-space
            job.forward = simd_float4.x_axis()
            job.up = simd_float4.y_axis()

            // Pole vector is in model space
            job.pole_vector = transformVector(parent, simd_float4.y_axis())

            do {  // x
                job.target = transformPoint(parent, simd_float4.x_axis())
                XCTAssertTrue(job.run(&quat, &reached))
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
            }

            do {  // -x
                job.target = transformPoint(parent, -simd_float4.x_axis())
                XCTAssertTrue(job.run(&quat, &reached))
                let y_Pi = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi)
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_Pi.x, y_Pi.y, y_Pi.z, y_Pi.w, 2e-3)
            }

            do {  // z
                job.target = transformPoint(parent, simd_float4.z_axis())
                XCTAssertTrue(job.run(&quat, &reached))
                let y_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_mPi_2.x, y_mPi_2.y, y_mPi_2.z, y_mPi_2.w, 2e-3)
            }

            do {  // -z
                job.target = transformPoint(parent, -simd_float4.z_axis())
                XCTAssertTrue(job.run(&quat, &reached))
                let y_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2)
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_Pi_2.x, y_Pi_2.y, y_Pi_2.z, y_Pi_2.w, 2e-3)
            }

            do {  // 45 up y
                job.target = transformPoint(parent, simd_float4.load(1.0, 1.0, 0.0, 0.0))
                XCTAssertTrue(job.run(&quat, &reached))
                let z_Pi_4 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_4)
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_4.x, z_Pi_4.y, z_Pi_4.z, z_Pi_4.w, 2e-3)
            }

            do {  // 45 up y, further
                job.target = transformPoint(parent, simd_float4.load(2.0, 2.0, 0.0, 0.0))
                XCTAssertTrue(job.run(&quat, &reached))
                let z_Pi_4 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_4)
                EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_4.x, z_Pi_4.y, z_Pi_4.z, z_Pi_4.w, 2e-3)
            }
        }
    }

    func testForward() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.x_axis()
        job.up = simd_float4.y_axis()
        job.pole_vector = simd_float4.y_axis()

        do {  // forward x
            job.forward = simd_float4.x_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // forward -x
            job.forward = -simd_float4.x_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let y_Pi = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_Pi.x, y_Pi.y, y_Pi.z, y_Pi.w, 2e-3)
        }

        do {  // forward z
            job.forward = simd_float4.z_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let y_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_Pi_2.x, y_Pi_2.y, y_Pi_2.z, y_Pi_2.w, 2e-3)
        }

    }

    func testUp() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.x_axis()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()
        job.pole_vector = simd_float4.y_axis()

        do {  // up y
            job.up = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // up -y
            job.up = -simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi.x, x_Pi.y, x_Pi.z, x_Pi.w, 2e-3)
        }

        do {  // up z
            job.up = simd_float4.z_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let x_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_mPi_2.x, x_mPi_2.y, x_mPi_2.z, x_mPi_2.w, 2e-3)
        }

        do {  // up 2*z
            job.up = simd_float4.z_axis() * simd_float4.load1(2.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let x_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_mPi_2.x, x_mPi_2.y, x_mPi_2.z, x_mPi_2.w, 2e-3)
        }

        do {  // up very small z
            job.up = simd_float4.z_axis() * simd_float4.load1(1e-9)
            XCTAssertTrue(job.run(&quat, &reached))
            let x_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_mPi_2.x, x_mPi_2.y, x_mPi_2.z, x_mPi_2.w, 2e-3)
        }

        do {  // up is zero
            job.up = simd_float4.zero()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }
    }

    func testPole() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.x_axis()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()

        do {  // Pole y
            job.pole_vector = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Pole -y
            job.pole_vector = -simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi.x, x_Pi.y, x_Pi.z, x_Pi.w, 2e-3)
        }

        do {  // Pole z
            job.pole_vector = simd_float4.z_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi_2.x, x_Pi_2.y, x_Pi_2.z, x_Pi_2.w,
                    2e-3)
        }

        do {  // Pole 2*z
            job.pole_vector =
                    simd_float4.z_axis() * simd_float4.load1(2.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi_2.x, x_Pi_2.y, x_Pi_2.z, x_Pi_2.w, 2e-3)
        }

        do {  // Pole very small z
            job.pole_vector = simd_float4.z_axis() * simd_float4.load1(1e-9)
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi_2.x, x_Pi_2.y, x_Pi_2.z, x_Pi_2.w, 2e-3)
        }
    }

    func testOffset() {

    }

    func testTwist() {

    }

    func testAlignedTargetUp() {

    }

    func testAlignedTargetPole() {

    }

    func testTargetTooClose() {

    }

    func testWeight() {

    }

    func testZeroScale() {

    }
}
