//
//  SpringJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class SpringJoint: Joint {
    func setMinDistance(_ distance: Float) {
        (_nativeJoint as! ISpringJoint).setMinDistance(distance)
    }

    func setMaxDistance(_ distance: Float) {
        (_nativeJoint as! ISpringJoint).setMaxDistance(distance)
    }

    func setTolerance(_ tolerance: Float) {
        (_nativeJoint as! ISpringJoint).setTolerance(tolerance)
    }

    func setStiffness(_ stiffness: Float) {
        (_nativeJoint as! ISpringJoint).setStiffness(stiffness)
    }

    func setDamping(_ damping: Float) {
        (_nativeJoint as! ISpringJoint).setDamping(damping)
    }

    func setDistanceJointFlag(_ flag: Int, _ value: Bool) {
        (_nativeJoint as! ISpringJoint).setDistanceJointFlag(flag, value)
    }
}
