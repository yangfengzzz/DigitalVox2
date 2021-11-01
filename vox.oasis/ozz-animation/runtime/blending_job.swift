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
struct BlendingJob {
    // Validates job parameters.
    // Returns true for a valid job, false otherwise:
    // -if layer range is not valid (can be empty though).
    // -if additive layer range is not valid (can be empty though).
    // -if any layer is not valid.
    // -if output range is not valid.
    // -if any buffer (including layers' content : transform, joint weights...) is
    // smaller than the bind pose buffer.
    // -if the threshold value is less than or equal to 0.f.
    func Validate() -> Bool {
        fatalError()
    }

    // Runs job's blending task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func Run() -> Bool {
        fatalError()
    }

    // Defines a layer of blending input data (local space transforms) and
    // parameters (weights).
    struct Layer {
        // Blending weight of this layer. Negative values are considered as 0.
        // Normalization is performed during the blending stage so weight can be in
        // any range, even though range [0:1] is optimal.
        var weight: Float

        // The range [begin,end[ of input layer posture. This buffer expect to store
        // local space transforms, that are usually outputted from a sampling job.
        // This range must be at least as big as the bind pose buffer, even though
        // only the number of transforms defined by the bind pose buffer will be
        // processed.
        var transform: ArraySlice<SoaTransform>

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
        var joint_weights: ArraySlice<SimdFloat4>
    }

    // The job blends the bind pose to the output when the accumulated weight of
    // all layers is less than this threshold value.
    // Must be greater than 0.f.
    var threshold: Float

    // Job input layers, can be empty or nullptr.
    // The range of layers that must be blended.
    var layers: ArraySlice<Layer>

    // Job input additive layers, can be empty or nullptr.
    // The range of layers that must be added to the output.
    var additive_layers: ArraySlice<Layer>

    // The skeleton bind pose. The size of this buffer defines the number of
    // transforms to blend. This is the reference because this buffer is defined
    // by the skeleton that all the animations belongs to.
    // It is used when the accumulated weight for a bone on all layers is
    // less than the threshold value, in order to fall back on valid transforms.
    var bind_pose: ArraySlice<SoaTransform>

    // Job output.
    // The range of output transforms to be filled with blended layer
    // transforms during job execution.
    // Must be at least as big as the bind pose buffer, but only the number of
    // transforms defined by the bind pose buffer size will be processed.
    var output: ArraySlice<SoaTransform>
}
