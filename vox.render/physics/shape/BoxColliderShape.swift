//
//  BoxColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Physical collider shape for box.
class BoxColliderShape: ColliderShape {
    private var _size: Vector3 = Vector3(1, 1, 1)

    /// Size of box shape.
    var size: Vector3 {
        get {
            _size
        }
        set {
            if (_size !== newValue) {
                newValue.cloneTo(target: _size)
            }
            (_nativeShape as! IBoxColliderShape).setSize(newValue)
        }
    }

    override init() {
        super.init()
        _nativeShape = PhysicsManager._nativePhysics.createBoxColliderShape(
                _id,
                _size,
                _material._nativeMaterial
        )
    }

    /// Set size of box.
    /// - Parameters:
    ///   - x: Size of x-axis
    ///   - y: Size of y-axis
    ///   - z: Size of z-axis
    func setSize(_ x: Float, _ y: Float, _ z: Float) {
        _size.x = x
        _size.y = y
        _size.z = z
        (_nativeShape as! IBoxColliderShape).setSize(_size)
    }
}
