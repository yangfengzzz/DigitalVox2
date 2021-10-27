//
//  IPlaneColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics plane collider shape.
protocol IPlaneColliderShape: IColliderShape {
    /// Set local rotation.
    func setRotation(normal: Vector3)
}
