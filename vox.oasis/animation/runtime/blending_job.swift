//
//  blending_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// ozz::animation::BlendingJob is in charge of blending (mixing) multiple poses
// (the result of a sampled animation) according to their respective weight,
// into one output pose.
// The number of transforms/joints blended by the job is defined by the number
// of transforms of the bind pose (note that this is a SoA format). This means
// that all buffers must be at least as big as the bind pose buffer.
// Partial animation blending is supported through optional joint weights that
// can be specified with layers joint_weights buffer. Unspecified joint weights
// are considered as a unit weight of 1.f, allowing to mix full and partial
// blend operations in a single pass.
// The job does not owned any buffers (input/output) and will thus not delete
// them during job's destruction.
class BlendingJob {
    // Validates job parameters.
    // Returns true for a valid job, false otherwise:
    // -if layer range is not valid (can be empty though).
    // -if additive layer range is not valid (can be empty though).
    // -if any layer is not valid.
    // -if output range is not valid.
    // -if any buffer (including layers' content : transform, joint weights...) is
    // smaller than the bind pose buffer.
    // -if the threshold value is less than or equal to 0.f.
    func validate() -> Bool {
        // Don't need any early out, as jobs are valid in most of the performance
        // critical cases.
        // Tests are written in multiple lines in order to avoid branches.
        var valid = true

        // Test for valid threshold).
        valid = valid && threshold > 0.0

        // Test for nullptr begin pointers.
        // Blending layers are mandatory, additive aren't.
        valid = valid && !bind_pose.isEmpty

        // The bind pose size defines the ranges of transforms to blend, so all
        // other buffers should be bigger.
        let min_range = bind_pose.count

        // Validates layers.
        for layer in layers {
            valid = valid && validateLayer(layer, min_range)
        }

        // Validates additive layers.
        for layer in additive_layers {
            valid = valid && validateLayer(layer, min_range)
        }

        return valid
    }

    // Runs job's blending task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func run(_ output: inout ArraySlice<SoaTransform>) -> Bool {
        if (!validate()) {
            return false
        }
        
        if output.isEmpty || output.count < bind_pose.count {
            return false
        }

        // Initializes blended parameters that are exchanged across blend stages.
        var process_args = ProcessArgs(self)

        // Blends all layers to the job output buffers.
        blendLayers(&process_args, &output)

        // Applies bind pose.
        blendBindPose(&process_args, &output)

        // Normalizes output.
        normalize(&process_args, &output)

        // Process additive blending.
        addLayers(&process_args, &output)

        return true
    }

    // Defines a layer of blending input data (local space transforms) and
    // parameters (weights).
    struct Layer {
        // Blending weight of this layer. Negative values are considered as 0.
        // Normalization is performed during the blending stage so weight can be in
        // any range, even though range [0:1] is optimal.
        var weight: Float = 0.0

        // The range [begin,end[ of input layer posture. This buffer expect to store
        // local space transforms, that are usually outputted from a sampling job.
        // This range must be at least as big as the bind pose buffer, even though
        // only the number of transforms defined by the bind pose buffer will be
        // processed.
        var transform: ArraySlice<SoaTransform> = ArraySlice()

        // Optional range [begin,end[ of blending weight for each joint in this
        // layer.
        // If both pointers are nullptr (default case) then per joint weight
        // blending is disabled. A valid range is defined as being at least as big
        // as the bind pose buffer, even though only the number of transforms
        // defined by the bind pose buffer will be processed. When a layer doesn't
        // specifies per joint weights, then it is implicitly considered as
        // being 1.f. This default value is a reference value for the normalization
        // process, which implies that the range of values for joint weights should
        // be [0,1]. Negative weight values are considered as 0, but positive ones
        // aren't clamped because they could exceed 1.f if all layers contains valid
        // joint weights.
        var joint_weights: ArraySlice<SimdFloat4> = ArraySlice()
    }

    // The job blends the bind pose to the output when the accumulated weight of
    // all layers is less than this threshold value.
    // Must be greater than 0.f.
    var threshold: Float = 0.1

    // Job input layers, can be empty or nullptr.
    // The range of layers that must be blended.
    var layers: ArraySlice<Layer> = ArraySlice()

    // Job input additive layers, can be empty or nullptr.
    // The range of layers that must be added to the output.
    var additive_layers: ArraySlice<Layer> = ArraySlice()

    // The skeleton bind pose. The size of this buffer defines the number of
    // transforms to blend. This is the reference because this buffer is defined
    // by the skeleton that all the animations belongs to.
    // It is used when the accumulated weight for a bone on all layers is
    // less than the threshold value, in order to fall back on valid transforms.
    var bind_pose: ArraySlice<SoaTransform> = ArraySlice()
}

fileprivate func validateLayer(_ _layer: BlendingJob.Layer, _ _min_range: Int) -> Bool {
    var valid = true

    // Tests transforms validity.
    valid = valid && _layer.transform.count >= _min_range

    // Joint weights are optional.
    if (!_layer.joint_weights.isEmpty) {
        valid = valid && _layer.joint_weights.count >= _min_range
    } else {
        valid = valid && _layer.joint_weights.isEmpty
    }
    return valid
}

// Defines parameters that are passed through blending stages.
fileprivate struct ProcessArgs {
    init(_ _job: BlendingJob) {
        job = _job
        num_soa_joints = _job.bind_pose.count
        num_passes = 0
        num_partial_passes = 0
        accumulated_weight = 0.0

        // The range of all buffers has already been validated.
        assert(accumulated_weights.count >= num_soa_joints)
    }

    // Allocates enough space to store a accumulated weights per-joint.
    // It will be initialized by the first pass processed, if any.
    // This is quite big for a stack allocation (4 byte * maximum number of
    // joints). This is one of the reasons why the number of joints is limited
    // by the API.
    // Note that this array is used with SoA data.
    // This is the first argument in order to avoid wasting too much space with
    // alignment padding.
    var accumulated_weights = [simd_float4](repeating: simd_float4(), count: SoaSkeleton.Constants.kMaxSoAJoints.rawValue)

    // The job to process.
    var job: BlendingJob

    // The number of transforms to process as defined by the size of the bind
    // pose.
    var num_soa_joints: Int

    // Number of processed blended passes (excluding passes with a weight <= 0.f),
    // including partial passes.
    var num_passes: Int

    // Number of processed partial blending passes (aka with a weight per-joint).
    var num_partial_passes: Int

    // The accumulated weight of all layers.
    var accumulated_weight: Float
}

// Blends all layers of the job to its output.
fileprivate func blendLayers(_ _args: inout ProcessArgs, _ output: inout ArraySlice<SoaTransform>) {
    // Iterates through all layers and blend them to the output.
    for layer in _args.job.layers {
        // Asserts buffer sizes, which must never fail as it has been validated.
        assert(layer.transform.count >= _args.num_soa_joints)
        assert(layer.joint_weights.isEmpty ||
                (layer.joint_weights.count >= _args.num_soa_joints))

        // Skip irrelevant layers.
        if (layer.weight <= 0.0) {
            continue
        }

        // Accumulates global weights.
        _args.accumulated_weight += layer.weight
        let layer_weight = simd_float4.load1(layer.weight)

        if (!layer.joint_weights.isEmpty) {
            // This layer has per-joint weights.
            _args.num_partial_passes += 1

            if (_args.num_passes == 0) {
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    let weight = layer_weight * max0(layer.joint_weights[i])
                    _args.accumulated_weights[i] = weight

                    // OZZ_BLEND_1ST_PASS(src, weight, dest)
                    output[i].translation = src.translation * weight
                    output[i].rotation = src.rotation * weight
                    output[i].scale = src.scale * weight
                }
            } else {
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    let weight = layer_weight * max0(layer.joint_weights[i])
                    _args.accumulated_weights[i] = _args.accumulated_weights[i] + weight

                    // OZZ_BLEND_N_PASS(src, weight, dest)
                    /* Blends translation. */
                    output[i].translation = output[i].translation + src.translation * weight
                    /* Blends rotations, negates opposed quaternions to be sure to choose*/
                    /* the shortest path between the two.*/
                    let sign: SimdInt4 = sign(dot(output[i].rotation, src.rotation))
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign)
                    )
                    output[i].rotation = output[i].rotation + rotation * weight
                    /* Blends scales.*/
                    output[i].scale = output[i].scale + src.scale * weight
                }
            }
        } else {
            // This is a full layer.
            if (_args.num_passes == 0) {
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    _args.accumulated_weights[i] = layer_weight

                    // OZZ_BLEND_1ST_PASS(src, layer_weight, dest)
                    output[i].translation = src.translation * layer_weight
                    output[i].rotation = src.rotation * layer_weight
                    output[i].scale = src.scale * layer_weight
                }
            } else {
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    _args.accumulated_weights[i] = _args.accumulated_weights[i] + layer_weight

                    // OZZ_BLEND_N_PASS(src, layer_weight, dest)
                    /* Blends translation. */
                    output[i].translation = output[i].translation + src.translation * layer_weight
                    /* Blends rotations, negates opposed quaternions to be sure to choose*/
                    /* the shortest path between the two.*/
                    let sign: SimdInt4 = sign(dot(output[i].rotation, src.rotation))
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign)
                    )
                    output[i].rotation = output[i].rotation + rotation * layer_weight
                    /* Blends scales.*/
                    output[i].scale = output[i].scale + src.scale * layer_weight
                }
            }
        }
        // One more pass blended.
        _args.num_passes += 1
    }
}

// Blends bind pose to the output if accumulated weight is less than the
// threshold value.
fileprivate func blendBindPose(_ _args: inout ProcessArgs, _ output: inout ArraySlice<SoaTransform>) {
    // Asserts buffer sizes, which must never fail as it has been validated.
    assert(_args.job.bind_pose.count >= _args.num_soa_joints)

    if (_args.num_partial_passes == 0) {
        // No partial blending pass detected, threshold can be tested globally.
        let bp_weight = _args.job.threshold - _args.accumulated_weight

        if (bp_weight > 0.0) {  // The bind-pose is needed if it has a weight.
            if (_args.num_passes == 0) {
                // Strictly copying bind-pose.
                _args.accumulated_weight = 1.0
                for i in 0..<_args.num_soa_joints {
                    output[i] = _args.job.bind_pose[i]
                }
            } else {
                // Updates global accumulated weight, but not per-joint weight any more
                // because normalization stage will be global also.
                _args.accumulated_weight = _args.job.threshold

                let simd_bp_weight = simd_float4.load1(bp_weight)

                for i in 0..<_args.num_soa_joints {
                    let src = _args.job.bind_pose[i]

                    // OZZ_BLEND_N_PASS(src, simd_bp_weight, dest)
                    /* Blends translation. */
                    output[i].translation = output[i].translation + src.translation * simd_bp_weight
                    /* Blends rotations, negates opposed quaternions to be sure to choose*/
                    /* the shortest path between the two.*/
                    let sign: SimdInt4 = sign(dot(output[i].rotation, src.rotation))
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign)
                    )
                    output[i].rotation = output[i].rotation + rotation * simd_bp_weight
                    /* Blends scales.*/
                    output[i].scale = output[i].scale + src.scale * simd_bp_weight
                }
            }
        }
    } else {
        // Blending passes contain partial blending, threshold must be tested for
        // each joint.
        let threshold = simd_float4.load1(_args.job.threshold)

        // There's been at least 1 pass as num_partial_passes != 0.
        assert(_args.num_passes != 0)

        for i in 0..<_args.num_soa_joints {
            let src = _args.job.bind_pose[i]
            let bp_weight = max0(threshold - _args.accumulated_weights[i])
            _args.accumulated_weights[i] = max(threshold, _args.accumulated_weights[i])

            // OZZ_BLEND_N_PASS(src, bp_weight, dest)
            /* Blends translation. */
            output[i].translation = output[i].translation + src.translation * bp_weight
            /* Blends rotations, negates opposed quaternions to be sure to choose*/
            /* the shortest path between the two.*/
            let sign: SimdInt4 = sign(dot(output[i].rotation, src.rotation))
            let rotation = SoaQuaternion(
                    x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                    z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign)
            )
            output[i].rotation = output[i].rotation + rotation * bp_weight
            /* Blends scales.*/
            output[i].scale = output[i].scale + src.scale * bp_weight
        }
    }
}

// Normalizes output rotations. Quaternion length cannot be zero as opposed
// quaternions have been fixed up during blending passes.
// Translations and scales are already normalized because weights were
// pre-multiplied by the normalization ratio.
fileprivate func normalize(_ _args: inout ProcessArgs, _ output: inout ArraySlice<SoaTransform>) {
    if (_args.num_partial_passes == 0) {
        // Normalization of a non-partial blending requires to apply the same
        // division to all joints.
        let ratio = simd_float4.load1(1.0 / _args.accumulated_weight)
        for i in 0..<_args.num_soa_joints {
            output[i].rotation = normalizeEst(output[i].rotation)
            output[i].translation = output[i].translation * ratio
            output[i].scale = output[i].scale * ratio
        }
    } else {
        // Partial blending normalization requires to compute the divider per-joint.
        let one = simd_float4.one()
        for i in 0..<_args.num_soa_joints {
            let ratio = one / _args.accumulated_weights[i]
            output[i].rotation = normalizeEst(output[i].rotation)
            output[i].translation = output[i].translation * ratio
            output[i].scale = output[i].scale * ratio
        }
    }
}

// Process additive blending pass.
fileprivate func addLayers(_ _args: inout ProcessArgs, _ output: inout ArraySlice<SoaTransform>) {
    // Iterates through all layers and blend them to the output.
    for layer in _args.job.additive_layers {
        // Asserts buffer sizes, which must never fail as it has been validated.
        assert(layer.transform.count >= _args.num_soa_joints)
        assert(layer.joint_weights.isEmpty ||
                (layer.joint_weights.count >= _args.num_soa_joints))

        // Prepares constants.
        let one = simd_float4.one()

        if (layer.weight > 0.0) {
            // Weight is positive, need to perform additive blending.
            let layer_weight = simd_float4.load1(layer.weight)

            if (!layer.joint_weights.isEmpty) {
                // This layer has per-joint weights.
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    let weight = layer_weight * max0(layer.joint_weights[i])
                    let one_minus_weight = one - weight
                    let one_minus_weight_f3 = SoaFloat3(x: one_minus_weight, y: one_minus_weight, z: one_minus_weight)

                    // OZZ_ADD_PASS(src, weight, dest)
                    output[i].translation = output[i].translation + src.translation * weight
                    /* Interpolate quaternion between identity and src.rotation.*/
                    /* Quaternion sign is fixed up, so that lerp takes the shortest path.*/
                    let sign: SimdInt4 = sign(src.rotation.w)
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign))
                    let interp_quat = SoaQuaternion(
                            x: rotation.x * weight, y: rotation.y * weight,
                            z: rotation.z * weight, w: (rotation.w - one) * weight + one)
                    output[i].rotation = normalizeEst(interp_quat) * output[i].rotation
                    output[i].scale = output[i].scale * (one_minus_weight_f3 + (src.scale * weight))
                }
            } else {
                // This is a full layer.
                let one_minus_weight = one - layer_weight
                let one_minus_weight_f3 = SoaFloat3(
                        x: one_minus_weight, y: one_minus_weight, z: one_minus_weight)

                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]

                    // OZZ_ADD_PASS(src, layer_weight, dest)
                    output[i].translation = output[i].translation + src.translation * layer_weight
                    /* Interpolate quaternion between identity and src.rotation.*/
                    /* Quaternion sign is fixed up, so that lerp takes the shortest path.*/
                    let sign: SimdInt4 = sign(src.rotation.w)
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign))
                    let interp_quat = SoaQuaternion(
                            x: rotation.x * layer_weight, y: rotation.y * layer_weight,
                            z: rotation.z * layer_weight, w: (rotation.w - one) * layer_weight + one)
                    output[i].rotation = normalizeEst(interp_quat) * output[i].rotation
                    output[i].scale = output[i].scale * (one_minus_weight_f3 + (src.scale * layer_weight))
                }
            }
        } else if (layer.weight < 0.0) {
            // Weight is negative, need to perform subtractive blending.
            let layer_weight = simd_float4.load1(-layer.weight)

            if (!layer.joint_weights.isEmpty) {
                // This layer has per-joint weights.
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]
                    let weight = layer_weight * max0(layer.joint_weights[i])
                    let one_minus_weight = one - weight

                    // OZZ_SUB_PASS(src, weight, dest)
                    output[i].translation = output[i].translation - src.translation * weight
                    /* Interpolate quaternion between identity and src.rotation.*/
                    /* Quaternion sign is fixed up, so that lerp takes the shortest path.*/
                    let sign: SimdInt4 = sign(src.rotation.w)
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign))
                    let interp_quat = SoaQuaternion(
                            x: rotation.x * weight, y: rotation.y * weight,
                            z: rotation.z * weight, w: (rotation.w - one) * weight + one)
                    output[i].rotation = conjugate(normalizeEst(interp_quat)) * output[i].rotation
                    let rcp_scale = SoaFloat3(
                            x: rcpEst(mAdd(src.scale.x, weight, one_minus_weight)),
                            y: rcpEst(mAdd(src.scale.y, weight, one_minus_weight)),
                            z: rcpEst(mAdd(src.scale.z, weight, one_minus_weight)))
                    output[i].scale = output[i].scale * rcp_scale
                }
            } else {
                // This is a full layer.
                let one_minus_weight = one - layer_weight
                for i in 0..<_args.num_soa_joints {
                    let src = layer.transform[i]

                    // OZZ_SUB_PASS(src, layer_weight, dest)
                    output[i].translation = output[i].translation - src.translation * layer_weight
                    /* Interpolate quaternion between identity and src.rotation.*/
                    /* Quaternion sign is fixed up, so that lerp takes the shortest path.*/
                    let sign: SimdInt4 = sign(src.rotation.w)
                    let rotation = SoaQuaternion(
                            x: xor(src.rotation.x, sign), y: xor(src.rotation.y, sign),
                            z: xor(src.rotation.z, sign), w: xor(src.rotation.w, sign))
                    let interp_quat = SoaQuaternion(
                            x: rotation.x * layer_weight, y: rotation.y * layer_weight,
                            z: rotation.z * layer_weight, w: (rotation.w - one) * layer_weight + one)
                    output[i].rotation = conjugate(normalizeEst(interp_quat)) * output[i].rotation
                    let rcp_scale = SoaFloat3(
                            x: rcpEst(mAdd(src.scale.x, layer_weight, one_minus_weight)),
                            y: rcpEst(mAdd(src.scale.y, layer_weight, one_minus_weight)),
                            z: rcpEst(mAdd(src.scale.z, layer_weight, one_minus_weight)))
                    output[i].scale = output[i].scale * rcp_scale
                }
            }
        } else {
            // Skip layer as its weight is 0.
        }
    }
}
