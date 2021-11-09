//
//  Joint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class Joint: Component {
    internal var _nativeJoint: IJoint!

    func setActors(_ actor0: Collider, _ actor1: Collider) {
        _nativeJoint.setActors(actor0._nativeCollider, actor1._nativeCollider)
    }

    func setLocalPose(_ actor: Int, _ position: Vector3, _ rotation: Quaternion) {
        _nativeJoint.setLocalPose(actor, position, rotation)
    }

    func setBreakForce(_ force: Float, _ torque: Float) {
        _nativeJoint.setBreakForce(force, torque)
    }

    func setConstraintFlag(_ flags: Int, _ value: Bool) {
        _nativeJoint.setConstraintFlag(flags, value)
    }

    func setInvMassScale0(_ invMassScale: Float) {
        _nativeJoint.setInvMassScale0(invMassScale)
    }

    func setInvInertiaScale0(_ invInertiaScale: Float) {
        _nativeJoint.setInvInertiaScale0(invInertiaScale)
    }

    func setInvMassScale1(_ invMassScale: Float) {
        _nativeJoint.setInvMassScale1(invMassScale)
    }

    func setInvInertiaScale1(_ invInertiaScale: Float) {
        _nativeJoint.setInvInertiaScale1(invInertiaScale)
    }
}
