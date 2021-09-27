//
//  ASphereCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// A bounding sphere.
class ASphereCollider: Collider {
    private static var _tempSphere: BoundingSphere = BoundingSphere()

    var center: Vector3 = Vector3()
    var radius: Float = 1

    /// Set the center and radius of the sphere.
    /// - Parameters:
    ///   - center: The center point of the sphere
    ///   - radius: The radius of the sphere
    func setSphere(_ center: Vector3, _ radius: Float) {
        self.center = center
        self.radius = radius
    }

    internal override func _raycast(_ ray: Ray, _ hit: HitResult) -> Bool {
        let transform = entity.transform
        let boundingSphere = ASphereCollider._tempSphere
        Vector3.transformCoordinate(v: center, m: transform!.worldMatrix, out: boundingSphere.center)
        let lossyScale = transform!.lossyWorldScale
        boundingSphere.radius = radius * max(lossyScale.x, lossyScale.y, lossyScale.z)
        let intersect = ray.intersectSphere(sphere: boundingSphere)
        if (intersect != -1) {
            _updateHitResult(ray, intersect, hit, ray.origin, true)
            return true
        } else {
            return false
        }
    }
}
