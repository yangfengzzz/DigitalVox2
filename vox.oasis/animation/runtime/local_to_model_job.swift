//
//  local_to_model_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Computes model-space joint matrices from local-space SoaTransform.
// This job uses the skeleton to define joints parent-child hierarchy. The job
// iterates through all joints to compute their transform relatively to the
// skeleton root.
// Job inputs is an array of SoaTransform objects (in local-space), ordered like
// skeleton's joints. Job output is an array of matrices (in model-space),
// ordered like skeleton's joints. Output are matrices, because the combination
// of affine transformations can contain shearing or complex transformation
// that cannot be represented as Transform object.
struct LocalToModelJob {
    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if any input pointer, including ranges, is nullptr.
    // -if the size of the input is smaller than the skeleton's number of joints.
    // Note that this input has a SoA format.
    // -if the size of of the output is smaller than the skeleton's number of
    // joints.
    func Validate() -> Bool {
        // Don't need any early out, as jobs are valid in most of the performance
        // critical cases.
        // Tests are written in multiple lines in order to avoid branches.
        var valid = true

        // Test for nullptr begin pointers.
        if (skeleton == nil) {
            return false
        }

        let num_joints = skeleton!.num_joints()
        let num_soa_joints = (num_joints + 3) / 4

        // Test input and output ranges, implicitly tests for nullptr end pointers.
        valid = valid && input.count >= num_soa_joints
        valid = valid && output.count >= num_joints

        return valid
    }

    // Runs job's local-to-model task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if job is not valid. See Validate() function.
    mutating func Run() -> Bool {
        if (!Validate()) {
            return false
        }

        guard let skeleton = skeleton else {
            fatalError()
        }

        let parents = skeleton.joint_parents()

        // Initializes an identity matrix that will be used to compute roots model
        // matrices without requiring a branch.
        let identity = OZZFloat4x4.identity()
        let root_matrix = (root == nil) ? identity : root

        // Applies hierarchical transformation.
        // Loop ends after "to".
        let end = min(to + 1, skeleton.num_joints())
        // Begins iteration from "from", or the next joint if "from" is excluded.
        // Process next joint if end is not reach. parents[begin] >= from is true as
        // long as "begin" is a child of "from".
        var i = max(from + (from_excluded ? 1 : 0), 0)
        var process = i < end && (!from_excluded || parents[i] >= from)
        while process {
            // Builds soa matrices from soa transforms.
            let transform = input[i / 4]
            var local_soa_matrices = SoaFloat4x4.FromAffine(
                    transform.translation, transform.rotation, transform.scale)

            // Converts to aos matrices.
            var local_aos_matrices: [Float4x4] = [Float4x4](repeating: OZZFloat4x4.identity(), count: 4)
            OZZFloat4.transpose16x16(with: &local_soa_matrices.cols.0.x,
                    local_aos_matrices[0].cols)

            // parents[i] >= from is true as long as "i" is a child of "from".
            let soa_end = (i + 4) & ~3
            while i < soa_end && process {
                let parent = parents[i]
                let parent_matrix = parent == Skeleton.Constants.kNoParent.rawValue ? root_matrix : output[parent]
                output[i] = parent_matrix! * local_aos_matrices[i & 3]

                i += 1
                process = i < end && parents[i] >= from
            }

        }
        return true
    }

    // Job input.

    // The Skeleton object describing the joint hierarchy used for local to
    // model space conversion.
    var skeleton: Skeleton?

    // The root matrix will multiply to every model space matrices, default nullptr
    // means an identity matrix. This can be used to directly compute world-space
    // transforms for example.
    var root: Float4x4?

    // Defines "from" which joint the local-to-model conversion should start.
    // Default value is ozz::Skeleton::kNoParent, meaning the whole hierarchy is
    // updated. This parameter can be used to optimize update by limiting
    // conversion to part of the joint hierarchy. Note that "from" parent should
    // be a valid matrix, as it is going to be used as part of "from" joint
    // hierarchy update.
    var from: Int = Skeleton.Constants.kNoParent.rawValue

    // Defines "to" which joint the local-to-model conversion should go, "to"
    // included. Update will end before "to" joint is reached if "to" is not part
    // of the hierarchy starting from "from". Default value is
    // ozz::animation::Skeleton::kMaxJoints, meaning the hierarchy (starting from
    // "from") is updated to the last joint.
    var to: Int = Skeleton.Constants.kMaxJoints.rawValue

    // If true, "from" joint is not updated during job execution. Update starts
    // with all children of "from". This can be used to update a model-space
    // transform independently from the local-space one. To do so: set "from"
    // joint model-space transform matrix, and run this Job with "from_excluded"
    // to update all "from" children.
    // Default value is false.
    var from_excluded: Bool = false

    // The input range that store local transforms.
    var input: ArraySlice<SoaTransform> = ArraySlice()

    //MARK: - Job output.

    // The output range to be filled with model-space matrices.
    var output: ArraySlice<Float4x4> = ArraySlice()
}
