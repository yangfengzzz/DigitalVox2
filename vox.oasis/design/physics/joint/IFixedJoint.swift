//
//  IFixedJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IFixedJoint: IJoint {
    func setProjectionLinearTolerance(_ tolerance: Float)

    func setProjectionAngularTolerance(_ tolerance: Float)
}
