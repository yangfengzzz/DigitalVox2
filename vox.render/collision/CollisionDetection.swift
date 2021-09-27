//
//  CollisionDetection.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Detect collisions between the Collider on the current entity and other Colliders in the scene.
class CollisionDetection: Script {
    private static var _tempBox1: BoundingBox = BoundingBox()
    private static var _tempBox2: BoundingBox = BoundingBox()

    private var _colliderManager: ColliderFeature?
    private var _myCollider: Collider?
    private var _overlappedCollider: Collider?
    private var _sphere: BoundingSphere?
    private var _box: BoundingBox = BoundingBox()

    /// The collider that intersects with the collider on the current Entity.
    var overlappedCollider: Collider? {
        get {
            _overlappedCollider
        }
    }

    /// When every frame is updated, calculate the collision with other collider.
    override func onUpdate(_ deltaTime: Float) {
        super.onUpdate(deltaTime)

        var overlappedCollider: Collider? = nil

        if (_colliderManager != nil && _myCollider != nil) {
            let colliders = _colliderManager!.colliders

            if (_myCollider is ABoxCollider) {
                _updateWorldBox(_myCollider as! ABoxCollider, _box)
                for i in 0..<colliders.count {
                    let collider = colliders[i]
                    if (collider !== _myCollider && _boxCollision(collider)) {
                        overlappedCollider = collider
                        let scripts = entity._scripts
                        for i in 0..<scripts.count {
                            scripts[i].onTriggerStay(collider)
                        }

                    }
                }
            } else if (_myCollider is ASphereCollider) {
                _sphere = _getWorldSphere(_myCollider as! ASphereCollider)
                for i in 0..<colliders.count {
                    let collider = colliders[i]
                    if (collider !== _myCollider && _sphereCollision(collider)) {
                        overlappedCollider = collider
                        let scripts = entity._scripts
                        for i in 0..<scripts.count {
                            scripts[i].onTriggerStay(collider)
                        }
                    }
                }
            }
        }


        if (overlappedCollider != nil && _overlappedCollider !== overlappedCollider) {
            let scripts = entity._scripts
            for i in 0..<scripts.count {
                scripts[i].onTriggerEnter(overlappedCollider!)
            }
        }

        if (_overlappedCollider != nil && _overlappedCollider !== overlappedCollider) {
            let scripts = entity._scripts
            for i in 0..<scripts.count {
                scripts[i].onTriggerExit(_overlappedCollider!)
            }
        }

        _overlappedCollider = overlappedCollider
    }

    /// Calculate the boundingBox in world space from boxCollider.
    /// - Parameters:
    ///   - boxCollider: The boxCollider to calculate
    ///   - out: The calculated boundingBox
    func _updateWorldBox(_ boxCollider: ABoxCollider, _ out: BoundingBox) {
        let mat = boxCollider.entity.transform.worldMatrix
        let source = CollisionDetection._tempBox1
        boxCollider.boxMax.cloneTo(target: source.max)
        boxCollider.boxMin.cloneTo(target: source.min)
        BoundingBox.transform(source: source, matrix: mat, out: out)
    }

    /// Get the sphere info of the given sphere collider in world space.
    /// - Parameter sphereCollider: The given sphere collider
    /// - Returns: BoundingSphere
    func _getWorldSphere(_ sphereCollider: ASphereCollider) -> BoundingSphere {
        let center: Vector3 = Vector3()
        Vector3.transformCoordinate(v: sphereCollider.center,
                m: sphereCollider.entity.transform.worldMatrix, out: center)
        return BoundingSphere(center, sphereCollider.radius)
    }


    /// Collider and another collider do collision detection.
    /// - Parameter other: The another collider to collision detection
    /// - Returns: detected
    func _boxCollision(_ other: Collider) -> Bool {
        if other is ABoxCollider {
            let box = CollisionDetection._tempBox2
            _updateWorldBox(other as! ABoxCollider, box)
            return intersectBox2Box(boxA: box, boxB: _box)
        } else {
            let sphere = _getWorldSphere(other as! ASphereCollider)
            return intersectSphere2Box(sphere: sphere, box: _box)
        }
    }

    /// Collider and another collider do collision detection.
    /// - Parameter other: The another collider to collision detection
    /// - Returns: detected
    func _sphereCollision(_ other: Collider) -> Bool {
        if other is ABoxCollider {
            let box = CollisionDetection._tempBox2
            _updateWorldBox(other as! ABoxCollider, box)
            return intersectSphere2Box(sphere: _sphere!, box: box)
        } else {
            let sphere = _getWorldSphere(other as! ASphereCollider)
            return intersectSphere2Sphere(sphereA: sphere, sphereB: _sphere!)
        }
    }

    override func onAwake() {
        _colliderManager = scene.findFeature()
        _myCollider = entity.getComponent()
    }

}
