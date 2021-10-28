//
//  ColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Abstract class for collider shapes.
class ColliderShape {
    private static var _idGenerator: Int = 0

    internal var _collider: Collider?
    internal var _nativeShape: IColliderShape!

    var _id: Int
    var _position: Vector3 = Vector3()
    var _material: PhysicsMaterial
    var _isTrigger: Bool = false
    var _isSceneQuery: Bool = true

    /// Collider owner of this shape.
    var collider: Collider? {
        get {
            _collider
        }
    }

    /// Unique id for this shape.
    var id: Int {
        get {
            _id
        }
    }

    /// Physical material.
    var material: PhysicsMaterial {
        get {
            _material
        }
        set {
            _material = newValue
            _nativeShape.setMaterial(newValue._nativeMaterial)
        }
    }

    /// The local position of this ColliderShape.
    var position: Vector3 {
        get {
            _position
        }
        set {
            if (_position !== newValue) {
                newValue.cloneTo(target: _position)
            }
            _nativeShape.setPosition(newValue)
        }
    }

    /// True for TriggerShape, false for SimulationShape.
    var isTrigger: Bool {
        get {
            _isTrigger
        }
        set {
            _isTrigger = newValue
            _nativeShape.setIsTrigger(newValue)
        }
    }


    init() {
        _material = PhysicsMaterial()
        _id = ColliderShape._idGenerator
        ColliderShape._idGenerator += 1
    }


    /// Set local position of collider shape
    /// - Parameters:
    ///   - x: The x component of the vector, default 0
    ///   - y: The y component of the vector, default 0
    ///   - z: The z component of the vector, default 0
    func setPosition(x: Float, y: Float, z: Float) {
        _ = _position.setValue(x: x, y: y, z: z)
        _nativeShape.setPosition(_position)
    }
}
