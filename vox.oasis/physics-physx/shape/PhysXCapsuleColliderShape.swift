//
//  PhysXCapsuleColliderShape.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// Capsule collider shape in PhysX.
class PhysXCapsuleColliderShape: PhysXColliderShape, ICapsuleColliderShape {
    private var _radius: Float
    private var _halfHeight: Float
    private var _upAxis: ColliderShapeUpAxis = ColliderShapeUpAxis.Y

    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - radius: Radius of CapsuleCollider
    ///   - height: Height of CapsuleCollider
    ///   - material: Material of PhysXCollider
    init(uniqueID: Int, radius: Float, height: Float, material: PhysXPhysicsMaterial) {
        _radius = radius
        _halfHeight = height * 0.5

        super.init()

        _pxGeometry = CPxCapsuleGeometry(radius: _radius, halfHeight: _halfHeight)
        _allocShape(material)
        _setLocalPose()
        setUniqueID(uniqueID)
    }

    func setRadius(_ value: Float) {
        _radius = value
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.y, _scale.z)
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.x, _scale.z)
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.x, _scale.y)
            break
        }
        _pxShape.setGeometry(_pxGeometry)
    }

    func setHeight(_ value: Float) {
        _halfHeight = value * 0.5
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.x
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.y
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.z
            break
        }
        _pxShape.setGeometry(_pxGeometry)
    }

    func setUpAxis(_ upAxis: Int) {
        _upAxis = ColliderShapeUpAxis(rawValue: upAxis)!
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            _ = _rotation.setValue(x: 0, y: 0, z: 0, w: 1)
            break
        case ColliderShapeUpAxis.Y:
            _ = _rotation.setValue(x: 0, y: 0, z: PhysXColliderShape.halfSqrt, w: PhysXColliderShape.halfSqrt)
            break
        case ColliderShapeUpAxis.Z:
            _ = _rotation.setValue(x: 0, y: PhysXColliderShape.halfSqrt, z: 0, w: PhysXColliderShape.halfSqrt)
            break
        }
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.y, scale.z)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.x
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.x, scale.z)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.y
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.x, scale.y)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.z
            break
        }
        _pxShape.setGeometry(_pxGeometry)
    }
}
