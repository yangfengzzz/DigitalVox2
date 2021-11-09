//
//  IJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IJoint {
    func setActors(_ actor0: ICollider, _ actor1: ICollider)

    func setLocalPose(_ actor: Int, _ position: Vector3, _ rotation: Quaternion)

    func setBreakForce(_ force: Float, _ torque: Float)

    func setConstraintFlag(_ flags: Int, _ value: Bool)

    func setInvMassScale0(_ invMassScale: Float)

    func setInvInertiaScale0(_ invInertiaScale: Float)

    func setInvMassScale1(_ invMassScale: Float)

    func setInvInertiaScale1(_ invInertiaScale: Float)
}
