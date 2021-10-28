//
//  PhysicsMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Material class to represent a set of surface properties.
class PhysicsMaterial {
    private var _bounciness: Float = 0.1
    private var _dynamicFriction: Float = 0.1
    private var _staticFriction: Float = 0.1
    private var _bounceCombine: PhysicsMaterialCombineMode = PhysicsMaterialCombineMode.Average
    private var _frictionCombine: PhysicsMaterialCombineMode = PhysicsMaterialCombineMode.Average

    internal var _nativeMaterial: IPhysicsMaterial

    init() {
        _nativeMaterial = PhysicsManager._nativePhysics.createPhysicsMaterial(
                _staticFriction,
                _dynamicFriction,
                _bounciness,
                _bounceCombine.rawValue,
                _frictionCombine.rawValue
        )
    }

    /// The coefficient of bounciness.
    var bounciness: Float {
        get {
            _bounciness
        }
        set {
            _bounciness = newValue
            _nativeMaterial.setBounciness(newValue)
        }
    }

    /// The DynamicFriction value.
    var dynamicFriction: Float {
        get {
            _dynamicFriction
        }
        set {
            _dynamicFriction = newValue
            _nativeMaterial.setDynamicFriction(newValue)
        }
    }

    /// The coefficient of static friction.
    var staticFriction: Float {
        get {
            _staticFriction
        }
        set {
            _staticFriction = newValue
            _nativeMaterial.setStaticFriction(newValue)
        }
    }

    /// The restitution combine mode.
    var bounceCombine: PhysicsMaterialCombineMode {
        get {
            _bounceCombine
        }
        set {
            _bounceCombine = newValue
            _nativeMaterial.setBounceCombine(newValue.rawValue)
        }
    }

    /// The friction combine mode.
    var frictionCombine: PhysicsMaterialCombineMode {
        get {
            _frictionCombine
        }
        set {
            _frictionCombine = newValue
            _nativeMaterial.setFrictionCombine(newValue.rawValue)
        }
    }
}
