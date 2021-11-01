//
//  PhysXCollider.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// Abstract class of physical collider.
class PhysXCollider: ICollider {
    internal var _pxActor: CPxRigidActor!

    func addShape(_ shape: IColliderShape) {
        _pxActor.attachShape(with: (shape as! PhysXColliderShape)._pxShape)
    }

    func removeShape(_ shape: IColliderShape) {
        _pxActor.detachShape(with: (shape as! PhysXColliderShape)._pxShape)
    }

    func setWorldTransform(_ position: Vector3, _ rotation: Quaternion) {
        _pxActor.setGlobalPose(position.elements, rotation: rotation.elements)
    }

    func getWorldTransform(_ outPosition: Vector3, _ outRotation: Quaternion) {
        _pxActor.getGlobalPose(&outPosition.elements, rotation: &outRotation.normalize().elements);
    }
}
