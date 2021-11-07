//
//  soa_skeleton.swift
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
// packed as an array of parent joint indices (16 bits), stored in depth-first
// order. This is enough to traverse the whole joint hierarchy. See
// IterateJointsDF() from skeleton_utils.h that implements a depth-first
// traversal utility.
class SoaSkeleton {
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

    // Buffers below store joint information in joining depth first order. Their
    // size is equal to the number of joints of the skeleton.

    // Bind pose of every joint in local space.
    internal var joint_bind_poses_: ArraySlice<SoaTransform> = ArraySlice()

    // Array of joint parent indexes.
    internal var joint_parents_: ArraySlice<Int> = ArraySlice()

    // Stores the name of every joint in an array of c-strings.
    internal var joint_names_: ArraySlice<String> = ArraySlice()

    // Returns the number of joints of *this skeleton.
    func num_joints() -> Int {
        joint_parents_.count
    }

    // Returns the number of soa elements matching the number of joints of *this
    // skeleton. This value is useful to allocate SoA runtime data structures.
    func num_soa_joints() -> Int {
        (num_joints() + 3) / 4
    }

    // Returns joint's bind poses. Bind poses are stored in soa format.
    func joint_bind_poses() -> ArraySlice<SoaTransform> {
        joint_bind_poses_
    }

    // Returns joint's parent indices range.
    func joint_parents() -> ArraySlice<Int> {
        joint_parents_
    }

    // Returns joint's name collection.
    func joint_names() -> ArraySlice<String> {
        joint_names_[...]
    }

    // Internal allocation/deallocation function.
    // Allocate returns the beginning of the contiguous buffer of names.
    internal func allocate(_ _num_joints: Int) {
        assert(joint_bind_poses_.count == 0 && joint_names_.count == 0 &&
                joint_parents_.count == 0)

        // Early out if no joint.
        if (_num_joints == 0) {
            return
        }

        // Bind poses have SoA format
        let num_soa_joints = (_num_joints + 3) / 4

        // Serves larger alignment values first.
        // Bind pose first, biggest alignment.
        joint_bind_poses_ = [SoaTransform](repeating: SoaTransform.identity(), count: num_soa_joints)[...]

        // Then names array, second biggest alignment.
        joint_names_ = [String](repeating: "", count: _num_joints)[...]

        // Parents, third biggest alignment.
        joint_parents_ = [Int](repeating: 0, count: _num_joints)[...]
    }
    
    func load(_ filename:String) {
        guard let assetUrl = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Model: \(filename) not found")
        }
        
        let loader = SoaSkeletonLoader()
        loader.loadSkeleton(assetUrl.path)
        
        let n_name = loader.numberOfNames()
        var names = [String](repeating: "", count: n_name)
        for i in 0..<n_name {
            names[i] = loader.name(with: i)
        }
        joint_names_ = names[...]
        
        let n_parents = loader.numberOfParents()
        var parents = [Int](repeating: -1, count: n_parents)
        for i in 0..<n_parents {
            loader.parent(with: i, &parents[i])
        }
        joint_parents_ = parents[...]
        
        let n_poses = loader.numberOfBindPose()
        var poses = [SoaTransform](repeating: SoaTransform.identity(), count: n_poses)
        for i in 0..<n_poses {
            loader.pose(with: i, &poses[i])
        }
        joint_bind_poses_ = poses[...]
    }
}
