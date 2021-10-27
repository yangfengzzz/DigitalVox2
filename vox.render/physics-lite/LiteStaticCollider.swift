//
//  LiteStaticCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// A static collider component that will not move.
/// - Remark: Mostly used for object which always stays at the same place and never moves around.
class LiteStaticCollider: LiteCollider, IStaticCollider {
    /// Initialize static actor.
    /// - Parameters:
    ///   - position: The global position
    ///   - rotation: The global rotation
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _transform.setPosition(x: position.x, y: position.y, z: position.z)
        _transform.setRotationQuaternion(x: rotation.x, y: rotation.y, z: rotation.z, w: rotation.w)
    }
}
