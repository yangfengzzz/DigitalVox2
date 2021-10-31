//
//  skeleton_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Get bind-pose of a skeleton joint.
func GetJointLocalBindPose(_skeleton: Skeleton, _joint: Int) -> VecTransform {
    guard _joint >= 0 && _joint < _skeleton.num_joints() else {
        fatalError("Joint index out of range.")
    }


    var soa_transform = _skeleton.joint_bind_poses()[_joint / 4]

    // Transpose SoA data to AoS.
    // TODO: Maybe have problem
    var translations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    OZZFloat4.transpose3x4(with: &soa_transform.translation.x, &translations)
    var rotations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    OZZFloat4.transpose4x4(with: &soa_transform.rotation.x, &rotations)
    var scales = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    OZZFloat4.transpose3x4(with: &soa_transform.scale.x, &scales)

    // Stores to the Transform object.
    var bind_pose = VecTransform.identity()
    let offset = _joint % 4
    OZZFloat4.store3PtrU(with: translations[offset], &bind_pose.translation.x)
    OZZFloat4.storePtrU(with: rotations[offset], &bind_pose.rotation.x)
    OZZFloat4.store3PtrU(with: scales[offset], &bind_pose.scale.x)

    return bind_pose
}

// Test if a joint is a leaf. _joint number must be in range [0, num joints].
// "_joint" is a leaf if it's the last joint, or next joint's parent isn't
// "_joint".
func IsLeaf(_skeleton: Skeleton, _joint: Int) -> Bool {
    let num_joints = _skeleton.num_joints()
    guard _joint >= 0 && _joint < num_joints else {
        fatalError("_joint index out of range")
    }
    let parents = _skeleton.joint_parents()
    let next = _joint + 1
    return next == num_joints || parents[next] != _joint
}

protocol JointVisitor {
    func visitor(_ _current: Int, _ _parent: Int)
}

// Applies a specified functor to each joint in a depth-first order.
// _Fct is of type void(int _current, int _parent) where the first argument is
// the child of the second argument. _parent is kNoParent if the
// _current joint is a root. _from indicates the joint from which the joint
// hierarchy traversal begins. Use Skeleton::kNoParent to traverse the
// whole hierarchy, in case there are multiple roots.
func IterateJointsDF<_Fct: JointVisitor>(_skeleton: Skeleton, _fct: _Fct,
                                         _from: Int = Skeleton.Constants.kNoParent.rawValue) -> _Fct {
    let parents = _skeleton.joint_parents()
    let num_joints = _skeleton.num_joints()

    var i = _from < 0 ? 0 : _from
    var process = i < num_joints
    while process {
        _fct.visitor(i, parents[i])
        i += 1
        process = i < num_joints && parents[i] >= _from
    }

    return _fct
}

// Applies a specified functor to each joint in a reverse (from leaves to root)
// depth-first order. _Fct is of type void(int _current, int _parent) where the
// first argument is the child of the second argument. _parent is kNoParent if
// the _current joint is a root.
func IterateJointsDFReverse<_Fct: JointVisitor>(_skeleton: Skeleton, _fct: _Fct) -> _Fct {
    let parents = _skeleton.joint_parents()
    for i in 0..<_skeleton.num_joints() {
        _fct.visitor(i, parents[i])
    }
    return _fct
}
