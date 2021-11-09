//
//  PhysXJoint.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXJoint: IJoint {
    internal var _pxJoint: CPxJoint!

    func setActors(_ actor0: ICollider?, _ actor1: ICollider?) {
        _pxJoint.setActors((actor0 as? PhysXCollider)?._pxActor, (actor1 as? PhysXCollider)?._pxActor)
    }

    func setLocalPose(_ actor: Int, _ position: Vector3, _ rotation: Quaternion) {
        _pxJoint.setLocalPose(CPxJointActorIndex(UInt32(actor)), position.elements, rotation: rotation.elements)
    }

    func setBreakForce(_ force: Float, _ torque: Float) {
        _pxJoint.setBreakForce(force, torque)
    }

    func setConstraintFlag(_ flags: Int, _ value: Bool) {
        _pxJoint.setConstraintFlag(CPxConstraintFlag(UInt32(flags)), value)
    }

    func setInvMassScale0(_ invMassScale: Float) {
        _pxJoint.setInvMassScale0(invMassScale)
    }

    func setInvInertiaScale0(_ invInertiaScale: Float) {
        _pxJoint.setInvInertiaScale0(invInertiaScale)
    }

    func setInvMassScale1(_ invMassScale: Float) {
        _pxJoint.setInvMassScale1(invMassScale)
    }

    func setInvInertiaScale1(_ invInertiaScale: Float) {
        _pxJoint.setInvInertiaScale1(invInertiaScale)
    }
}
