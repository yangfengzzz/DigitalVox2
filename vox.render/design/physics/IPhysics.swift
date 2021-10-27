//
//  IPhysics.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// The interface of physics creation.
protocol IPhysics {
    /// Create physics manager.
    func createPhysicsManager(_ onContactEnter: ((Float, Float) -> Void)?,
                              _ onContactExit: ((Float, Float) -> Void)?,
                              _ onContactStay: ((Float, Float) -> Void)?,
                              _ onTriggerEnter: ((Float, Float) -> Void)?,
                              _ onTriggerExit: ((Float, Float) -> Void)?,
                              _ onTriggerStay: ((Float, Float) -> Void)?) -> IPhysicsManager

    /// Create dynamic collider.
    func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> IDynamicCollider

    /// Create static collider.
    func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> IStaticCollider

    /// Create physics material.
    func createPhysicsMaterial(_ staticFriction: Float,
                               _ dynamicFriction: Float,
                               _ bounciness: Float,
                               _ frictionCombine: Float,
                               _ bounceCombine: Float) -> IPhysicsMaterial

    /// Create box collider shape.
    func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3, _ material: IPhysicsMaterial) -> IBoxColliderShape

    /// Create sphere collider shape.
    func createSphereColliderShape(_ uniqueID: Int, _ radius: Float, _ material: IPhysicsMaterial) -> ISphereColliderShape

    /// Create plane collider shape.
    func createPlaneColliderShape(_ uniqueID: Int, _ material: IPhysicsMaterial) -> IPlaneColliderShape

    /// Create capsule collider shape.
    func createCapsuleColliderShape(_ uniqueID: Int,
                                    _ radius: Float,
                                    _ height: Float,
                                    _ material: IPhysicsMaterial) -> ICapsuleColliderShape
}
