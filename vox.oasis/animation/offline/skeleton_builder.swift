//
//  skeleton_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Defines the class responsible of building Skeleton instances.
class SkeletonBuilder {
    // Creates a Skeleton based on _raw_skeleton and *this builder parameters.
    // Returns a Skeleton instance on success, an empty unique_ptr on failure. See
    // RawSkeleton::Validate() for more details about failure reasons.
    // The skeleton is returned as an unique_ptr as ownership is given back to the
    // caller.
    func eval(_ _raw_skeleton: RawSkeleton) -> Skeleton? {
        // Tests _raw_skeleton validity.
        if (!_raw_skeleton.Validate()) {
            return nil
        }

        // Everything is fine, allocates and fills the skeleton.
        // Will not fail.
        let skeleton = Skeleton()
        let num_joints = _raw_skeleton.num_joints()

        // Iterates through all the joint of the raw skeleton and fills a sorted joint
        // list.
        // Iteration order defines runtime skeleton joint ordering.
        var lister = JointLister(num_joints)
        IterateJointsDF(_raw_skeleton, &lister)
        assert(lister.linear_joints.count == num_joints)

        // Allocates all skeleton members.
        skeleton.Allocate(num_joints)

        // Copy names. All names are allocated in a single buffer. Only the first name
        // is set, all other names array entries must be initialized.
        for i in 0..<num_joints {
            let current = lister.linear_joints[i].joint
            skeleton.joint_names_[i] = current.name
        }

        // Transfers sorted joints hierarchy to the new skeleton.
        for i in 0..<num_joints {
            skeleton.joint_parents_[i] = lister.linear_joints[i].parent
        }

        // Transfers t-poses.
        let w_axis = OZZFloat4.w_axis()
        let zero = OZZFloat4.zero()
        let one = OZZFloat4.one()

        for i in 0..<skeleton.num_soa_joints() {
            var translations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            var scales = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            var rotations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            for j in 0..<4 {
                if (i * 4 + j < num_joints) {
                    let src_joint = lister.linear_joints[i * 4 + j].joint
                    translations[j] = OZZFloat4.load3PtrU(with: &src_joint.transform.translation.x)
                    rotations[j] = OZZFloat4.normalizeSafe4(with: OZZFloat4.loadPtrU(with: &src_joint.transform.rotation.x), w_axis)
                    scales[j] = OZZFloat4.load3PtrU(with: &src_joint.transform.scale.x)
                } else {
                    translations[j] = zero
                    rotations[j] = w_axis
                    scales[j] = one
                }
            }
            // Fills the SoaTransform structure.
            OZZFloat4.transpose4x3(with: translations, &skeleton.joint_bind_poses_[i].translation.x)
            OZZFloat4.transpose4x4(with: rotations, &skeleton.joint_bind_poses_[i].rotation.x)
            OZZFloat4.transpose4x3(with: scales, &skeleton.joint_bind_poses_[i].scale.x)
        }

        return skeleton  // Success.
    }
}

// Stores each traversed joint in a vector.
struct JointLister: SkeletonVisitor {
    init(_ _num_joints: Int) {
        linear_joints.reserveCapacity(_num_joints)
    }

    mutating func visitor(_ _current: RawSkeleton.Joint, _ _parent: RawSkeleton.Joint?) {
        // Looks for the "lister" parent.
        var parent = Skeleton.Constants.kNoParent.rawValue
        if (_parent != nil) {
            // Start searching from the last joint.
            for j in stride(from: linear_joints.count - 1, to: 0, by: -1) {
                if (linear_joints[j].joint === _parent) {
                    parent = j
                    break
                }
            }
            assert(parent >= 0)
        }
        let listed = Joint(joint: _current, parent: parent)
        linear_joints.append(listed)
    }

    struct Joint {
        var joint: RawSkeleton.Joint
        var parent: Int
    }

    // Array of joints in the traversed DAG order.
    var linear_joints: [Joint] = []
}
