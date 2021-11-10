//
//  ik_two_bone_job_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/10.
//

import XCTest
@testable import vox_oasis

class IKTwoBoneJobTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func EXPECT_REACHED(_ _job: IKTwoBoneJob,
                        _ start_joint_correction: SimdQuaternion,
                        _ mid_joint_correction: SimdQuaternion) {
        _ExpectReached(_job, true, start_joint_correction, mid_joint_correction)
    }

    func EXPECT_NOT_REACHED(_ _job: IKTwoBoneJob,
                            _ start_joint_correction: SimdQuaternion,
                            _ mid_joint_correction: SimdQuaternion) {
        _ExpectReached(_job, false, start_joint_correction, mid_joint_correction)
    }

    func _ExpectReached(_ _job: IKTwoBoneJob, _ _reachable: Bool,
                        _ start_joint_correction: SimdQuaternion,
                        _ mid_joint_correction: SimdQuaternion) {
        // Computes local transforms
        var invertiable = SimdInt4()
        let mid_local = invert(_job.start_joint!, &invertiable) * _job.mid_joint!
        let end_local = invert(_job.mid_joint!, &invertiable) * _job.end_joint!

        // Rebuild corrected model transforms
        let start_correction = simd_float4x4.fromQuaternion(start_joint_correction.xyzw)
        let start_corrected = _job.start_joint! * start_correction
        let mid_correction = simd_float4x4.fromQuaternion(mid_joint_correction.xyzw)
        let mid_corrected = start_corrected * mid_local * mid_correction
        let end_corrected = mid_corrected * end_local

        let diff = length3(end_corrected.columns.3 - _job.target)
        XCTAssertEqual(getX(diff) < 1e-2, _reachable)
    }

    func testJobValidity() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())

        do {  // Default is invalid
            let job = IKTwoBoneJob()
            XCTAssertFalse(job.validate())
        }

        do {  // Missing start joint matrix
            let job = IKTwoBoneJob()
            job.mid_joint = mid
            job.end_joint = end
            XCTAssertFalse(job.validate())
        }

        do {  // Missing mid joint matrix
            let job = IKTwoBoneJob()
            job.start_joint = start
            job.end_joint = end
            XCTAssertFalse(job.validate())
        }

        do {  // Missing end joint matrix
            let job = IKTwoBoneJob()
            job.start_joint = start
            job.mid_joint = mid
            XCTAssertFalse(job.validate())
        }

        do {  // Missing start joint output quaternion
            let job = IKTwoBoneJob()
            job.start_joint = start
            job.mid_joint = mid
            job.end_joint = end
            XCTAssertTrue(job.validate())
        }

        do {  // Missing mid joint output quaternion
            let job = IKTwoBoneJob()
            job.start_joint = start
            job.mid_joint = mid
            job.end_joint = end
            XCTAssertTrue(job.validate())
        }

        do {  // Unnormalized mid axis
            let job = IKTwoBoneJob()
            job.mid_axis = simd_float4.load(0.0, 0.70710678, 0.0, 0.70710678)
            job.start_joint = start
            job.mid_joint = mid
            job.end_joint = end
            XCTAssertFalse(job.validate())
        }

        do {  // Valid
            let job = IKTwoBoneJob()
            job.start_joint = start
            job.mid_joint = mid
            job.end_joint = end
            XCTAssertTrue(job.validate())
        }
    }

    func testStartJointCorrection() {
        // Setup initial pose
        let base_start = simd_float4x4.identity()
        let base_mid = simd_float4x4.fromAffine(simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let base_end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())

        let mid_axis = cross3(base_start.columns.3 - base_mid.columns.3, base_end.columns.3 - base_mid.columns.3)

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
            let start = parent * base_start
            let mid = parent * base_mid
            let end = parent * base_end

            // Prepares job.
            let job = IKTwoBoneJob()
            job.pole_vector = transformVector(parent, simd_float4.y_axis())
            job.mid_axis = mid_axis
            job.start_joint = start
            job.mid_joint = mid
            job.end_joint = end
            var qstart = SimdQuaternion()
            var qmid = SimdQuaternion()
            var reached = false
            XCTAssertTrue(job.validate())

            do {  // No correction expected
                job.target = transformPoint(parent, simd_float4.load(1.0, 1.0, 0.0, 0.0))
                XCTAssertTrue(job.run(&qstart, &qmid, &reached))

                EXPECT_REACHED(job, qstart, qmid)

                EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
                EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
            }

            do {  // 90
                job.target = transformPoint(parent, simd_float4.load(0.0, 1.0, 1.0, 0.0))
                XCTAssertTrue(job.run(&qstart, &qmid, &reached))

                EXPECT_REACHED(job, qstart, qmid)

                let y_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
                EXPECT_SIMDQUATERNION_EQ_TOL(qstart, y_mPi_2.x, y_mPi_2.y, y_mPi_2.z, y_mPi_2.w, 2e-3)
                EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
            }

            do {  // 180 behind
                job.target = transformPoint(parent, simd_float4.load(-1.0, 1.0, 0.0, 0.0))
                XCTAssertTrue(job.run(&qstart, &qmid, &reached))

                EXPECT_REACHED(job, qstart, qmid)

                let y_kPi = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi)
                EXPECT_SIMDQUATERNION_EQ_TOL(qstart, y_kPi.x, y_kPi.y, y_kPi.z, y_kPi.w, 2e-3)
                EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
            }

            do {  // 270
                job.target = transformPoint(parent, simd_float4.load(0.0, 1.0, -1.0, 0.0))
                XCTAssertTrue(job.run(&qstart, &qmid, &reached))

                EXPECT_REACHED(job, qstart, qmid)

                let y_kPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2)
                EXPECT_SIMDQUATERNION_EQ_TOL(qstart, y_kPi_2.x, y_kPi_2.y, y_kPi_2.z, y_kPi_2.w, 2e-3)
                EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
            }
        }
    }

    func testPole() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())

        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        job.mid_axis = mid_axis
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Pole Y
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Pole Z
        do {
            job.pole_vector = simd_float4.z_axis()
            job.target = simd_float4.load(1.0, 0.0, 1.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let x_kPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, x_kPi_2.x, x_kPi_2.y, x_kPi_2.z, x_kPi_2.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Pole -Z
        do {
            job.pole_vector = -simd_float4.z_axis()
            job.target = simd_float4.load(1.0, 0.0, -1.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let x_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, x_mPi_2.x, x_mPi_2.y, x_mPi_2.z, x_mPi_2.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Pole X
        do {
            job.pole_vector = simd_float4.x_axis()
            job.target = simd_float4.load(1.0, -1.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Pole -X
        do {
            job.pole_vector = -simd_float4.x_axis()
            job.target = simd_float4.load(-1.0, 1.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }
    }

    func testZeroScale() {
        // Setup initial pose
        let start = simd_float4x4.scaling(simd_float4.zero())
        let mid = start
        let end = start

        // Prepares job.
        let job = IKTwoBoneJob()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        XCTAssertTrue(job.run(&qstart, &qmid, &reached))

        EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
        EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
    }

    func testSoften() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())
        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        job.mid_axis = mid_axis
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Reachable
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.soften = 1.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }

        // Reachable, softened
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0 * 0.5, 0.0, 0.0, 0.0)
            job.soften = 0.5
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)
        }

        // Reachable, softened
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0 * 0.4, 0.0, 0.0, 0.0)
            job.soften = 0.5
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)
        }

        // Not reachable, softened
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0 * 0.6, 0.0, 0.0, 0.0)
            job.soften = 0.5
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)
        }

        // Not reachable, softened at max
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0 * 0.6, 0.0, 0.0, 0.0)
            job.soften = 0.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)
        }

        // Not reachable, softened
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.soften = 0.5
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)
        }

        // Not reachable, a bit too far
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(3.0, 0.0, 0.0, 0.0)
            job.soften = 1.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)
        }
    }

    func testTwist() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())
        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.pole_vector = simd_float4.y_axis()
        job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        job.mid_axis = mid_axis
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Twist angle 0
        do {
            job.twist_angle = 0.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Twist angle pi / 2
        do {
            job.twist_angle = kPi_2
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let h_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3(0.70710678, 0.70710678, 0.0), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, h_Pi_2.x, h_Pi_2.y, h_Pi_2.z, h_Pi_2.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Twist angle pi
        do {
            job.twist_angle = kPi
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let h_Pi = VecQuaternion.fromAxisAngle(VecFloat3(0.70710678, 0.70710678, 0.0), -kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, h_Pi.x, h_Pi.y, h_Pi.z, h_Pi.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Twist angle 2pi
        do {
            job.twist_angle = kPi * 2.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }
    }

    func testWeight() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())
        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        job.mid_axis = mid_axis
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Maximum weight
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.weight = 1.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }

        // Weight > 1 is clamped
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.weight = 1.1
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }

        // 0 weight
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.weight = 0.0
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_EST(qstart, 0.0, 0.0, 0.0, 1.0)
            EXPECT_SIMDQUATERNION_EQ_EST(qmid, 0.0, 0.0, 0.0, 1.0)
        }

        // Weight < 0 is clamped
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.weight = -0.1
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_EST(qstart, 0.0, 0.0, 0.0, 1.0)
            EXPECT_SIMDQUATERNION_EQ_EST(qmid, 0.0, 0.0, 0.0, 1.0)
        }

        // .5 weight
        do {
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)
            job.weight = 0.5
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)

            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2 * job.weight)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2 * job.weight)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }
    }

    func testPoleTargetAlignment() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())
        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        job.mid_axis = mid_axis
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        do {  // Reachable, undefined qstart
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(0.0, kSqrt2, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            // qstart is undefined, many solutions in this case
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Reachable, defined qstart
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(0.001, kSqrt2, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let z_Pi_4 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_4)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, z_Pi_4.x, z_Pi_4.y, z_Pi_4.z, z_Pi_4.w, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        do {  // Full extent, undefined qstart, end not reached
            job.pole_vector = simd_float4.y_axis()
            job.target = simd_float4.load(0.0, 3.0, 0.0, 0.0)
            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            // qstart is undefined, many solutions in this case
            let z_Pi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi_2.x, z_Pi_2.y, z_Pi_2.z, z_Pi_2.w, 2e-3)
        }
    }

    func testMidAxis() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())
        let mid_axis = cross3(start.columns.3 - mid.columns.3, end.columns.3 - mid.columns.3)

        // Prepares job.
        let job = IKTwoBoneJob()
        job.pole_vector = simd_float4.y_axis()
        job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Positive mid_axis
        do {
            job.mid_axis = mid_axis
            job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)

            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Negative mid_axis
        do {
            job.mid_axis = -mid_axis
            job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)

            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            let y_Pi = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, y_Pi.x, y_Pi.y, y_Pi.z, y_Pi.w, 2e-3)
            let z_Pi = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), kPi)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_Pi.x, z_Pi.y, z_Pi.z, z_Pi.w, 2e-3)
        }

        // Aligned joints
        do {
            // Replaces "end" joint matrix to align the 3 joints.
            let aligned_end = simd_float4x4.translation(simd_float4.load(0.0, 2.0, 0.0, 0.0))
            job.end_joint = aligned_end

            job.mid_axis = mid_axis
            job.target = simd_float4.load(1.0, 1.0, 0.0, 0.0)

            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            // Restore end joint matrix
            job.end_joint = end

            // Start rotates 180 on y, to allow Mid to turn positively on z axis.
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
        }
    }

    func testAlignedJointsAndTarget() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.translation(simd_float4.x_axis())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.x_axis())
        let mid_axis = simd_float4.z_axis()

        // Prepares job.
        let job = IKTwoBoneJob()
        job.pole_vector = simd_float4.y_axis()
        job.mid_axis = mid_axis
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Aligned and reachable
        do {
            job.target = simd_float4.load(2.0, 0.0, 0.0, 0.0)

            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_REACHED(job, qstart, qmid)

            // Start rotates 180 on y, to allow Mid to turn positively on z axis.
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }

        // Aligned and unreachable
        do {
            job.target = simd_float4.load(3.0, 0.0, 0.0, 0.0)

            XCTAssertTrue(job.run(&qstart, &qmid, &reached))

            EXPECT_NOT_REACHED(job, qstart, qmid)

            // Start rotates 180 on y, to allow Mid to turn positively on z axis.
            EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
            EXPECT_SIMDQUATERNION_EQ_TOL(qmid, 0.0, 0.0, 0.0, 1.0, 2e-3)
        }
    }

    func testZeroLengthStartTarget() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.fromAffine(
                simd_float4.y_axis(),
                SimdQuaternion.fromAxisAngle(simd_float4.z_axis(), simd_float4.load1(kPi_2)).xyzw,
                simd_float4.one())
        let end = simd_float4x4.translation(simd_float4.x_axis() + simd_float4.y_axis())

        // Prepares job.
        let job = IKTwoBoneJob()
        job.pole_vector = simd_float4.y_axis()
        job.target = start.columns.3  // 0 length from start to target
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        XCTAssertTrue(job.run(&qstart, &qmid, &reached))

        EXPECT_SIMDQUATERNION_EQ_TOL(qstart, 0.0, 0.0, 0.0, 1.0, 2e-3)
        // Mid joint is bent -90 degrees to reach start.
        let z_mPi_2 = VecQuaternion.fromAxisAngle(VecFloat3.z_axis(), -kPi_2)
        EXPECT_SIMDQUATERNION_EQ_TOL(qmid, z_mPi_2.x, z_mPi_2.y, z_mPi_2.z, z_mPi_2.w, 2e-3)
    }

    func testZeroLengthBoneChain() {
        // Setup initial pose
        let start = simd_float4x4.identity()
        let mid = simd_float4x4.identity()
        let end = simd_float4x4.identity()

        // Prepares job.
        let job = IKTwoBoneJob()
        job.pole_vector = simd_float4.y_axis()
        job.target = simd_float4.x_axis()
        job.start_joint = start
        job.mid_joint = mid
        job.end_joint = end
        var qstart = SimdQuaternion()
        var qmid = SimdQuaternion()
        var reached = false
        XCTAssertTrue(job.validate())

        // Just expecting it's not crashing
        XCTAssertTrue(job.run(&qstart, &qmid, &reached))

        EXPECT_NOT_REACHED(job, qstart, qmid)
    }
}
