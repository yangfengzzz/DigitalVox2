//
//  LiteSphereColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Sphere collider shape in Lite.
class LiteSphereColliderShape: LiteColliderShape, ISphereColliderShape {
    private static var _tempSphere: BoundingSphere = BoundingSphere()

    private var _radius: Float = 1
    private var _maxScale: Float = 1

    var worldRadius: Float {
        get {
            _radius * _maxScale
        }
    }

    /// Init sphere shape.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - radius: Size of SphereCollider
    ///   - material: Material of LiteCollider
    init(_ uniqueID: Int, _ radius: Float, _ material: LitePhysicsMaterial) {
        super.init()
        _radius = radius
        _id = uniqueID
    }


    func setRadius(_ value: Float) {
        _radius = value
    }


    override func setWorldScale(_ scale: Vector3) {
        _maxScale = max(scale.x, max(scale.x, scale.y))
    }


    internal override func _raycast(_ ray: Ray, _ hit: LiteHitResult) -> Bool {
        let boundingSphere = LiteSphereColliderShape._tempSphere
        Vector3.transformCoordinate(v: _transform.position, m: _transform.worldMatrix, out: boundingSphere.center)
        LiteSphereColliderShape._tempSphere.radius = worldRadius

        let rayDistance = ray.intersectSphere(sphere: boundingSphere)
        if (rayDistance != -1) {
            _updateHitResult(ray, rayDistance, hit, ray.origin, true)
            return true
        } else {
            return false
        }
    }
}
