//
//  IBoxCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

protocol IBoxCharacterControllerDesc: ICharacterControllerDesc {
    func setToDefault()
    func setHalfHeight(_ halfHeight: Float)
    func setHalfSideExtent(_ halfSideExtent: Float)
    func setHalfForwardExtent(_ halfForwardExtent: Float)

    func setPosition(_ position: Vector3)
    func setUpDirection(_ upDirection: Vector3)
    func setSlopeLimit(_ slopeLimit: Float)
    func setInvisibleWallHeight(_ invisibleWallHeight: Float)
    func setMaxJumpHeight(_ maxJumpHeight: Float)
    func setContactOffset(_ contactOffset: Float)
    func setStepOffset(_ stepOffset: Float)
    func setDensity(_ density: Float)
    func setScaleCoeff(_ scaleCoeff: Float)
    func setVolumeGrowth(_ volumeGrowth: Float)
    func setNonWalkableMode(_ nonWalkableMode: Int)
    func setMaterial(_ material: IPhysicsMaterial?)
    func setRegisterDeletionListener(_ registerDeletionListener: Bool)
    func setControllerBehaviorCallback(getShapeBehaviorFlags: @escaping (IColliderShape, ICollider) -> UInt8,
                                       getControllerBehaviorFlags: @escaping (ICharacterController) -> UInt8,
                                       getObstacleBehaviorFlags: @escaping (IPhysicsObstacle) -> UInt8)
}
