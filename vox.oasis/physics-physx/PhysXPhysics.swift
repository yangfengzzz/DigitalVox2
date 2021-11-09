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

    static func initialization() {
        _pxPhysics = CPxPhysics()
        _pxPhysics.initExtensions()
    }

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

    //MARK: - Collider Shape
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

    //MARK: - Joint
    static func createFixedJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> IFixedJoint {
        PhysXFixedJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    static func createHingeJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> IHingeJoint {
        PhysXHingeJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    static func createSphericalJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                     _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> ISphericalJoint {
        PhysXSphericalJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    static func createSpringJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                  _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> ISpringJoint {
        PhysXSpringJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    static func createTranslationalJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                         _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> ITranslationalJoint {
        PhysXTranslationalJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    static func createConfigurableJoint(_ actor0: ICollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                        _ actor1: ICollider?, _ position1: Vector3, _ rotation1: Quaternion) -> IConfigurableJoint {
        PhysXConfigurableJoint((actor0 as? PhysXCollider ?? nil), position0, rotation0, (actor1 as! PhysXCollider), position1, rotation1)
    }

    //MARK: - Character Controller
    static func createBoxCharacterControllerDesc() -> IBoxCharacterControllerDesc {
        PhysXBoxCharacterControllerDesc()
    }

    static func createCapsuleCharacterControllerDesc() -> ICapsuleCharacterControllerDesc {
        PhysXCapsuleCharacterControllerDesc()
    }

    static func createBoxObstacle() -> IPhysicsBoxObstacle {
        PhysXBoxObstacle()
    }

    static func createCapsuleObstacle() -> IPhysicsCapsuleObstacle {
        PhysXCapsuleObstacle()
    }
}
