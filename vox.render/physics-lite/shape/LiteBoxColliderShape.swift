//
//  LiteBoxColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Box collider shape in Lite.
class LiteBoxColliderShape: LiteColliderShape, IBoxColliderShape {
    private static var _tempBox: BoundingBox = BoundingBox();
    private var _halfSize: Vector3 = Vector3();

    internal var _boxMin: Vector3 = Vector3(-0.5, -0.5, -0.5);
    internal var _boxMax: Vector3 = Vector3(0.5, 0.5, 0.5);

    /// Init Box Shape.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark Shape.
    ///   - size: Size of Shape.
    ///   - material: Material of LiteCollider.
    init(_ uniqueID: Int, _ size: Vector3, _ material: LitePhysicsMaterial) {
        super.init();
        _id = uniqueID;
        _ = _halfSize.setValue(x: size.x * 0.5, y: size.y * 0.5, z: size.z * 0.5);
        _setBondingBox();
    }


    override func setPosition(_ position: Vector3) {
        super.setPosition(position);
        _setBondingBox();
    }


    override func setWorldScale(_ scale: Vector3) {
        _transform.setScale(x: scale.x, y: scale.y, z: scale.z);
    }


    func setSize(_ value: Vector3) {
        _ = _halfSize.setValue(x: value.x * 0.5, y: value.y * 0.5, z: value.z * 0.5);
        _setBondingBox();
    }

    internal override func _raycast(_ ray: Ray, _ hit: LiteHitResult) -> Bool {
        let localRay = _getLocalRay(ray);

        let boundingBox = LiteBoxColliderShape._tempBox;
        _boxMin.cloneTo(target: boundingBox.min);
        _boxMax.cloneTo(target: boundingBox.max);
        let rayDistance = localRay.intersectBox(box: boundingBox);
        if (rayDistance != -1) {
            self._updateHitResult(localRay, rayDistance, hit, ray.origin);
            return true;
        } else {
            return false;
        }
    }

    private func _setBondingBox() {
        let center = _transform.position

        Vector3.add(left: center, right: _halfSize, out: self._boxMax);
        Vector3.subtract(left: center, right: _halfSize, out: self._boxMin);
    }
}
