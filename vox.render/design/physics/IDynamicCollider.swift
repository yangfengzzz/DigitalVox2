//
//  IDynamicCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics dynamic collider.
protocol IDynamicCollider: ICollider {
    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    var linearVelocity: Vector3 { get set }
    /// The angular velocity vector of the dynamic collider measured in radians per second.
    var angularVelocity: Vector3 { get set }
    /// The linear damping of the dynamic collider.
    var linearDamping: Float { get set }
    /// The angular damping of the dynamic collider.
    var angularDamping: Float { get set }
    /// The mass of the dynamic collider.
    var mass: Float { get set }
    /// Controls whether physics affects the dynamic collider.
    var isKinematic: Bool { get set }

    /// Apply a force to the dynamic collider.
    func addForce(force: Vector3)

    /// Apply a torque to the dynamic collider.
    func addTorque(torque: Vector3)
}
