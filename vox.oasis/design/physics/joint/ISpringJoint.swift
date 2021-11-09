//
//  ISpringJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol ISpringJoint: IJoint {
    func setMinDistance(_ distance: Float)

    func setMaxDistance(_ distance: Float)

    func setTolerance(_ tolerance: Float)

    func setStiffness(_ stiffness: Float)

    func setDamping(_ damping: Float)

    func setDistanceJointFlag(_ flag: Int, _ value: Bool)
}
