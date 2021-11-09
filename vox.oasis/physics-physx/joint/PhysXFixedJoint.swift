//
//  PhysXFixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXFixedJoint: PhysXJoint, IFixedJoint {
    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
