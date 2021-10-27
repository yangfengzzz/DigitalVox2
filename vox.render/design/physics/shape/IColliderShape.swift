//
//  IColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Interface for physics collider shape.
protocol IColliderShape {
    /// Set unique id of the collider shape.
    func setUniqueID(id: Int)

    /// Set local position.
    func setPosition(position: Vector3)

    /// Set world scale of shape.
    func setWorldScale(scale: Vector3)

    /// Set physics material on shape.
    func setMaterial(material: IPhysicsMaterial)

    /// Set trigger or not.
    func setIsTrigger(value: Bool)

    /// Set scene query or not.
    func setIsSceneQuery(value: Bool)
}
