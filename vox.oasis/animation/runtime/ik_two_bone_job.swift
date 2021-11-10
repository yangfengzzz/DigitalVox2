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
        fatalError()
    }

    // Runs job's execution task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func run(_ start_joint_correction: inout SimdQuaternion,
             _ mid_joint_correction: inout SimdQuaternion,
             _ reached: inout Bool) -> Bool {
        fatalError()
    }

    // Job input.

    // Target IK position, in model-space. This is the position the end of the
    // joint chain will try to reach.
    var target: simd_float4!

    // Normalized middle joint rotation axis, in middle joint local-space. Default
    // value is z axis. This axis is usually fixed for a given skeleton (as it's
    // in middle joint space). Its direction is defined like this: a positive
    // rotation around this axis will open the angle between the two bones. This
    // in turn also to define which side the two joints must bend. Job validation
    // will fail if mid_axis isn't normalized.
    var mid_axis: simd_float4!

    // Pole vector, in model-space. The pole vector defines the direction the
    // middle joint should point to, allowing to control IK chain orientation.
    // Note that IK chain orientation will flip when target vector and the pole
    // vector are aligned/crossing each other. It's caller responsibility to
    // ensure that this doesn't happen.
    var pole_vector: simd_float4!

    // Twist_angle rotates IK chain around the vector define by start-to-target
    // vector. Default is 0.
    var twist_angle: Float!

    // Soften ratio allows the chain to gradually fall behind the target
    // position. This prevents the joint chain from snapping into the final
    // position, softening the final degrees before the joint chain becomes flat.
    // This ratio represents the distance to the end, from which softening is
    // starting.
    var soften: Float!

    // Weight given to the IK correction clamped in range [0,1]. This allows to
    // blend / interpolate from no IK applied (0 weight) to full IK (1).
    var weight: Float!

    // Model-space matrices of the start, middle and end joints of the chain.
    // The 3 joints should be ancestors. They don't need to be direct
    // ancestors though.
    var start_joint: matrix_float4x4!
    var mid_joint: matrix_float4x4!
    var end_joint: matrix_float4x4!
}
