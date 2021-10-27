//
//  IPhysicsMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics material.
protocol IPhysicsMaterial {
    /// Set the coefficient of bounciness.
    func setBounciness(value: Float)

    /// Set the coefficient of dynamic friction.
    func setDynamicFriction(value: Float)

    /// Set the coefficient of static friction.
    func setStaticFriction(value: Float)

    /// Set the bounciness combine mode.
    func setBounceCombine(value: Float)

    /// Set the friction combine mode.
    func setFrictionCombine(value: Float)
}
