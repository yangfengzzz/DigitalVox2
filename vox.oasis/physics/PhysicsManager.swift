//
//  PhysicsManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// A physics manager is a collection of bodies and constraints which can interact.
class PhysicsManager {
    internal static var _nativePhysics: IPhysics.Type!

    private var _nativePhysicsManager: IPhysicsManager!
    private var _physicalObjectsMap: [Int: ColliderShape] = [:]

    init() {
        _nativePhysicsManager = PhysicsManager._nativePhysics.createPhysicsManager(
                { (obj1: Int, obj2: Int) in },
                { (obj1: Int, obj2: Int) in },
                { (obj1: Int, obj2: Int) in },
                { (obj1: Int, obj2: Int) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerEnter(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerEnter(shape1!)
                    }
                },
                { (obj1: Int, obj2: Int) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerExit(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerExit(shape1!)
                    }
                },
                { (obj1: Int, obj2: Int) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerStay(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.length {
                        scripts.get(i)!.onTriggerStay(shape1!)
                    }
                }
        )
    }

    /// Call on every frame to update pose of objects.
    internal func _update(_  deltaTime: Float) {
        _nativePhysicsManager.update(deltaTime)
    }

    /// Add ColliderShape into the manager.
    /// - Parameter colliderShape: The Collider Shape.
    internal func _addColliderShape(_  colliderShape: ColliderShape) {
        _physicalObjectsMap[colliderShape.id] = colliderShape
        _nativePhysicsManager.addColliderShape(colliderShape._nativeShape)
    }

    /// Remove ColliderShape.
    /// - Parameter colliderShape: The Collider Shape.
    internal func _removeColliderShape(_ colliderShape: ColliderShape) {
        _physicalObjectsMap.removeValue(forKey: colliderShape.id)
        _nativePhysicsManager.removeColliderShape(colliderShape._nativeShape)
    }

    /// Add collider into the manager.
    /// - Parameter collider: StaticCollider or DynamicCollider.
    internal func _addCollider(_  collider: Collider) {
        _nativePhysicsManager.addCollider(collider._nativeCollider)
    }

    /// Remove collider.
    /// - Parameter collider: StaticCollider or DynamicCollider.
    internal func _removeCollider(_  collider: Collider) {
        _nativePhysicsManager.removeCollider(collider._nativeCollider)
    }
}

//MARK: - Raycast
extension PhysicsManager {
    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameter ray: The ray
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray) -> Bool {
        _nativePhysicsManager.raycast(ray, Float.greatestFiniteMagnitude, nil)
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray, _ outHitResult: HitResult) -> Bool {
        let hitResult: HitResult = outHitResult
        let distance = Float.greatestFiniteMagnitude
        let layerMask = Layer.Everything

        let result = _nativePhysicsManager.raycast(ray, distance, { [self](idx, distance, position, normal) in
            hitResult.entity = _physicalObjectsMap[idx]!._collider!.entity
            hitResult.distance = distance
            normal.cloneTo(target: hitResult.normal)
            position.cloneTo(target: hitResult.point)
        })

        if (result) {
            if (hitResult.entity!.layer.rawValue & layerMask.rawValue != 0) {
                return true
            } else {
                hitResult.entity = nil
                hitResult.distance = 0
                _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
                _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
                return false
            }
        }
        return false
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray, _ distance: Float) -> Bool {
        _nativePhysicsManager.raycast(ray, distance, nil)
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray, _ distance: Float, _ outHitResult: HitResult) -> Bool {
        let hitResult: HitResult = outHitResult
        let layerMask = Layer.Everything

        let result = _nativePhysicsManager.raycast(ray, distance, { [self](idx, distance, position, normal) in
            hitResult.entity = _physicalObjectsMap[idx]!._collider!.entity
            hitResult.distance = distance
            normal.cloneTo(target: hitResult.normal)
            position.cloneTo(target: hitResult.point)
        })

        if (result) {
            if (hitResult.entity!.layer.rawValue & layerMask.rawValue != 0) {
                return true
            } else {
                hitResult.entity = nil
                hitResult.distance = 0
                _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
                _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
                return false
            }
        }
        return false
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray, _ distance: Float, _ layerMask: Layer) -> Bool {
        _nativePhysicsManager.raycast(ray, distance, nil)
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(_ ray: Ray, _ distance: Float, _ layerMask: Layer, _ outHitResult: HitResult) -> Bool {
        let hitResult = outHitResult

        let result = _nativePhysicsManager.raycast(ray, distance, { [self](idx, distance, position, normal) in
            hitResult.entity = _physicalObjectsMap[idx]!._collider!.entity
            hitResult.distance = distance
            normal.cloneTo(target: hitResult.normal)
            position.cloneTo(target: hitResult.point)
        })

        if (result) {
            if (hitResult.entity!.layer.rawValue & layerMask.rawValue != 0) {
                return true
            } else {
                hitResult.entity = nil
                hitResult.distance = 0
                _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
                _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
                return false
            }
        }
        return false
    }
}
