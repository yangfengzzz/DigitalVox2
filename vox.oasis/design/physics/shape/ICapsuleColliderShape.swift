//
//  ICapsuleColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics capsule collider shape.
protocol ICapsuleColliderShape: IColliderShape {
    /// Set radius of capsule.
    func setRadius(_ radius: Float)

    /// Set height of capsule.
    func setHeight(_ height: Float)

    /// Set up axis of capsule.
    func setUpAxis(_ upAxis: Int)
}
