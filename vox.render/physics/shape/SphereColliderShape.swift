//
//  SphereColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Physical collider shape for sphere.
class SphereColliderShape: ColliderShape {
    private var _radius: Float = 1

    /// Radius of sphere shape.
    var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            (_nativeShape as! ISphereColliderShape).setRadius(newValue)
        }
    }

    override init() {
        super.init()
        _nativeShape = PhysicsManager._nativePhysics.createSphereColliderShape(
                _id,
                _radius,
                _material._nativeMaterial
        )
    }
}
