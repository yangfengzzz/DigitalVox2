//
//  ISphereColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface of physics sphere collider shape.
protocol ISphereColliderShape: IColliderShape {
    /// Set radius of sphere.
    func setRadius(_ radius: Float)
}
