//
//  PhysXSpringJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXSpringJoint: PhysXJoint, ISpringJoint {
    func setMinDistance(_ distance: Float) {
        (_pxJoint as! CPxDistanceJoint).setMinDistance(distance)
    }

    func setMaxDistance(_ distance: Float) {
        (_pxJoint as! CPxDistanceJoint).setMaxDistance(distance)
    }

    func setTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxDistanceJoint).setTolerance(tolerance)
    }

    func setStiffness(_ stiffness: Float) {
        (_pxJoint as! CPxDistanceJoint).setStiffness(stiffness)
    }

    func setDamping(_ damping: Float) {
        (_pxJoint as! CPxDistanceJoint).setDamping(damping)
    }

    func setDistanceJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxDistanceJoint).setDistanceJointFlag(CPxDistanceJointFlag(UInt32(flag)), value)
    }
}
