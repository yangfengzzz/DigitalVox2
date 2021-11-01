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
        fatalError()
    }

    // Runs job's local-to-model task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if job is not valid. See Validate() function.
    func Run() -> Bool {
        fatalError()
    }

    // Job input.

    // The Skeleton object describing the joint hierarchy used for local to
    // model space conversion.
    var skeleton: Skeleton

    // The root matrix will multiply to every model space matrices, default nullptr
    // means an identity matrix. This can be used to directly compute world-space
    // transforms for example.
    var root: Float4x4

    // Defines "from" which joint the local-to-model conversion should start.
    // Default value is ozz::Skeleton::kNoParent, meaning the whole hierarchy is
    // updated. This parameter can be used to optimize update by limiting
    // conversion to part of the joint hierarchy. Note that "from" parent should
    // be a valid matrix, as it is going to be used as part of "from" joint
    // hierarchy update.
    var from: Int

    // Defines "to" which joint the local-to-model conversion should go, "to"
    // included. Update will end before "to" joint is reached if "to" is not part
    // of the hierarchy starting from "from". Default value is
    // ozz::animation::Skeleton::kMaxJoints, meaning the hierarchy (starting from
    // "from") is updated to the last joint.
    var to: Int

    // If true, "from" joint is not updated during job execution. Update starts
    // with all children of "from". This can be used to update a model-space
    // transform independently from the local-space one. To do so: set "from"
    // joint model-space transform matrix, and run this Job with "from_excluded"
    // to update all "from" children.
    // Default value is false.
    var from_excluded: Bool

    // The input range that store local transforms.
    var input: ArraySlice<SoaTransform>

    //MARK: - Job output.

    // The output range to be filled with model-space matrices.
    var output: ArraySlice<Float4x4>
}
