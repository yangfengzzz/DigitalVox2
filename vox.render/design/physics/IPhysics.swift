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
    func createPhysicsManager(onContactEnter: ((Float, Float) -> Void)?,
                              onContactExit: ((Float, Float) -> Void)?,
                              onContactStay: ((Float, Float) -> Void)?,
                              onTriggerEnter: ((Float, Float) -> Void)?,
                              onTriggerExit: ((Float, Float) -> Void)?,
                              onTriggerStay: ((Float, Float) -> Void)?) -> IPhysicsManager

    /// Create dynamic collider.
    func createDynamicCollider(position: Vector3, rotation: Quaternion) -> IDynamicCollider

    /// Create static collider.
    func createStaticCollider(position: Vector3, rotation: Quaternion) -> IStaticCollider

    /// Create physics material.
    func createPhysicsMaterial(staticFriction: Float,
                               dynamicFriction: Float,
                               bounciness: Float,
                               frictionCombine: Float,
                               bounceCombine: Float) -> IPhysicsMaterial

    /// Create box collider shape.
    func createBoxColliderShape(uniqueID: Int, size: Vector3, material: IPhysicsMaterial) -> IBoxColliderShape

    /// Create sphere collider shape.
    func createSphereColliderShape(uniqueID: Int, radius: Float, material: IPhysicsMaterial) -> ISphereColliderShape

    /// Create plane collider shape.
    func createPlaneColliderShape(uniqueID: Int, material: IPhysicsMaterial) -> IPlaneColliderShape

    /// Create capsule collider shape.
    func createCapsuleColliderShape(uniqueID: Int,
                                    radius: Float,
                                    height: Float,
                                    material: IPhysicsMaterial) -> ICapsuleColliderShape
}
