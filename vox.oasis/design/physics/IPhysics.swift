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

    //MARK: - Collider Shape
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

    //MARK: - Joint
    static func createFixedJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IFixedJoint

    static func createHingeJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IHingeJoint

    static func createSphericalJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                     _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ISphericalJoint

    static func createSpringJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                  _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ISpringJoint

    static func createTranslationalJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                         _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ITranslationalJoint

    static func createConfigurableJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                        _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IConfigurableJoint
}
