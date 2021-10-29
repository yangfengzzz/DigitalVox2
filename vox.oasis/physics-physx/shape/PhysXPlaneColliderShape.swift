//
//  PhysXPlaneColliderShape.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import Foundation

/// Plane collider shape in PhysX.
class PhysXPlaneColliderShape: PhysXColliderShape, IPlaneColliderShape {
    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: Int, _ material: PhysXPhysicsMaterial) {
        super.init()

        _pxGeometry = CPxPlaneGeometry()
        _allocShape(material)
        _setLocalPose()
        setUniqueID(uniqueID)
    }

    func setRotation(_ value: Vector3) {
        Quaternion.rotationYawPitchRoll(yaw: value.x, pitch: value.y, roll: value.z, out: _rotation)
        Quaternion.rotateZ(quaternion: _rotation, rad: Float.pi * 0.5, out: _rotation)
        _ = _rotation.normalize()
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
    }
}
