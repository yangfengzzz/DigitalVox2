//
//  PhysXBoxColliderShape.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Box collider shape in PhysX.
class PhysXBoxColliderShape: PhysXColliderShape, IBoxColliderShape {
    private static var _tempHalfExtents = Vector3()
    private var _halfSize: Vector3 = Vector3()

    /// Init Box Shape and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark Shape.
    ///   - size: Size of Shape.
    ///   - material: Material of PhysXCollider.
    init(_ uniqueID: Int, _ size: Vector3, _ material: PhysXPhysicsMaterial) {
        _ = _halfSize.setValue(x: size.x * 0.5, y: size.y * 0.5, z: size.z * 0.5)
        super.init()

        _pxGeometry = CPxBoxGeometry(
                hx: _halfSize.x * _scale.x,
                hy: _halfSize.y * _scale.y,
                hz: _halfSize.z * _scale.z
        )
        _allocShape(material)
        _setLocalPose()
        setUniqueID(uniqueID)
    }

    func setSize(_ size: Vector3) {
        _ = _halfSize.setValue(x: size.x * 0.5, y: size.y * 0.5, z: size.z * 0.5)
        Vector3.multiply(left: _halfSize, right: _scale, out: PhysXBoxColliderShape._tempHalfExtents)
        (_pxGeometry as! CPxBoxGeometry).halfExtents = PhysXBoxColliderShape._tempHalfExtents.elements
        _pxShape.setGeometry(_pxGeometry)
    }

    override func setWorldScale(_ scale: Vector3) {
        scale.cloneTo(target: _scale)
        Vector3.multiply(left: _halfSize, right: _scale, out: PhysXBoxColliderShape._tempHalfExtents)
        (_pxGeometry as! CPxBoxGeometry).halfExtents = PhysXBoxColliderShape._tempHalfExtents.elements
        _pxShape.setGeometry(_pxGeometry)
    }
}
