//
//  PhysXPhysics.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// PhysX object creation.
class PhysXPhysics: IPhysics {
    /// Physx physics object
    internal static var _pxPhysics: CPxPhysics!

    static func createPhysicsManager(_ onContactEnter: ((Int, Int) -> Void)?,
                                     _ onContactExit: ((Int, Int) -> Void)?,
                                     _ onContactStay: ((Int, Int) -> Void)?,
                                     _ onTriggerEnter: ((Int, Int) -> Void)?,
                                     _ onTriggerExit: ((Int, Int) -> Void)?,
                                     _ onTriggerStay: ((Int, Int) -> Void)?) -> IPhysicsManager {
        PhysXPhysicsManager(onContactEnter, onContactExit, onContactStay,
                             onTriggerEnter, onTriggerExit, onTriggerStay)
    }

    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> IDynamicCollider {
        PhysXDynamicCollider(position, rotation)
    }

    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> IStaticCollider {
        PhysXStaticCollider(position, rotation)
    }

    static func createPhysicsMaterial(_ staticFriction: Float,
                                      _ dynamicFriction: Float,
                                      _ bounciness: Float,
                                      _ frictionCombine: Int,
                                      _ bounceCombine: Int) -> IPhysicsMaterial {
        PhysXPhysicsMaterial(staticFriction, dynamicFriction, bounciness,
                CombineMode(rawValue: frictionCombine)!,
                CombineMode(rawValue: bounceCombine)!)
    }

    static func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3,
                                       _ material: IPhysicsMaterial) -> IBoxColliderShape {
        PhysXBoxColliderShape(uniqueID, size, (material as! PhysXPhysicsMaterial))
    }

    static func createSphereColliderShape(_ uniqueID: Int, _ radius: Float,
                                          _ material: IPhysicsMaterial) -> ISphereColliderShape {
        PhysXSphereColliderShape(uniqueID, radius, (material as! PhysXPhysicsMaterial))
    }

    static func createPlaneColliderShape(_ uniqueID: Int,
                                         _ material: IPhysicsMaterial) -> IPlaneColliderShape {
        PhysXPlaneColliderShape(uniqueID, (material as! PhysXPhysicsMaterial))
    }

    static func createCapsuleColliderShape(_ uniqueID: Int, _ radius: Float, _ height: Float,
                                           _ material: IPhysicsMaterial) -> ICapsuleColliderShape {
        PhysXCapsuleColliderShape(uniqueID, radius, height, (material as! PhysXPhysicsMaterial))
    }

    static func initialization() {
        _pxPhysics = CPxPhysics()
        _pxPhysics.initExtensions()
    }
}
