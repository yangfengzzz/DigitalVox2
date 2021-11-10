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
        let job = IKAimJob()
        var quat = SimdQuaternion()
        let joint = simd_float4x4.identity()
        job.joint = joint
        var reached: Bool = false

        job.target = simd_float4.x_axis()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()
        job.pole_vector = simd_float4.y_axis()

        do {  // No offset
            reached = false
            job.offset = simd_float4.zero()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset inside target sphere
            reached = false
            job.offset = simd_float4.load(0.0, kSqrt2_2, 0.0, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_4 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_4)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_4.x, z_Pi_4.y, z_Pi_4.z, z_Pi_4.w, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset inside target sphere
            reached = false
            job.offset = simd_float4.load(0.5, 0.5, 0.0, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_6 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi / 6.0)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_6.x, z_Pi_6.y, z_Pi_6.z, z_Pi_6.w, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset inside target sphere
            reached = false
            job.offset = simd_float4.load(-0.5, 0.5, 0.0, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_6 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi / 6.0)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_6.x, z_Pi_6.y, z_Pi_6.z, z_Pi_6.w, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset inside target sphere
            reached = false
            job.offset = simd_float4.load(0.5, 0.0, 0.5, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let y_Pi_6 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi / 6.0)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_Pi_6.x, y_Pi_6.y, y_Pi_6.z, y_Pi_6.w, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset on target sphere
            reached = false
            job.offset = simd_float4.load(0.0, 1.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
            XCTAssertTrue(reached)
        }

        do {  // Offset outside of target sphere, unreachable
            reached = true
            job.offset = simd_float4.load(0.0, 2.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
            XCTAssertFalse(reached)
        }

        let translated_joint = simd_float4x4.translation(simd_float4.y_axis())
        job.joint = translated_joint

        do {  // Offset inside of target sphere, unreachable
            reached = false
            job.offset = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
            XCTAssertTrue(reached)
        }
    }

    func testTwist() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.x_axis()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()

        do {  // Pole y, twist 0
            job.pole_vector = simd_float4.y_axis()
            job.twist_angle = 0.0
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Pole y, twist pi
            job.pole_vector = simd_float4.y_axis()
            job.twist_angle = kPi
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi.x, x_Pi.y, x_Pi.z, x_Pi.w, 2e-3)
        }

        do {  // Pole y, twist -pi
            job.pole_vector = simd_float4.y_axis()
            job.twist_angle = -kPi
            XCTAssertTrue(job.run(&quat, &reached))
            let x_mPi = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_mPi.x, x_mPi.y, x_mPi.z, x_mPi.w, 2e-3)
        }

        do {  // Pole y, twist pi/2
            job.pole_vector = simd_float4.y_axis()
            job.twist_angle = kPi_2
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi_2.x, x_Pi_2.y, x_Pi_2.z, x_Pi_2.w, 2e-3)
        }

        do {  // Pole z, twist pi/2
            job.pole_vector = simd_float4.z_axis()
            job.twist_angle = kPi_2
            XCTAssertTrue(job.run(&quat, &reached))
            let x_Pi = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, x_Pi.x, x_Pi.y, x_Pi.z, x_Pi.w, 2e-3)
        }
    }

    func testAlignedTargetUp() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.forward = simd_float4.x_axis()
        job.pole_vector = simd_float4.y_axis()

        do {  // Not aligned
            job.target = simd_float4.x_axis()
            job.up = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Aligned y
            job.target = simd_float4.y_axis()
            job.up = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }

        do {  // Aligned 2*y
            job.target = simd_float4.y_axis() * simd_float4.load1(2.0)
            job.up = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }

        do {  // Aligned -2*y
            job.target = simd_float4.y_axis() * simd_float4.load1(-2.0)
            job.up = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
        }
    }

    func testAlignedTargetPole() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()

        do {  // Not aligned
            job.target = simd_float4.x_axis()
            job.pole_vector = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Aligned y
            job.target = simd_float4.y_axis()
            job.pole_vector = simd_float4.y_axis()
            XCTAssertTrue(job.run(&quat, &reached))
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }
    }

    func testTargetTooClose() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.zero()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()
        job.pole_vector = simd_float4.y_axis()

        XCTAssertTrue(job.run(&quat, &reached))
        EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
    }

    func testWeight() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.identity()
        job.joint = joint

        job.target = simd_float4.z_axis()
        job.forward = simd_float4.x_axis()
        job.up = simd_float4.y_axis()
        job.pole_vector = simd_float4.y_axis()

        do {  // Full weight
            job.weight = 1.0
            XCTAssertTrue(job.run(&quat, &reached))
            let y_mPi2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_mPi2.x, y_mPi2.y, y_mPi2.z, y_mPi2.w, 2e-3)
        }

        do {  // > 1
            job.weight = 2.0
            XCTAssertTrue(job.run(&quat, &reached))
            let y_mPi2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_mPi2.x, y_mPi2.y, y_mPi2.z, y_mPi2.w, 2e-3)
        }

        do {  // Half weight
            job.weight = 0.5
            XCTAssertTrue(job.run(&quat, &reached))
            let y_mPi4 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_4)
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, y_mPi4.x, y_mPi4.y, y_mPi4.z, y_mPi4.w, 2e-3)
        }

        do {  // Zero weight
            job.weight = 0.0
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // < 0
            job.weight = -0.5
            XCTAssertTrue(job.run(&quat, &reached))
            EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }
    }

    func testZeroScale() {
        let job = IKAimJob()
        var quat = SimdQuaternion()
        var reached = false
        let joint = simd_float4x4.scaling(simd_float4.zero())
        job.joint = joint

        XCTAssertTrue(job.run(&quat, &reached))
        EXPECT_SIMDQUATERNION_EQ_TOL(quat, 0.0, 0.0, 0.0, 1.0, 2e-3)
    }
}
