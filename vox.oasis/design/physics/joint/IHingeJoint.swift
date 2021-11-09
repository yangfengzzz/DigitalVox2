//
//  IHingeJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IHingeJoint: IJoint {
    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float)

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float)

    func setDriveVelocity(_ velocity: Float)

    func setDriveForceLimit(_ limit: Float)

    func setDriveGearRatio(_ ratio: Float)

    func setRevoluteJointFlag(_ flag: Int, _ value: Bool)

    func setProjectionLinearTolerance(_ tolerance: Float)

    func setProjectionAngularTolerance(_ tolerance: Float)
}
