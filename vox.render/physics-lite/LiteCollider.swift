//
//  LiteCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Abstract class of physical collider.
class LiteCollider: ICollider {
    internal var _shapes: [LiteColliderShape] = []
    internal var _transform: LiteTransform = LiteTransform()

    init() {
        _transform.setOwner(owner: self)
    }

    func addShape(shape: IColliderShape) {
        let shape = shape as! LiteColliderShape
        
        let oldCollider = shape._collider
        if (oldCollider !== self) {
            if (oldCollider != nil) {
                oldCollider!.removeShape(shape: shape)
            }
            _shapes.append(shape)
            shape._collider = self
        }
    }

    func removeShape(shape: IColliderShape) {
        let shape = shape as! LiteColliderShape
        
        _shapes.removeAll { s in
            s === shape
        }
    }


    func setWorldTransform(position: Vector3, rotation: Quaternion) {
        _transform.setPosition(x: position.x, y: position.y, z: position.z)
        _transform.setRotationQuaternion(x: rotation.x, y: rotation.y, z: rotation.z, w: rotation.w)
    }


    func getWorldTransform(outPosition: Vector3, outRotation: Quaternion) {
        let position = _transform.position
        let rotationQuaternion = _transform.rotationQuaternion
        _ = outPosition.setValue(x: position.x, y: position.y, z: position.z)
        _ = outRotation.setValue(x: rotationQuaternion.x, y: rotationQuaternion.y, z: rotationQuaternion.z, w: rotationQuaternion.w)
    }

    internal func _raycast(ray: Ray, hit: LiteHitResult) -> Bool {
        hit.distance = Float.greatestFiniteMagnitude
        for i in 0..<_shapes.count {
            _ = _shapes[i]._raycast(ray: ray, hit: hit)
        }

        return hit.distance != Float.greatestFiniteMagnitude
    }
}
