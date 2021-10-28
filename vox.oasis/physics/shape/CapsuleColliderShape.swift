//
//  CapsuleColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Physical collider shape for capsule.
class CapsuleColliderShape: ColliderShape {
    private var _radius: Float = 1
    private var _height: Float = 2
    private var _upAxis: ColliderShapeUpAxis = ColliderShapeUpAxis.Y

    /// Radius of capsule.
    var radius: Float {
        get {
            _radius
        }
        set {
            (_nativeShape as! ICapsuleColliderShape).setRadius(newValue)
        }
    }

    /// Height of capsule.
    var height: Float {
        get {
            _height
        }
        set {
            (_nativeShape as! ICapsuleColliderShape).setHeight(newValue)
        }
    }

    /// Up axis of capsule.
    var upAxis: ColliderShapeUpAxis {
        get {
            _upAxis
        }
        set {
            (_nativeShape as! ICapsuleColliderShape).setUpAxis(newValue.rawValue)
        }
    }

    override init() {
        super.init()
        _nativeShape = PhysicsManager._nativePhysics.createCapsuleColliderShape(
                _id,
                _radius,
                _height,
                _material._nativeMaterial
        )
    }
}
