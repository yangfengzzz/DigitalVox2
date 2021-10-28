//
//  PhysXColliderShape.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Flags which affect the behavior of Shapes.
enum ShapeFlag: Int {
    /// The shape will partake in collision in the physical simulation.
    case SIMULATION_SHAPE = 1
    /// The shape will partake in scene queries (ray casts, overlap tests, sweeps, ...).
    case SCENE_QUERY_SHAPE = 2
    /// The shape is a trigger which can send reports whenever other shapes enter/leave its volume.
    case TRIGGER_SHAPE = 4
}

/// Abstract class for collider shapes.
class PhysXColliderShape: IColliderShape {
    static var halfSqrt: Float = 0.70710678118655


    var _position: Vector3 = Vector3()
    var _rotation: Quaternion = Quaternion(0, 0, PhysXColliderShape.halfSqrt, PhysXColliderShape.halfSqrt)
    var _scale: Vector3 = Vector3(1, 1, 1)

    private var _shapeFlags: Int = ShapeFlag.SCENE_QUERY_SHAPE.rawValue | ShapeFlag.SIMULATION_SHAPE.rawValue
    private var _pxMaterials: [CPxMaterial] = []

    internal var _pxGeometry: CPxGeometry!
    internal var _id: Int!

    func setUniqueID(_ id: Int) {
        fatalError()
    }

    func setPosition(_ position: Vector3) {
        fatalError()
    }

    func setWorldScale(_ scale: Vector3) {
        fatalError()
    }

    func setMaterial(_ material: IPhysicsMaterial) {
        fatalError()
    }

    func setIsTrigger(_ value: Bool) {
        fatalError()
    }

    func setIsSceneQuery(_ value: Bool) {
        fatalError()
    }
}
