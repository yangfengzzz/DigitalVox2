//
//  StaticCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// A static collider component that will not move.
/// - Remark: Mostly used for object which always stays at the same place and never moves around.
class StaticCollider: Collider {
    required init(_ entity: Entity) {
        super.init(entity)
        let transform = entity.transform
        _nativeCollider = PhysicsManager._nativePhysics.createStaticCollider(
                transform!.worldPosition,
                transform!.worldRotationQuaternion
        )
    }
}
