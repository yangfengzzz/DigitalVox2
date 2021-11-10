//
//  CharacterController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

import Foundation

enum ControllerNonWalkableMode: Int {
    /// Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
    case PREVENT_CLIMBING
    /// Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
    case PREVENT_CLIMBING_AND_FORCE_SLIDING
};

class CharacterController: Component {
    internal var _nativeCharacterController: ICharacterController!

    private var _stepOffset: Float = 0
    private var _nonWalkableMode: ControllerNonWalkableMode = .PREVENT_CLIMBING
    private var _contactOffset: Float = 0
    private var _upDirection = Vector3(0, 1, 0)
    private var _slopeLimit: Float = 0

    var stepOffset: Float {
        get {
            _stepOffset
        }
        set {
            _stepOffset = newValue
            _nativeCharacterController.setStepOffset(newValue)
        }
    }

    var nonWalkableMode: ControllerNonWalkableMode {
        get {
            _nonWalkableMode
        }
        set {
            _nonWalkableMode = newValue
            _nativeCharacterController.setNonWalkableMode(newValue.rawValue)
        }
    }

    var contactOffset: Float {
        get {
            _contactOffset
        }
        set {
            _contactOffset = newValue
            _nativeCharacterController.setContactOffset(newValue)
        }
    }

    var upDirection: Vector3 {
        get {
            _upDirection
        }
        set {
            if _upDirection !== newValue {
                newValue.cloneTo(target: _upDirection)
            }
            _nativeCharacterController.setUpDirection(_upDirection)
        }
    }

    var slopeLimit: Float {
        get {
            _slopeLimit
        }
        set {
            _slopeLimit = newValue
            _nativeCharacterController.setSlopeLimit(newValue)
        }
    }

    required init(_ entity: Entity) {
        super.init(entity)
        if engine.physicsManager!.characterControllerManager == nil {
            engine.physicsManager!._createCharacterControllerManager()
        }
    }

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _nativeCharacterController.move(disp, minDist, elapsedTime)
    }

    func setPosition(_ position: Vector3) -> Bool {
        _nativeCharacterController.setPosition(position)
    }

    func setFootPosition(_ position: Vector3) {
        _nativeCharacterController.setFootPosition(position)
    }

    func invalidateCache() {
        _nativeCharacterController.invalidateCache()
    }

    func resize(_ height: Float) {
        _nativeCharacterController.resize(height)
    }
}
