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
            _ frictionCombine: Float,
            _ bounceCombine: Float
    ) -> IPhysicsMaterial {
        LitePhysicsMaterial(staticFriction, dynamicFriction, bounciness, frictionCombine, bounceCombine)
    }

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
}
