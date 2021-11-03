//
//  ik_aim_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// ozz::animation::IKAimJob rotates a joint so it aims at a target. Joint aim
// direction and up vectors can be different from joint axis. The job computes
// the transformation (rotation) that needs to be applied to the joints such
// that a provided forward vector (in joint local-space) aims at the target
// position (in skeleton model-space). Up vector (in joint local-space) is also
// used to keep the joint oriented in the same direction as the pole vector.
// The job also exposes an offset (in joint local-space) from where the forward
// vector should aim the target.
// Result is unstable if joint-to-target direction is parallel to pole vector,
// or if target is too close to joint position.
struct IKAimJob {
    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if output quaternion pointer is nullptr
    func Validate() -> Bool {
        fatalError()
    }

    // Runs job's execution task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func Run() -> Bool {
        fatalError()
    }

    // Job input.

    // Target position to aim at, in model-space
    var target: SimdFloat4

    // Joint forward axis, in joint local-space, to be aimed at target position.
    // This vector shall be normalized, otherwise validation will fail.
    // Default is x axis.
    var forward: SimdFloat4

    // Offset position from the joint in local-space, that will aim at target.
    var offset: SimdFloat4

    // Joint up axis, in joint local-space, used to keep the joint oriented in the
    // same direction as the pole vector. Default is y axis.
    var up: SimdFloat4

    // Pole vector, in model-space. The pole vector defines the direction
    // the up should point to.  Note that IK chain orientation will flip when
    // target vector and the pole vector are aligned/crossing each other. It's
    // caller responsibility to ensure that this doesn't happen.
    var pole_vector: SimdFloat4

    // Twist_angle rotates joint around the target vector.
    // Default is 0.
    var twist_angle: Float

    // Weight given to the IK correction clamped in range [0,1]. This allows to
    // blend / interpolate from no IK applied (0 weight) to full IK (1).
    var weight: Float

    // Joint model-space matrix.
    var joint: Float4x4

    //MARK: - Job output.

    // Output local-space joint correction quaternion. It needs to be multiplied
    // with joint local-space quaternion.
    var joint_correction: SimdQuaternion

    // Optional boolean output value, set to true if target can be reached with IK
    // computations. Target is considered not reachable when target is between
    // joint and offset position.
    var reached: Bool
}
