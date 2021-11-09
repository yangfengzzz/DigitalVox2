//
//  PhysXFixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXFixedJoint: PhysXJoint, IFixedJoint {
    init(_ actor0: PhysXCollider, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createFixedJoint(
                actor0._pxActor, position0.elements, rotation0.elements,
                actor1._pxActor, position1.elements, rotation1.elements)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
