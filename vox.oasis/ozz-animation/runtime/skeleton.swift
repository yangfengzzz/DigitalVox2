//
//  skeleton.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// This runtime skeleton data structure provides a const-only access to joint
// hierarchy, joint names and bind-pose. This structure is filled by the
// SkeletonBuilder and can be serialize/deserialized.
// Joint names, bind-poses and hierarchy information are all stored in separate
// arrays of data (as opposed to joint structures for the RawSkeleton), in order
// to closely match with the way runtime algorithms use them. Joint hierarchy is
// packed as an array of parent jont indices (16 bits), stored in depth-first
// order. This is enough to traverse the whole joint hierarchy. See
// IterateJointsDF() from skeleton_utils.h that implements a depth-first
// traversal utility.
class Skeleton {
    // Defines Skeleton constant values.
    enum Constants: Int {
        // Defines the maximum number of joints.
        // This is limited in order to control the number of bits required to store
        // a joint index. Limiting the number of joints also helps handling worst
        // size cases, like when it is required to allocate an array of joints on
        // the stack.
        case kMaxJoints = 1024

        // Defines the maximum number of SoA elements required to store the maximum
        // number of joints.
        case kMaxSoAJoints = 256

        // Defines the index of the parent of the root joint (which has no parent in
        // fact).
        case kNoParent = -1
    }
    
    // Buffers below store joint informations in joing depth first order. Their
    // size is equal to the number of joints of the skeleton.

    // Bind pose of every joint in local space.
    private var joint_bind_poses_:[SoaTransform] = []

    // Array of joint parent indexes.
    private var joint_parents_:[Int] = []
    
    // Stores the name of every joint in an array of c-strings.
    private var joint_names_:[String] = []
}
