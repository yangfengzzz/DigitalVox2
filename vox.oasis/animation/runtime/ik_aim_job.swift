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
class IKAimJob {
    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if output quaternion pointer is nullptr
    func validate() -> Bool {
        var valid = true
        valid = valid && joint != nil
        valid = valid && areAllTrue1(isNormalizedEst3(forward))
        return valid
    }

    // Runs job's execution task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func run(_ joint_correction: inout SimdQuaternion, _ reached: inout Bool) -> Bool {
        if (!validate()) {
            return false
        }

        // If matrices aren't invertible, they'll be all 0 (ozz::math
        // implementation), which will result in identity correction quaternions.
        var invertible = SimdInt4()
        let inv_joint = invert(joint!, &invertible)

        // Computes joint to target vector, in joint local-space (_js).
        let joint_to_target_js = transformPoint(inv_joint, target)
        let joint_to_target_js_len2 = length3Sqr(joint_to_target_js)

        // Recomputes forward vector to account for offset.
        // If the offset is further than target, it won't be reachable.
        var offsetted_forward = simd_float4()
        let lreached = computeOffsettedForward(forward, offset, joint_to_target_js, &offsetted_forward)
        // Copies reachability result.
        // If offsetted forward vector doesn't exists, target position cannot be
        // aimed.
        reached = lreached

        if (!lreached || areAllTrue1(cmpEq(joint_to_target_js_len2, simd_float4.zero()))) {
            // Target can't be reached or is too close to joint position to find a
            // direction.
            joint_correction = SimdQuaternion.identity()
            return true
        }

        // Calculates joint_to_target_rot_ss quaternion which solves for
        // offsetted_forward vector rotating onto the target.
        let joint_to_target_rot_js = SimdQuaternion.fromVectors(offsetted_forward, joint_to_target_js)

        // Calculates rotate_plane_js quaternion which aligns joint up to the pole vector.
        let corrected_up_js = transformVector(joint_to_target_rot_js, up)

        // Compute (and normalize) reference and pole planes normals.
        let pole_vector_js = transformVector(inv_joint, pole_vector)
        let ref_joint_normal_js = cross3(pole_vector_js, joint_to_target_js)
        let joint_normal_js = cross3(corrected_up_js, joint_to_target_js)
        let ref_joint_normal_js_len2 = length3Sqr(ref_joint_normal_js)
        let joint_normal_js_len2 = length3Sqr(joint_normal_js)

        let denoms = setZ(setY(joint_to_target_js_len2, joint_normal_js_len2), ref_joint_normal_js_len2)

        var rotate_plane_axis_js = simd_float4()
        var rotate_plane_js = SimdQuaternion()
        // Computing rotation axis and plane requires valid normals.
        if (areAllTrue3(cmpNe(denoms, simd_float4.zero()))) {
            let rsqrts = rSqrtEstNR(setZ(setY(joint_to_target_js_len2, joint_normal_js_len2), ref_joint_normal_js_len2))

            // Computes rotation axis, which is either joint_to_target_js or
            // -joint_to_target_js depending on rotation direction.
            rotate_plane_axis_js = joint_to_target_js * splatX(rsqrts)

            // Computes angle cosine between the 2 normalized plane normals.
            let rotate_plane_cos_angle = dot3(joint_normal_js * splatY(rsqrts), ref_joint_normal_js * splatZ(rsqrts))
            let axis_flip = and(splatX(dot3(ref_joint_normal_js, corrected_up_js)), SimdInt4.mask_sign())
            let rotate_plane_axis_flipped_js = xor(rotate_plane_axis_js, axis_flip)

            // Builds quaternion along rotation axis.
            let one = simd_float4.one()
            rotate_plane_js = SimdQuaternion.fromAxisCosAngle(rotate_plane_axis_flipped_js, clamp(-one, rotate_plane_cos_angle, one))
        } else {
            rotate_plane_axis_js = joint_to_target_js * splatX(rSqrtEstXNR(denoms))
            rotate_plane_js = SimdQuaternion.identity()
        }

        // Twists rotation plane.
        var twisted = SimdQuaternion()
        if (twist_angle != 0.0) {
            // If a twist angle is provided, rotation angle is rotated around joint to
            // target vector.
            let twist_ss = SimdQuaternion.fromAxisAngle(rotate_plane_axis_js, simd_float4.load1(twist_angle))
            twisted = twist_ss * rotate_plane_js * joint_to_target_rot_js
        } else {
            twisted = rotate_plane_js * joint_to_target_rot_js
        }

        // Weights output quaternion.

        // Fix up quaternions so w is always positive, which is required for NLerp
        // (with identity quaternion) to lerp the shortest path.
        let twisted_fu = xor(twisted.xyzw, and(SimdInt4.mask_sign(), cmpLt(splatW(twisted.xyzw), simd_float4.zero())))

        if (weight < 1.0) {
            // NLerp start and mid joint rotations.
            let identity = simd_float4.w_axis()
            let simd_weight = max0(simd_float4.load1(weight))
            joint_correction.xyzw = normalizeEst4(lerp(identity, twisted.xyzw, simd_weight))
        } else {
            // Quaternion doesn't need interpolation
            joint_correction.xyzw = twisted_fu
        }

        return true
    }

    // Job input.

    // Target position to aim at, in model-space
    var target: simd_float4 = simd_float4.zero()

    // Joint forward axis, in joint local-space, to be aimed at target position.
    // This vector shall be normalized, otherwise validation will fail.
    // Default is x axis.
    var forward: simd_float4 = simd_float4.x_axis()

    // Offset position from the joint in local-space, that will aim at target.
    var offset: simd_float4 = simd_float4.zero()

    // Joint up axis, in joint local-space, used to keep the joint oriented in the
    // same direction as the pole vector. Default is y axis.
    var up: simd_float4 = simd_float4.y_axis()

    // Pole vector, in model-space. The pole vector defines the direction
    // the up should point to.  Note that IK chain orientation will flip when
    // target vector and the pole vector are aligned/crossing each other. It's
    // caller responsibility to ensure that this doesn't happen.
    var pole_vector: simd_float4 = simd_float4.y_axis()

    // Twist_angle rotates joint around the target vector.
    // Default is 0.
    var twist_angle: Float = 0.0

    // Weight given to the IK correction clamped in range [0,1]. This allows to
    // blend / interpolate from no IK applied (0 weight) to full IK (1).
    var weight: Float = 1.0

    // Joint model-space matrix.
    var joint: matrix_float4x4?
}

// When there's an offset, the forward vector needs to be recomputed.
// The idea is to find the vector that will allow the point at offset position
// to aim at target position. This vector starts at joint position. It ends on a
// line perpendicular to pivot-offset line, at the intersection with the sphere
// defined by target position (centered on joint position). See geogebra
// diagram: media/doc/src/ik_aim_offset.ggb
fileprivate func computeOffsettedForward(_ _forward: simd_float4, _ _offset: simd_float4,
                                         _ _target: simd_float4,
                                         _ _offsetted_forward: inout simd_float4) -> Bool {
    // AO is projected offset vector onto the normalized forward vector.
    assert(areAllTrue1(isNormalizedEst3(_forward)))
    let AOl = dot3(_forward, _offset)

    // Compute square length of ac using Pythagorean theorem.
    let ACl2 = length3Sqr(_offset) - AOl * AOl

    // Square length of target vector, aka circle radius.
    let r2 = length3Sqr(_target)

    // If offset is outside of the sphere defined by target length, the target
    // isn't reachable.
    if (areAllTrue1(cmpGt(ACl2, r2))) {
        return false
    }

    // AIl is the length of the vector from offset to sphere intersection.
    let AIl = sqrtX(r2 - ACl2)

    // The distance from offset position to the intersection with the sphere is
    // (AIl - AOl) Intersection point on the sphere can thus be computed.
    _offsetted_forward = _offset + _forward * splatX(AIl - AOl)

    return true
}
