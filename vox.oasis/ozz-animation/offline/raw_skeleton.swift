//
//  raw_skeleton.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Off-line skeleton type.
// This skeleton type is not intended to be used in run time. It is used to
// define the offline skeleton object that can be converted to the runtime
// skeleton using the SkeletonBuilder. This skeleton structure exposes joints'
// hierarchy. A joint is defined with a name, a transformation (its bind pose),
// and its children. Children are exposed as a public std::vector of joints.
// This same type is used for skeleton roots, also exposed from the public API.
// The public API exposed through std:vector's of joints can be used freely with
// the only restriction that the total number of joints does not exceed
// Skeleton::kMaxJoints.
struct RawSkeleton {
    // Offline skeleton joint type.
    struct Joint {
        // Children joints.
        var children: [Joint]

        // The name of the joint.
        var name: String

        // Joint bind pose transformation in local space.
        var transform: VecTransform
    }

    // Declares the skeleton's roots. Can be empty if the skeleton has no joint.
    var roots: [Joint] = []

    // Tests for *this validity.
    // Returns true on success or false on failure if the number of joints exceeds
    // ozz::Skeleton::kMaxJoints.
    func Validate() -> Bool {
        fatalError()
    }

    // Returns the number of joints of *this animation.
    // This function is not constant time as it iterates the hierarchy of joints
    // and counts them.
    func num_joints() -> Int {
        fatalError()
    }
}
