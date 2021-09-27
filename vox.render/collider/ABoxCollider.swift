//
//  ABoxCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Axis Aligned Bound Box (AABB).
class ABoxCollider: Collider {
    private static var _tempVec3: Vector3 = Vector3()
    private static var _tempBox: BoundingBox = BoundingBox()

    public var boxMin: Vector3 = Vector3(-0.5, -0.5, -0.5)
    public var boxMax: Vector3 = Vector3(0.5, 0.5, 0.5)

    private var _corners: Array<Vector3> = []
    private var _cornerFlag: Bool = false

    /// Set box from the minimum point of the box and the maximum point of the box.
    /// - Parameters:
    ///   - min: The minimum point of the box
    ///   - max: The maximum point of the box
    func setBoxMinMax(min: Vector3, max: Vector3) {
        boxMin = min
        boxMax = max

        _cornerFlag = true
    }

    /// Set box from the center point and the size of the bounding box.
    /// - Parameters:
    ///   - center: The center point
    ///   - size: The size of the bounding box
    func setBoxCenterSize(center: Vector3, size: Vector3) {
        let halfSize = ABoxCollider._tempVec3
        Vector3.scale(left: size, s: 0.5, out: halfSize)
        Vector3.add(left: center, right: halfSize, out: boxMax)
        Vector3.subtract(left: center, right: halfSize, out: boxMin)

        _cornerFlag = true
    }

    /// Get the eight corners of this bounding box.
    func getCorners() -> [Vector3] {
        if (_cornerFlag) {
            let minX = boxMin.x
            let minY = boxMin.y
            let minZ = boxMin.z
            let w = boxMax.x - minX
            let h = boxMax.y - minY
            let d = boxMax.z - minZ

            if (_corners.count == 0) {
                for _ in 0..<8 {
                    _corners.append(Vector3())
                }
            }

            _ = _corners[0].setValue(x: minX + w, y: minY + h, z: minZ + d)
            _ = _corners[1].setValue(x: minX, y: minY + h, z: minZ + d)
            _ = _corners[2].setValue(x: minX, y: minY, z: minZ + d)
            _ = _corners[3].setValue(x: minX + w, y: minY, z: minZ + d)
            _ = _corners[4].setValue(x: minX + w, y: minY + h, z: minZ)
            _ = _corners[5].setValue(x: minX, y: minY + h, z: minZ)
            _ = _corners[6].setValue(x: minX, y: minY, z: minZ)
            _ = _corners[7].setValue(x: minX + w, y: minY, z: minZ)

            _cornerFlag = false
        }

        return _corners
    }

    internal override func _raycast(ray: Ray, hit: HitResult) -> Bool {
        let localRay = _getLocalRay(ray: ray)

        let boundingBox = ABoxCollider._tempBox
        boxMin.cloneTo(target: boundingBox.min)
        boxMax.cloneTo(target: boundingBox.max)
        let intersect = localRay.intersectBox(box: boundingBox)
        if (intersect != -1) {
            _updateHitResult(ray: localRay, distance: intersect, outHit: hit, origin: ray.origin)
            return true
        } else {
            return false
        }
    }
}
