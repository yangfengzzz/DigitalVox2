//
//  FixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class FixedJoint: Joint {
    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_nativeJoint as! IFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_nativeJoint as! IFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
