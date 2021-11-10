//
//  ik_two_bone_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// ozz::animation::IKTwoBoneJob performs inverse kinematic on a three joints
// chain (two bones).
// The job computes the transformations (rotations) that needs to be applied to
// the first two joints of the chain (named start and middle joints) such that
// the third joint (named end) reaches the provided target position (if
// possible). The job outputs start and middle joint rotation corrections as
// quaternions.
// The three joints must be ancestors, but don't need to be direct
// ancestors (joints in-between will simply remain fixed).
// Implementation is inspired by Autodesk Maya 2 bone IK, improved stability
// wise and extended with Soften IK.
class IKTwoBoneJob {
    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if any input pointer is nullptr
    // -if mid_axis isn't normalized.
    func validate() -> Bool {
        var valid = true
        valid = valid && start_joint != nil && mid_joint != nil && end_joint != nil
        valid = valid && areAllTrue1(isNormalizedEst3(mid_axis))
        return valid
    }

    // Runs job's execution task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func run(_ start_joint_correction: inout SimdQuaternion,
             _ mid_joint_correction: inout SimdQuaternion,
             _ reached: inout Bool) -> Bool {
        if (!validate()) {
            return false
        }

        // Early out if weight is 0.
        if (weight <= 0.0) {
            // No correction.
            start_joint_correction = SimdQuaternion.identity()
            mid_joint_correction = SimdQuaternion.identity()
            // Target isn't reached.
            reached = false
            return true
        }

        // Prepares constant ik data.
        let setup = IKConstantSetup(self)

        // Finds soften target position.
        var start_target_ss = simd_float4()
        var start_target_ss_len2 = simd_float4()
        let lreached = SoftenTarget(self, setup, &start_target_ss, &start_target_ss_len2)
        reached = lreached && weight >= 1.0

        // Calculate mid_rot_local quaternion which solves for the mid_ss joint
        // rotation.
        let mid_rot_ms = ComputeMidJoint(self, setup, start_target_ss_len2)

        // Calculates end_to_target_rot_ss quaternion which solves for effector
        // rotating onto the target.
        let start_rot_ss = ComputeStartJoint(self, setup, mid_rot_ms, start_target_ss, start_target_ss_len2)

        // Finally apply weight and output quaternions.
        WeightOutput(self, setup, start_rot_ss, mid_rot_ms, &start_joint_correction, &mid_joint_correction)

        return true
    }

    // Job input.

    // Target IK position, in model-space. This is the position the end of the
    // joint chain will try to reach.
    var target: simd_float4 = simd_float4.zero()

    // Normalized middle joint rotation axis, in middle joint local-space. Default
    // value is z axis. This axis is usually fixed for a given skeleton (as it's
    // in middle joint space). Its direction is defined like this: a positive
    // rotation around this axis will open the angle between the two bones. This
    // in turn also to define which side the two joints must bend. Job validation
    // will fail if mid_axis isn't normalized.
    var mid_axis: simd_float4 = simd_float4.z_axis()

    // Pole vector, in model-space. The pole vector defines the direction the
    // middle joint should point to, allowing to control IK chain orientation.
    // Note that IK chain orientation will flip when target vector and the pole
    // vector are aligned/crossing each other. It's caller responsibility to
    // ensure that this doesn't happen.
    var pole_vector: simd_float4 = simd_float4.y_axis()

    // Twist_angle rotates IK chain around the vector define by start-to-target
    // vector. Default is 0.
    var twist_angle: Float = 0.0

    // Soften ratio allows the chain to gradually fall behind the target
    // position. This prevents the joint chain from snapping into the final
    // position, softening the final degrees before the joint chain becomes flat.
    // This ratio represents the distance to the end, from which softening is
    // starting.
    var soften: Float = 1.0

    // Weight given to the IK correction clamped in range [0,1]. This allows to
    // blend / interpolate from no IK applied (0 weight) to full IK (1).
    var weight: Float = 1.0

    // Model-space matrices of the start, middle and end joints of the chain.
    // The 3 joints should be ancestors. They don't need to be direct
    // ancestors though.
    var start_joint: matrix_float4x4?
    var mid_joint: matrix_float4x4?
    var end_joint: matrix_float4x4?
}

// Local data structure used to share constant data accross ik stages.
fileprivate struct IKConstantSetup {
    init(_ _job: IKTwoBoneJob) {
        // Prepares constants
        one = simd_float4.one()
        mask_sign = SimdInt4.mask_sign()
        m_one = xor(one, mask_sign)

        // Computes inverse matrices required to change to start and mid spaces.
        // If matrices aren't invertible, they'll be all 0 (ozz::math
        // implementation), which will result in identity correction quaternions.
        var invertible = SimdInt4()
        inv_start_joint = invert(_job.start_joint!, &invertible)
        let inv_mid_joint = invert(_job.mid_joint!, &invertible)

        // Transform some positions to mid joint space (_ms)
        let start_ms = transformPoint(inv_mid_joint, _job.start_joint!.columns.3)
        let end_ms = transformPoint(inv_mid_joint, _job.end_joint!.columns.3)

        // Transform some positions to start joint space (_ss)
        let mid_ss = transformPoint(inv_start_joint, _job.mid_joint!.columns.3)
        let end_ss = transformPoint(inv_start_joint, _job.end_joint!.columns.3)

        // Computes bones vectors and length in mid and start spaces.
        // Start joint position will be treated as 0 because all joints are
        // expressed in start joint space.
        start_mid_ms = -start_ms
        mid_end_ms = end_ms
        start_mid_ss = mid_ss
        let mid_end_ss = end_ss - mid_ss
        let start_end_ss = end_ss
        start_mid_ss_len2 = length3Sqr(start_mid_ss)
        mid_end_ss_len2 = length3Sqr(mid_end_ss)
        start_end_ss_len2 = length3Sqr(start_end_ss)
    }

    // Constants
    var one: simd_float4
    var m_one: simd_float4
    var mask_sign: SimdInt4

    // Inverse matrices
    var inv_start_joint: matrix_float4x4

    // Bones vectors and length in mid and start spaces (_ms and _ss).
    var start_mid_ms: simd_float4
    var mid_end_ms: simd_float4
    var start_mid_ss: simd_float4
    var start_mid_ss_len2: simd_float4
    var mid_end_ss_len2: simd_float4
    var start_end_ss_len2: simd_float4
}

// Smoothen target position when it's further that a ratio of the joint chain
// length, and start to target length isn't 0.
// Inspired by http://www.softimageblog.com/archives/108
// and http://www.ryanjuckett.com/programming/analytic-two-bone-ik-in-2d/
fileprivate func SoftenTarget(_ _job: IKTwoBoneJob, _ _setup: IKConstantSetup,
                              _ _start_target_ss: inout simd_float4,
                              _ _start_target_ss_len2: inout simd_float4) -> Bool {
    // Hanlde position in start joint space (_ss)
    let start_target_original_ss = transformPoint(_setup.inv_start_joint, _job.target)
    let start_target_original_ss_len2 = length3Sqr(start_target_original_ss)
    let lengths = sqrt(setZ(setY(_setup.start_mid_ss_len2, _setup.mid_end_ss_len2), start_target_original_ss_len2))
    let start_mid_ss_len = lengths
    let mid_end_ss_len = splatY(lengths)
    let start_target_original_ss_len = splatZ(lengths)
    let bone_len_diff_abs = andNot(start_mid_ss_len - mid_end_ss_len, _setup.mask_sign)
    let bones_chain_len = start_mid_ss_len + mid_end_ss_len
    // da.yzw needs to be 0
    let da = bones_chain_len * clamp(simd_float4.zero(), simd_float4.loadX(_job.soften), _setup.one)
    let ds = bones_chain_len - da

    // Sotftens target position if it is further than a ratio (_soften) of the
    // whole bone chain length. Needs to check also that ds and
    // start_target_original_ss_len2 are != 0, because they're used as a
    // denominator.
    // x = start_target_original_ss_len > da
    // y = start_target_original_ss_len > 0
    // z = start_target_original_ss_len > bone_len_diff_abs
    // w = ds                           > 0
    let left = setW(start_target_original_ss_len, ds)
    let right = setZ(da, bone_len_diff_abs)
    let comp = cmpGt(left, right)
    let comp_mask = moveMask(comp)

    // xyw all 1, z is untested.
    if ((comp_mask & 0xb) == 0xb) {
        // Finds interpolation ratio (aka alpha).
        let alpha = (start_target_original_ss_len - da) * rcpEstX(ds)
        // Approximate an exponential function with : 1-(3^4)/(alpha+3)^4
        // The derivative must be 1 for x = 0, and y must never exceeds 1.
        // Negative x aren't used.
        let three = simd_float4.load1(3.0)
        let op = setY(three, alpha + three)
        let op2 = op * op
        let op4 = op2 * op2
        let ratio = op4 * rcpEstX(splatY(op4))

        // Recomputes start_target_ss vector and length.
        let start_target_ss_len = da + ds - ds * ratio
        _start_target_ss_len2 = start_target_ss_len * start_target_ss_len
        _start_target_ss = start_target_original_ss * splatX(start_target_ss_len * rcpEstX(start_target_original_ss_len))
    } else {
        _start_target_ss = start_target_original_ss
        _start_target_ss_len2 = start_target_original_ss_len2
    }

    // The maximum distance we can reach is the soften bone chain length: da
    // (stored in !x). The minimum distance we can reach is the absolute value of
    // the difference of the 2 bone lengths, |d1−d2| (stored in z). x is 0 and z
    // is 1, yw are untested.
    return (comp_mask & 0x5) == 0x4
}

fileprivate func ComputeMidJoint(_ _job: IKTwoBoneJob,
                                 _ _setup: IKConstantSetup,
                                 _ _start_target_ss_len2: simd_float4) -> SimdQuaternion {
    // Computes expected angle at mid_ss joint, using law of cosine (generalized
    // Pythagorean).
    // c^2 = a^2 + b^2 - 2ab cosC
    // cosC = (a^2 + b^2 - c^2) / 2ab
    // Computes both corrected and initial mid joint angles
    // cosine within a single SimdFloat4 (corrected is x component, initial is y).
    let start_mid_end_sum_ss_len2 = _setup.start_mid_ss_len2 + _setup.mid_end_ss_len2
    let start_mid_end_ss_half_rlen = splatX(simd_float4.load1(0.5) * rSqrtEstXNR(_setup.start_mid_ss_len2 * _setup.mid_end_ss_len2))
    // Cos value needs to be clamped, as it will exit expected range if
    // start_target_ss_len2 is longer than the triangle can be (start_mid_ss +
    // mid_end_ss).
    let mid_cos_angles_unclamped = (splatX(start_mid_end_sum_ss_len2) - setY(_start_target_ss_len2, _setup.start_end_ss_len2)) * start_mid_end_ss_half_rlen
    let mid_cos_angles = clamp(_setup.m_one, mid_cos_angles_unclamped, _setup.one)

    // Computes corrected angle
    let mid_corrected_angle = aCosX(mid_cos_angles)

    // Computes initial angle.
    // The sign of this angle needs to be decided. It's considered negative if
    // mid-to-end joint is bent backward (mid_axis direction dictates valid
    // bent direction).
    let bent_side_ref = cross3(_setup.start_mid_ms, _job.mid_axis)
    let bent_side_flip = splatX(cmpLt(dot3(bent_side_ref, _setup.mid_end_ms), simd_float4.zero()))
    let mid_initial_angle = xor(aCosX(splatY(mid_cos_angles)), and(bent_side_flip, _setup.mask_sign))

    // Finally deduces initial to corrected angle difference.
    let mid_angles_diff = mid_corrected_angle - mid_initial_angle

    // Builds quaternion.
    return SimdQuaternion.fromAxisAngle(_job.mid_axis, mid_angles_diff)
}

fileprivate func ComputeStartJoint(_ _job: IKTwoBoneJob,
                                   _ _setup: IKConstantSetup,
                                   _ _mid_rot_ms: SimdQuaternion,
                                   _ _start_target_ss: simd_float4,
                                   _ _start_target_ss_len2: simd_float4) -> SimdQuaternion {
    // Pole vector in start joint space (_ss)
    let pole_ss = transformVector(_setup.inv_start_joint, _job.pole_vector)

    // start_mid_ss with quaternion mid_rot_ms applied.
    let mid_end_ss_final = transformVector(_setup.inv_start_joint, transformVector(_job.mid_joint!, transformVector(_mid_rot_ms, _setup.mid_end_ms)))
    let start_end_ss_final = _setup.start_mid_ss + mid_end_ss_final

    // Quaternion for rotating the effector onto the target
    let end_to_target_rot_ss = SimdQuaternion.fromVectors(start_end_ss_final, _start_target_ss)

    // Calculates rotate_plane_ss quaternion which aligns joint chain plane to
    // the reference plane (pole vector). This can only be computed if start
    // target axis is valid (not 0 length)
    // -------------------------------------------------
    var start_rot_ss = end_to_target_rot_ss
    if (areAllTrue1(cmpGt(_start_target_ss_len2, simd_float4.zero()))) {
        // Computes each plane normal.
        let ref_plane_normal_ss = cross3(_start_target_ss, pole_ss)
        let ref_plane_normal_ss_len2 = length3Sqr(ref_plane_normal_ss)
        // Computes joint chain plane normal, which is the same as mid joint axis
        // (same triangle).
        let mid_axis_ss = transformVector(_setup.inv_start_joint, transformVector(_job.mid_joint!, _job.mid_axis))
        let joint_plane_normal_ss = transformVector(end_to_target_rot_ss, mid_axis_ss)
        let joint_plane_normal_ss_len2 = length3Sqr(joint_plane_normal_ss)
        // Computes all reciprocal square roots at once.
        let rsqrts = rSqrtEstNR(setZ(setY(_start_target_ss_len2, ref_plane_normal_ss_len2), joint_plane_normal_ss_len2))

        // Computes angle cosine between the 2 normalized normals.
        let rotate_plane_cos_angle = dot3(ref_plane_normal_ss * splatY(rsqrts), joint_plane_normal_ss * splatZ(rsqrts))

        // Computes rotation axis, which is either start_target_ss or
        // -start_target_ss depending on rotation direction.
        let rotate_plane_axis_ss = _start_target_ss * splatX(rsqrts)
        let start_axis_flip = and(splatX(dot3(joint_plane_normal_ss, pole_ss)), _setup.mask_sign)
        let rotate_plane_axis_flipped_ss = xor(rotate_plane_axis_ss, start_axis_flip)

        // Builds quaternion along rotation axis.
        let rotate_plane_ss = SimdQuaternion.fromAxisCosAngle(rotate_plane_axis_flipped_ss, clamp(_setup.m_one, rotate_plane_cos_angle, _setup.one))

        if (_job.twist_angle != 0.0) {
            // If a twist angle is provided, rotation angle is rotated along
            // rotation plane axis.
            let twist_ss = SimdQuaternion.fromAxisAngle(rotate_plane_axis_ss, simd_float4.load1(_job.twist_angle))
            start_rot_ss = twist_ss * rotate_plane_ss * end_to_target_rot_ss
        } else {
            start_rot_ss = rotate_plane_ss * end_to_target_rot_ss
        }
    }
    return start_rot_ss
}

fileprivate func WeightOutput(_ _job: IKTwoBoneJob, _ _setup: IKConstantSetup,
                              _ _start_rot: SimdQuaternion,
                              _ _mid_rot: SimdQuaternion,
                              _ start_joint_correction: inout SimdQuaternion,
                              _ mid_joint_correction: inout SimdQuaternion) {
    let zero = simd_float4.zero()

    // Fix up quaternions so w is always positive, which is required for NLerp
    // (with identity quaternion) to lerp the shortest path.
    let start_rot_fu = xor(_start_rot.xyzw, and(_setup.mask_sign, cmpLt(splatW(_start_rot.xyzw), zero)))
    let mid_rot_fu = xor(_mid_rot.xyzw, and(_setup.mask_sign, cmpLt(splatW(_mid_rot.xyzw), zero)))

    if (_job.weight < 1.0) {
        // NLerp start and mid joint rotations.
        let identity = simd_float4.w_axis()
        let simd_weight = max(zero, simd_float4.load1(_job.weight))

        // Lerp
        let start_lerp = lerp(identity, start_rot_fu, simd_weight)
        let mid_lerp = lerp(identity, mid_rot_fu, simd_weight)

        // Normalize
        let rsqrts = rSqrtEstNR(setY(length4Sqr(start_lerp), length4Sqr(mid_lerp)))
        start_joint_correction.xyzw = start_lerp * splatX(rsqrts)
        mid_joint_correction.xyzw = mid_lerp * splatY(rsqrts)
    } else {
        // Quatenions don't need interpolation
        start_joint_correction.xyzw = start_rot_fu
        mid_joint_correction.xyzw = mid_rot_fu
    }
}
