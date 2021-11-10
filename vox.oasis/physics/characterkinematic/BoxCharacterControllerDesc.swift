//
//  BoxCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class BoxCharacterControllerDesc {
    internal var _nativeCharacterControllerDesc: IBoxCharacterControllerDesc

    init() {
        _nativeCharacterControllerDesc = PhysicsManager._nativePhysics.createBoxCharacterControllerDesc()
    }

    func setToDefault() {
        _nativeCharacterControllerDesc.setToDefault()
    }

    func setHalfHeight(_ halfHeight: Float) {
        _nativeCharacterControllerDesc.setHalfHeight(halfHeight)
    }

    func setHalfSideExtent(_ halfSideExtent: Float) {
        _nativeCharacterControllerDesc.setHalfSideExtent(halfSideExtent)
    }

    func setHalfForwardExtent(_ halfForwardExtent: Float) {
        _nativeCharacterControllerDesc.setHalfForwardExtent(halfForwardExtent)
    }

    func setPosition(_ position: Vector3) {
        _nativeCharacterControllerDesc.setPosition(position)
    }

    func setUpDirection(_ upDirection: Vector3) {
        _nativeCharacterControllerDesc.setUpDirection(upDirection)
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        _nativeCharacterControllerDesc.setSlopeLimit(slopeLimit)
    }

    func setInvisibleWallHeight(_ invisibleWallHeight: Float) {
        _nativeCharacterControllerDesc.setInvisibleWallHeight(invisibleWallHeight)
    }

    func setMaxJumpHeight(_ maxJumpHeight: Float) {
        _nativeCharacterControllerDesc.setMaxJumpHeight(maxJumpHeight)
    }

    func setContactOffset(_ contactOffset: Float) {
        _nativeCharacterControllerDesc.setContactOffset(contactOffset)
    }

    func setStepOffset(_ stepOffset: Float) {
        _nativeCharacterControllerDesc.setStepOffset(stepOffset)
    }

    func setDensity(_ density: Float) {
        _nativeCharacterControllerDesc.setDensity(density)
    }

    func setScaleCoeff(_ scaleCoeff: Float) {
        _nativeCharacterControllerDesc.setScaleCoeff(scaleCoeff)
    }

    func setVolumeGrowth(_ volumeGrowth: Float) {
        _nativeCharacterControllerDesc.setVolumeGrowth(volumeGrowth)
    }

    func setNonWalkableMode(_ nonWalkableMode: Int) {
        _nativeCharacterControllerDesc.setNonWalkableMode(nonWalkableMode)
    }

    func setMaterial(_ material: PhysicsMaterial) {
        _nativeCharacterControllerDesc.setMaterial(material._nativeMaterial)
    }

    func setRegisterDeletionListener(_ registerDeletionListener: Bool) {
        _nativeCharacterControllerDesc.setRegisterDeletionListener(registerDeletionListener)
    }
}
