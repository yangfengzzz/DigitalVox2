//
//  Collider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Define collider data.
class Collider: Component {
    private static var _ray = Ray()

    override func _onEnable() {
        let feature: ColliderFeature? = scene.findFeature()
        feature?.attachCollider(self)
    }

    override func _onDisable() {
        let feature: ColliderFeature? = scene.findFeature()
        feature?.detachCollider(self)
    }


    func _updateHitResult(_ ray: Ray,
                          _ distance: Float,
                          _ outHit: HitResult,
                          _ origin: Vector3,
                          _ isWorldRay: Bool = false) {
        _ = ray.getPoint(distance: distance, out: outHit.point)
        if (!isWorldRay) {
            Vector3.transformCoordinate(v: outHit.point, m: entity.transform.worldMatrix, out: outHit.point)
        }

        outHit.distance = Vector3.distance(left: origin, right: outHit.point)
        outHit.collider = self
    }

    func _getLocalRay(_ ray: Ray) -> Ray {
        let worldToLocal = entity.getInvModelMatrix()
        let outRay = Collider._ray

        Vector3.transformCoordinate(v: ray.origin, m: worldToLocal, out: outRay.origin)
        Vector3.transformNormal(v: ray.direction, m: worldToLocal, out: outRay.direction)
        _ = outRay.direction.normalize()

        return outRay
    }

    internal func _raycast(_ ray: Ray, _ hit: HitResult) -> Bool {
        fatalError("Error: use concrete type instead!")
    }
}
