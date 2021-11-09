//
//  ITranslationalJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ITranslationalJoint: IJoint {
    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float)

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float)

    func setPrismaticJointFlag(_ flag: Int, _ value: Bool)

    func setProjectionLinearTolerance(_ tolerance: Float)

    func setProjectionAngularTolerance(_ tolerance: Float)
}
