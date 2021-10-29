//
//  PhysXPhysicsManager.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// A manager is a collection of bodies and constraints which can interact.
class PhysXPhysicsManager: IPhysicsManager {
    private static var _tempPosition: Vector3 = Vector3()
    private static var _tempNormal: Vector3 = Vector3()

    private var _pxScene: CPxScene

    init(_ onContactEnter: ((Int, Int) -> Void)?,
         _ onContactExit: ((Int, Int) -> Void)?,
         _ onContactStay: ((Int, Int) -> Void)?,
         _ onTriggerEnter: ((Int, Int) -> Void)?,
         _ onTriggerExit: ((Int, Int) -> Void)?,
         _ onTriggerStay: ((Int, Int) -> Void)?) {
        _pxScene = PhysXPhysics._pxPhysics.createScene({ (obj1: CPxShape?, obj2: CPxShape?) in },
                onContactExit: { (obj1: CPxShape?, obj2: CPxShape?) in },
                onContactStay: { (obj1: CPxShape?, obj2: CPxShape?) in },
                onTriggerEnter: { (obj1: CPxShape?, obj2: CPxShape?) in },
                onTriggerExit: { (obj1: CPxShape?, obj2: CPxShape?) in })
    }

    func setGravity(_ gravity: Vector3) {
        fatalError()
    }

    func addColliderShape(_ colliderShape: IColliderShape) {
        fatalError()
    }

    func removeColliderShape(_ colliderShape: IColliderShape) {
        fatalError()
    }

    func addCollider(_ collider: ICollider) {
        fatalError()
    }

    func removeCollider(_ collider: ICollider) {
        fatalError()
    }

    func update(_ elapsedTime: Float) {
        fatalError()
    }

    func raycast(_ ray: Ray, _ distance: Float,
                 _ outHitResult: ((Int, Float, Vector3, Vector3) -> Void)?) -> Bool {
        fatalError()
    }
}
