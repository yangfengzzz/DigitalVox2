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
    class Joint {
        // Children joints.
        var children: [Joint] = []

        // The name of the joint.
        var name: String = ""

        // Joint bind pose transformation in local space.
        var transform = VecTransform.identity()
    }

    // Declares the skeleton's roots. Can be empty if the skeleton has no joint.
    var roots: [Joint] = []

    // Tests for *this validity.
    // Returns true on success or false on failure if the number of joints exceeds
    // ozz::Skeleton::kMaxJoints.
    func Validate() -> Bool {
        if (num_joints() > SoaSkeleton.Constants.kMaxJoints.rawValue) {
            return false
        }
        return true
    }

    // Returns the number of joints of *this animation.
    // This function is not constant time as it iterates the hierarchy of joints
    // and counts them.
    func num_joints() -> Int {
        struct JointCounter: SkeletonVisitor {
            var num_joints: Int = 0

            mutating func visitor(_ _current: RawSkeleton.Joint, _ _parent: RawSkeleton.Joint?) {
                num_joints += 1
            }
        }

        var counter = JointCounter()
        IterateJointsDF(self, &counter)
        return counter.num_joints
    }
}

protocol SkeletonVisitor {
    mutating func visitor(_ _current: RawSkeleton.Joint, _ _parent: RawSkeleton.Joint?)
}

// Internal function used to iterate through joint hierarchy depth-first.
func _IterHierarchyRecurseDF<_Fct: SkeletonVisitor>(_ _children: [RawSkeleton.Joint],
                                                    _ _parent: RawSkeleton.Joint?,
                                                    _ _fct: inout _Fct) {
    for i in 0..<_children.count {
        let current = _children[i]
        _fct.visitor(current, _parent)
        _IterHierarchyRecurseDF(current.children, current, &_fct)
    }
}

// Internal function used to iterate through joint hierarchy breadth-first.
func _IterHierarchyRecurseBF<_Fct: SkeletonVisitor>(_ _children: [RawSkeleton.Joint],
                                                    _ _parent: RawSkeleton.Joint?,
                                                    _ _fct: inout _Fct) {
    for i in 0..<_children.count {
        let current = _children[i]
        _fct.visitor(current, _parent)
    }

    for i in 0..<_children.count {
        let current = _children[i]
        _IterHierarchyRecurseBF(current.children, current, &_fct)
    }
}

// Applies a specified functor to each joint in a depth-first order.
// _Fct is of type void(const Joint& _current, const Joint* _parent) where the
// first argument is the child of the second argument. _parent is null if the
// _current joint is the root.
func IterateJointsDF<_Fct: SkeletonVisitor>(_ _skeleton: RawSkeleton,
                                            _ _fct: inout _Fct) {
    _IterHierarchyRecurseDF(_skeleton.roots, nil, &_fct)
}

// Applies a specified functor to each joint in a breadth-first order.
// _Fct is of type void(const Joint& _current, const Joint* _parent) where the
// first argument is the child of the second argument. _parent is null if the
// _current joint is the root.
func IterateJointsBF<_Fct: SkeletonVisitor>(_ _skeleton: RawSkeleton,
                                            _ _fct: inout _Fct) {
    _IterHierarchyRecurseBF(_skeleton.roots, nil, &_fct)
}
