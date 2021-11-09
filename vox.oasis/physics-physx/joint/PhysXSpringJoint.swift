//
//  PhysXSpringJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXSpringJoint: PhysXJoint, ISpringJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createDistanceJoint(
                actor0?._pxActor ?? nil, position0.elements, rotation0.elements,
                actor1?._pxActor ?? nil, position1.elements, rotation1.elements)
    }

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
