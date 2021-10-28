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
    static func createPhysicsManager(_ onContactEnter: ((Int, Int) -> Void)?,
                                     _ onContactExit: ((Int, Int) -> Void)?,
                                     _ onContactStay: ((Int, Int) -> Void)?,
                                     _ onTriggerEnter: ((Int, Int) -> Void)?,
                                     _ onTriggerExit: ((Int, Int) -> Void)?,
                                     _ onTriggerStay: ((Int, Int) -> Void)?) -> IPhysicsManager

    /// Create dynamic collider.
    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> IDynamicCollider

    /// Create static collider.
    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> IStaticCollider

    /// Create physics material.
    static func createPhysicsMaterial(_ staticFriction: Float,
                                      _ dynamicFriction: Float,
                                      _ bounciness: Float,
                                      _ frictionCombine: Int,
                                      _ bounceCombine: Int) -> IPhysicsMaterial

    /// Create box collider shape.
    static func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3, _ material: IPhysicsMaterial) -> IBoxColliderShape

    /// Create sphere collider shape.
    static func createSphereColliderShape(_ uniqueID: Int, _ radius: Float, _ material: IPhysicsMaterial) -> ISphereColliderShape

    /// Create plane collider shape.
    static func createPlaneColliderShape(_ uniqueID: Int, _ material: IPhysicsMaterial) -> IPlaneColliderShape

    /// Create capsule collider shape.
    static func createCapsuleColliderShape(_ uniqueID: Int,
                                           _ radius: Float,
                                           _ height: Float,
                                           _ material: IPhysicsMaterial) -> ICapsuleColliderShape
}
