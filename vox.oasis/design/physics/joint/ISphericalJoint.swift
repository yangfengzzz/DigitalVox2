//
//  ISphericalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ISphericalJoint: IJoint {
    func setHardLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float)

    func setSoftLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float)

    func setSphericalJointFlag(_ flag: Int, _ value: Bool)

    func setProjectionLinearTolerance(_ tolerance: Float)
}
