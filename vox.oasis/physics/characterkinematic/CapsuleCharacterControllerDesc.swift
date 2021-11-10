//
//  CapsuleCharacterControllerDesc.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/10.
//

import Foundation

class CapsuleCharacterControllerDesc {
    internal var _nativeCharacterControllerDesc: ICapsuleCharacterControllerDesc

    private var _radius: Float = 0
    private var _height: Float = 0
    private var _climbingMode: CapsuleClimbingMode = .EASY

    private var _position = Vector3()
    private var _upDirection = Vector3(0, 1, 0)
    private var _slopeLimit: Float = 0
    private var _invisibleWallHeight: Float = 0
    private var _maxJumpHeight: Float = 0
    private var _contactOffset: Float = 0
    private var _stepOffset: Float = 0
    private var _density: Float = 0
    private var _scaleCoeff: Float = 0
    private var _volumeGrowth: Float = 0
    private var _nonWalkableMode: ControllerNonWalkableMode = .PREVENT_CLIMBING
    private var _material: PhysicsMaterial?
    private var _registerDeletionListener: Bool = false

    var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            _nativeCharacterControllerDesc.setRadius(newValue)
        }
    }

    var height: Float {
        get {
            _height
        }
        set {
            _height = newValue
            _nativeCharacterControllerDesc.setHeight(newValue)
        }
    }

    var climbingMode: CapsuleClimbingMode {
        get {
            _climbingMode
        }
        set {
            _climbingMode = newValue
            _nativeCharacterControllerDesc.setClimbingMode(newValue.rawValue)
        }
    }

    var position: Vector3 {
        get {
            _position
        }
        set {
            if _position !== newValue {
                newValue.cloneTo(target: _position)
                _nativeCharacterControllerDesc.setPosition(_position)
            }
        }
    }

    var upDirection: Vector3 {
        get {
            _upDirection
        }
        set {
            newValue.cloneTo(target: _upDirection)
            _nativeCharacterControllerDesc.setUpDirection(_upDirection)
        }
    }

    var slopeLimit: Float {
        get {
            _slopeLimit
        }
        set {
            _slopeLimit = newValue
            _nativeCharacterControllerDesc.setSlopeLimit(newValue)
        }
    }

    var invisibleWallHeight: Float {
        get {
            _invisibleWallHeight
        }
        set {
            _invisibleWallHeight = newValue
            _nativeCharacterControllerDesc.setInvisibleWallHeight(newValue)
        }
    }

    var maxJumpHeight: Float {
        get {
            _maxJumpHeight
        }
        set {
            _maxJumpHeight = newValue
            _nativeCharacterControllerDesc.setMaxJumpHeight(newValue)
        }
    }

    var contactOffset: Float {
        get {
            _contactOffset
        }
        set {
            _contactOffset = newValue
            _nativeCharacterControllerDesc.setContactOffset(newValue)
        }
    }

    var stepOffset: Float {
        get {
            _stepOffset
        }
        set {
            _stepOffset = newValue
            _nativeCharacterControllerDesc.setStepOffset(newValue)
        }
    }

    var density: Float {
        get {
            _density
        }
        set {
            _density = newValue
            _nativeCharacterControllerDesc.setDensity(newValue)
        }
    }

    var scaleCoeff: Float {
        get {
            _scaleCoeff
        }
        set {
            _scaleCoeff = newValue
            _nativeCharacterControllerDesc.setScaleCoeff(scaleCoeff)
        }
    }

    var volumeGrowth: Float {
        get {
            _volumeGrowth
        }
        set {
            _volumeGrowth = newValue
            _nativeCharacterControllerDesc.setVolumeGrowth(volumeGrowth)
        }
    }

    var nonWalkableMode: ControllerNonWalkableMode {
        get {
            _nonWalkableMode
        }
        set {
            _nonWalkableMode = newValue
            _nativeCharacterControllerDesc.setNonWalkableMode(newValue.rawValue)
        }
    }

    var material: PhysicsMaterial? {
        get {
            _material
        }
        set {
            _material = newValue
            _nativeCharacterControllerDesc.setMaterial(newValue?._nativeMaterial)
        }
    }

    var registerDeletionListener: Bool {
        get {
            _registerDeletionListener
        }
        set {
            _registerDeletionListener = newValue
            _nativeCharacterControllerDesc.setRegisterDeletionListener(newValue)
        }
    }

    init() {
        _nativeCharacterControllerDesc = PhysicsManager._nativePhysics.createCapsuleCharacterControllerDesc()
    }

    func setToDefault() {
        _radius = 0
        _height = 0
        _climbingMode = .EASY

        _ = _position.setValue(x: 0, y: 0, z: 0)
        _ = _upDirection.setValue(x: 0, y: 1, z: 0)
        _slopeLimit = 0
        _invisibleWallHeight = 0
        _maxJumpHeight = 0
        _contactOffset = 0
        _stepOffset = 0
        _density = 0
        _scaleCoeff = 0
        _volumeGrowth = 0
        _nonWalkableMode = .PREVENT_CLIMBING
        _material = nil
        _registerDeletionListener = false

        _nativeCharacterControllerDesc.setToDefault()
    }
}
