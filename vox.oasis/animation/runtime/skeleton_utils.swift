//
//  skeleton_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Get bind-pose of a skeleton joint.
func getJointLocalBindPose(_ _skeleton: SoaSkeleton, _ _joint: Int) -> VecTransform {
    guard _joint >= 0 && _joint < _skeleton.num_joints() else {
        fatalError("Joint index out of range.")
    }

    let soa_transform = _skeleton.joint_bind_poses()[_joint / 4]

    // Transpose SoA data to AoS.
    var translations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose3x4(soa_transform.translation, &translations)
    var rotations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose4x4(soa_transform.rotation, &rotations)
    var scales = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose3x4(soa_transform.scale, &scales)

    // Stores to the Transform object.
    var bind_pose = VecTransform.identity()
    let offset = _joint % 4
    var result:[Float] = [0, 0, 0, 0]
    store3PtrU(translations[offset], &result)
    bind_pose.translation = VecFloat3(result[0], result[1], result[2])
    storePtrU(rotations[offset], &result)
    bind_pose.rotation = VecQuaternion(result[0], result[1], result[2], result[3])
    store3PtrU(scales[offset], &result)
    bind_pose.scale = VecFloat3(result[0], result[1], result[2])

    return bind_pose
}

// Test if a joint is a leaf. _joint number must be in range [0, num joints].
// "_joint" is a leaf if it's the last joint, or next joint's parent isn't
// "_joint".
func isLeaf(_ _skeleton: SoaSkeleton, _ _joint: Int) -> Bool {
    let num_joints = _skeleton.num_joints()
    guard _joint >= 0 && _joint < num_joints else {
        fatalError("_joint index out of range")
    }
    let parents = _skeleton.joint_parents()
    let next = _joint + 1
    return next == num_joints || parents[next] != _joint
}

// Applies a specified functor to each joint in a depth-first order.
// _Fct is of type void(int _current, int _parent) where the first argument is
// the child of the second argument. _parent is kNoParent if the
// _current joint is a root. _from indicates the joint from which the joint
// hierarchy traversal begins. Use Skeleton::kNoParent to traverse the
// whole hierarchy, in case there are multiple roots.
func iterateJointsDF(_ _skeleton: SoaSkeleton, _ _fct: (Int, Int) -> Void,
                     _ _from: Int = SoaSkeleton.Constants.kNoParent.rawValue) {
    let parents = _skeleton.joint_parents()
    let num_joints = _skeleton.num_joints()

    var i = _from < 0 ? 0 : _from
    var process = i < num_joints
    while process {
        _fct(i, parents[i])
        i += 1
        process = i < num_joints && parents[i] >= _from
    }
}

// Applies a specified functor to each joint in a reverse (from leaves to root)
// depth-first order. _Fct is of type void(int _current, int _parent) where the
// first argument is the child of the second argument. _parent is kNoParent if
// the _current joint is a root.
func iterateJointsDFReverse(_ _skeleton: SoaSkeleton, _ _fct: (Int, Int) -> Void) {
    let parents = _skeleton.joint_parents()
    for i in 0..<_skeleton.num_joints() {
        _fct(i, parents[i])
    }
}
