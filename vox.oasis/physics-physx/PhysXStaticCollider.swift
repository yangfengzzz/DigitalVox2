//
//  PhysXStaticCollider.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// A static collider component that will not move.
/// - Remark: Mostly used for object which always stays at the same place and never moves around.
class PhysXStaticCollider: PhysXCollider, IStaticCollider {
    /// Initialize PhysX static actor.
    /// - Parameters:
    ///   - position: The global position
    ///   - rotation: The global rotation
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _pxActor = PhysXPhysics._pxPhysics.createRigidStatic(withPosition: position.elements,
                rotation: rotation.normalize().elements)
    }
}
