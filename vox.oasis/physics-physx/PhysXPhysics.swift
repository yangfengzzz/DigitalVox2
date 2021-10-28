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
        fatalError()
    }

    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> IDynamicCollider {
        fatalError()
    }

    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> IStaticCollider {
        fatalError()
    }

    static func createPhysicsMaterial(_ staticFriction: Float,
                                      _ dynamicFriction: Float,
                                      _ bounciness: Float,
                                      _ frictionCombine: Int,
                                      _ bounceCombine: Int) -> IPhysicsMaterial {
        fatalError()
    }

    static func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3,
                                       _ material: IPhysicsMaterial) -> IBoxColliderShape {
        fatalError()
    }

    static func createSphereColliderShape(_ uniqueID: Int, _ radius: Float,
                                          _ material: IPhysicsMaterial) -> ISphereColliderShape {
        fatalError()
    }

    static func createPlaneColliderShape(_ uniqueID: Int,
                                         _ material: IPhysicsMaterial) -> IPlaneColliderShape {
        fatalError()
    }

    static func createCapsuleColliderShape(_ uniqueID: Int, _ radius: Float, _ height: Float,
                                           _ material: IPhysicsMaterial) -> ICapsuleColliderShape {
        fatalError()
    }
    
    private static func _init() {
        _pxPhysics = CPxPhysics()
    }
}
