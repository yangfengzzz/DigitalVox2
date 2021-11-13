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

enum ControllerCollisionFlag: Int {
    /// Character is colliding to the sides.
    case COLLISION_SIDES = 1
    /// Character has collision above.
    case COLLISION_UP = 2
    /// Character has collision below.
    case COLLISION_DOWN = 4
};

class CharacterController: Component {
    internal var _index: Int = -1
    internal var _nativeCharacterController: ICharacterController!

    private var _stepOffset: Float = 0
    private var _nonWalkableMode: ControllerNonWalkableMode = .PREVENT_CLIMBING
    private var _contactOffset: Float = 0
    private var _upDirection = Vector3(0, 1, 0)
    private var _slopeLimit: Float = 0

    var _id: Int
    var _material: PhysicsMaterial

    /// Unique id for this controller.
    var id: Int {
        get {
            _id
        }
    }

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
        _id = PhysicsManager._idGenerator
        PhysicsManager._idGenerator += 1
        _material = PhysicsMaterial()

        super.init(entity)

        if engine.physicsManager!.characterControllerManager == nil {
            engine.physicsManager!._createCharacterControllerManager()
        }
    }

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _nativeCharacterController.move(disp, minDist, elapsedTime)
    }

    func isSetControllerCollisionFlag(_ flags: UInt8, _ flag: ControllerCollisionFlag) -> Bool {
        _nativeCharacterController.isSetControllerCollisionFlag(flags, flag.rawValue)
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

    internal func _onLateUpdate() {
        let position = entity.transform!.worldPosition
        _nativeCharacterController.getPosition(position)
        entity.transform!.worldPosition = position
    }

    internal override func _onEnable() {
        engine._componentsManager.addCharacterController(self)
    }


    internal override func _onDisable() {
        engine.physicsManager!._removeCharacterController(self)
        engine._componentsManager.removeCharacterController(self)
    }
}
