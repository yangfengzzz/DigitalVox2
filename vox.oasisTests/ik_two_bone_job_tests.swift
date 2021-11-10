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

    }

    func testPole() {

    }

    func testZeroScale() {

    }

    func testSoften() {

    }

    func testTwist() {

    }

    func testWeight() {

    }

    func testPoleTargetAlignment() {

    }

    func testMidAxis() {

    }

    func testAlignedJointsAndTarget() {

    }

    func testZeroLengthStartTarget() {

    }

    func testZeroLengthBoneChain() {

    }
}
