//
//  PlaneColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Physical collider shape plane.
class PlaneColliderShape: ColliderShape {
    private var _rotation: Vector3 = Vector3()

    /// The local rotation of this plane.
    var rotation: Vector3 {
        get {
            _rotation
        }
        set {
            if (_rotation !== newValue) {
                newValue.cloneTo(target: _rotation)
            }
            (_nativeShape as! IPlaneColliderShape).setRotation(newValue)
        }
    }

    override init() {
        super.init()
        _nativeShape = PhysicsManager._nativePhysics.createPlaneColliderShape(
                _id,
                _material._nativeMaterial
        )
    }

    /// Set the local rotation of this plane.
    /// - Parameters:
    ///   - x: Radian of yaw
    ///   - y: Radian of pitch
    ///   - z: Radian of roll
    func setRotation(_ x: Float, _ y: Float, _ z: Float) {
        _ = _rotation.setValue(x: x, y: y, z: z)
        (_nativeShape as! IPlaneColliderShape).setRotation(_rotation)
    }
}
