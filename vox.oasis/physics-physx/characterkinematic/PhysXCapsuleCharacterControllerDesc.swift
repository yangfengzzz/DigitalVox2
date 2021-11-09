//
//  PhysXCapsuleCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

class PhysXCapsuleCharacterControllerDesc: PhysXCharacterControllerDesc, ICapsuleCharacterControllerDesc {
    override init() {
        super.init()
        _pxControllerDesc = CPxCapsuleControllerDesc()
    }

    func setToDefault() {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).setToDefault()
    }

    func setRadius(_ radius: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).radius = radius
    }

    func setHeight(_ height: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).height = height
    }

    func setClimbingMode(_ climbingMode: Int) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).climbingMode = CPxCapsuleClimbingMode(UInt32(climbingMode))
    }

    func setPosition(_ position: Vector3) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).position = position.elements
    }

    func setUpDirection(_ upDirection: Vector3) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).upDirection = upDirection.elements
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).slopeLimit = slopeLimit
    }

    func setInvisibleWallHeight(_ invisibleWallHeight: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).invisibleWallHeight = invisibleWallHeight
    }

    func setMaxJumpHeight(_ maxJumpHeight: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).maxJumpHeight = maxJumpHeight
    }

    func setContactOffset(_ contactOffset: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).contactOffset = contactOffset
    }

    func setStepOffset(_ stepOffset: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).stepOffset = stepOffset
    }

    func setDensity(_ density: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).density = density
    }

    func setScaleCoeff(_ scaleCoeff: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).scaleCoeff = scaleCoeff
    }

    func setVolumeGrowth(_ volumeGrowth: Float) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).volumeGrowth = volumeGrowth
    }

    func setNonWalkableMode(_ nonWalkableMode: Int) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).nonWalkableMode = CPxControllerNonWalkableMode(UInt32(nonWalkableMode))
    }

    func setMaterial(_ material: IPhysicsMaterial) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).material = (material as! PhysXPhysicsMaterial)._pxMaterial
    }

    func setRegisterDeletionListener(_ registerDeletionListener: Bool) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).registerDeletionListener = registerDeletionListener
    }

    func setControllerBehaviorCallback(getShapeBehaviorFlags: @escaping (IColliderShape, ICollider) -> UInt8,
                                       getControllerBehaviorFlags: @escaping (ICharacterController) -> UInt8,
                                       getObstacleBehaviorFlags: @escaping (IPhysicsObstacle) -> UInt8) {
        (_pxControllerDesc as! CPxCapsuleControllerDesc).setControllerBehaviorCallback({ (shape: CPxShape, actor: CPxRigidActor) in
            let s = PhysXColliderShape()
            s._pxShape = shape
            let a = PhysXCollider()
            a._pxActor = actor
            return getShapeBehaviorFlags(s, a)
        }, { (controller: CPxController) in
            let c = PhysXCharacterController()
            c._pxController = controller
            return getControllerBehaviorFlags(c)
        }, { (obstacle: CPxObstacle) in
            let o = PhysXObstacle()
            o._pxObstacle = obstacle
            return getObstacleBehaviorFlags(o)
        })
    }
}
