//
//  IBoxColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics box collider shape.
protocol IBoxColliderShape: IColliderShape {
    /// Set size of Box Shape.
    func setSize(_ size: Vector3)
}
