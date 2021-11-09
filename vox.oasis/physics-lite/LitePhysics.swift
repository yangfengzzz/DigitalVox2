//
//  LitePhysics.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

class LitePhysics: IPhysics {
    static func createPhysicsManager(_ onContactEnter: ((Int, Int) -> Void)?,
                                     _ onContactExit: ((Int, Int) -> Void)?,
                                     _ onContactStay: ((Int, Int) -> Void)?,
                                     _ onTriggerEnter: ((Int, Int) -> Void)?,
                                     _ onTriggerExit: ((Int, Int) -> Void)?,
                                     _ onTriggerStay: ((Int, Int) -> Void)?) -> IPhysicsManager {
        LitePhysicsManager(
                onContactEnter,
                onContactExit,
                onContactStay,
                onTriggerEnter,
                onTriggerExit,
                onTriggerStay
        )
    }

    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> IStaticCollider {
        LiteStaticCollider(position, rotation)
    }


    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> IDynamicCollider {
        LiteDynamicCollider(position, rotation)
    }

    static func createPhysicsMaterial(
            _ staticFriction: Float,
            _ dynamicFriction: Float,
            _ bounciness: Float,
            _ frictionCombine: Int,
            _ bounceCombine: Int
    ) -> IPhysicsMaterial {
        LitePhysicsMaterial(staticFriction, dynamicFriction, bounciness, frictionCombine, bounceCombine)
    }

    //MARK: - Collider Shape
    static func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3, _ material: IPhysicsMaterial) -> IBoxColliderShape {
        LiteBoxColliderShape(uniqueID, size, material as! LitePhysicsMaterial)
    }

    static func createSphereColliderShape(
            _ uniqueID: Int,
            _ radius: Float,
            _ material: IPhysicsMaterial
    ) -> ISphereColliderShape {
        LiteSphereColliderShape(uniqueID, radius, material as! LitePhysicsMaterial)
    }

    static func createPlaneColliderShape(_ uniqueID: Int, _ material: IPhysicsMaterial) -> IPlaneColliderShape {
        fatalError("Physics-lite don't support PlaneColliderShape. Use Physics-PhysX instead!")
    }

    static func createCapsuleColliderShape(
            _ uniqueID: Int,
            _ radius: Float,
            _ height: Float,
            _ material: IPhysicsMaterial
    ) -> ICapsuleColliderShape {
        fatalError("Physics-lite don't support CapsuleColliderShape. Use Physics-PhysX instead!")
    }

    //MARK: - Joint
    static func createFixedJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IFixedJoint {
        fatalError("Physics-lite don't support FixedJoint. Use Physics-PhysX instead!")
    }

    static func createHingeJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IHingeJoint {
        fatalError("Physics-lite don't support HingeJoint. Use Physics-PhysX instead!")
    }

    static func createSphericalJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                     _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ISphericalJoint {
        fatalError("Physics-lite don't support SphericalJoint. Use Physics-PhysX instead!")
    }

    static func createSpringJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                  _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ISpringJoint {
        fatalError("Physics-lite don't support SpringJoint. Use Physics-PhysX instead!")
    }

    static func createTranslationalJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                         _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> ITranslationalJoint {
        fatalError("Physics-lite don't support TranslationalJoint. Use Physics-PhysX instead!")
    }

    static func createConfigurableJoint(_ actor0: ICollider, _ position0: Vector3, _ rotation0: Quaternion,
                                        _ actor1: ICollider, _ position1: Vector3, _ rotation1: Quaternion) -> IConfigurableJoint {
        fatalError("Physics-lite don't support ConfigurableJoint. Use Physics-PhysX instead!")
    }
}
