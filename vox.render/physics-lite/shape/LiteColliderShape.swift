//
//  LiteColliderShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Abstract class for collider shapes.
class LiteColliderShape: IColliderShape {
    private static var _ray = Ray()
    private static var _tempPoint = Vector3()

    internal var _id: Int!
    internal var _collider: LiteCollider!
    internal var _transform: LiteTransform = LiteTransform()
    internal var _invModelMatrix: Matrix = Matrix()
    internal var _inverseWorldMatFlag: LiteUpdateFlag

    init() {
        _inverseWorldMatFlag = _transform.registerWorldChangeFlag()
        _transform.setOwner(owner: self)
    }

    func setPosition(position: Vector3) {
        _transform.setPosition(x: position.x, y: position.y, z: position.z)
    }

    func setWorldScale(scale: Vector3) {
        fatalError()
    }

    func setMaterial(material: IPhysicsMaterial) {
        fatalError("Physics-lite don't support setMaterial. Use Physics-PhysX instead!")
    }

    func setUniqueID(id: Int) {
        _id = id
    }

    func setIsTrigger(value: Bool) {
        fatalError("Physics-lite don't support setIsTrigger. Use Physics-PhysX instead!")
    }

    func setIsSceneQuery(value: Bool) {
        fatalError("Physics-lite don't support setIsSceneQuery. Use Physics-PhysX instead!")
    }

    internal func _raycast(ray: Ray, hit: LiteHitResult) -> Bool {
        fatalError()
    }

    func _updateHitResult(ray: Ray,
                          rayDistance: Float,
                          outHit: LiteHitResult,
                          origin: Vector3,
                          isWorldRay: Bool = false) {
        let hitPoint = LiteColliderShape._tempPoint
        _ = ray.getPoint(distance: rayDistance, out: hitPoint)
        if (!isWorldRay) {
            Vector3.transformCoordinate(v: hitPoint, m: _transform.worldMatrix, out: hitPoint)
        }

        let distance = Vector3.distance(left: origin, right: hitPoint)

        if (distance < outHit.distance) {
            hitPoint.cloneTo(target: outHit.point)
            outHit.distance = distance
            outHit.shapeID = _id
        }
    }

    func _getLocalRay(ray: Ray) -> Ray {
        let worldToLocal = _getInvModelMatrix()
        let outRay = LiteColliderShape._ray

        Vector3.transformCoordinate(v: ray.origin, m: worldToLocal, out: outRay.origin)
        Vector3.transformNormal(v: ray.direction, m: worldToLocal, out: outRay.direction)
        _ = outRay.direction.normalize()

        return outRay
    }

    private func _getInvModelMatrix() -> Matrix {
        if (_inverseWorldMatFlag.flag) {
            Matrix.invert(a: _transform.worldMatrix, out: _invModelMatrix)
            _inverseWorldMatFlag.flag = false
        }
        return _invModelMatrix
    }
}
