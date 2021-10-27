//
//  PhysicsManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Manager for physical scenes.
class PhysicsManager {
    private static var _currentHit: HitResult = HitResult()

    private let _engine: Engine

    internal init(_ engine: Engine) {
        _engine = engine
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameter ray: The ray
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        let distance = Float.greatestFiniteMagnitude
        let layerMask = Layer.Everything

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]

            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    return true
                }
            }
        }
        return isHit
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray, outHitResult: HitResult) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        let hitResult: HitResult = outHitResult
        var distance = Float.greatestFiniteMagnitude
        let layerMask = Layer.Everything

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]

            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    curHit.normal.cloneTo(target: hitResult.normal)
                    curHit.point.cloneTo(target: hitResult.point)
                    hitResult.distance = curHit.distance
                    hitResult.collider = curHit.collider

                    distance = curHit.distance
                }
            }
        }

        if !isHit {
            hitResult.collider = nil
            hitResult.distance = 0
            _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
            _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
        }
        return isHit
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray, distance: Float) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        let layerMask = Layer.Everything

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]

            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    return true
                }
            }
        }

        return isHit
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray, distance: Float, outHitResult: HitResult) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        let hitResult: HitResult = outHitResult
        var distance = distance
        let layerMask = Layer.Everything

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]

            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    curHit.normal.cloneTo(target: hitResult.normal)
                    curHit.point.cloneTo(target: hitResult.point)
                    hitResult.distance = curHit.distance
                    hitResult.collider = curHit.collider

                    distance = curHit.distance
                }
            }
        }

        if !isHit {
            hitResult.collider = nil
            hitResult.distance = 0
            _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
            _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
        }
        return isHit
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray, distance: Float, layerMask: Layer) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]
            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    return true
                }
            }
        }
        return isHit
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    func raycast(ray: Ray, distance: Float, layerMask: Layer, outHitResult: HitResult) -> Bool {
        let cf: ColliderFeature? = _engine.sceneManager.activeScene!.findFeature()
        let colliders = cf!.colliders

        let hitResult: HitResult = outHitResult
        var distance = distance

        var isHit = false
        let curHit = PhysicsManager._currentHit
        for i in 0..<colliders.count {
            let collider = colliders[i]
            if (collider.entity.layer.rawValue & layerMask.rawValue) == 0 {
                continue
            }

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    curHit.normal.cloneTo(target: hitResult.normal)
                    curHit.point.cloneTo(target: hitResult.point)
                    hitResult.distance = curHit.distance
                    hitResult.collider = curHit.collider

                    distance = curHit.distance
                }
            }
        }

        if !isHit {
            hitResult.collider = nil
            hitResult.distance = 0
            _ = hitResult.point.setValue(x: 0, y: 0, z: 0)
            _ = hitResult.normal.setValue(x: 0, y: 0, z: 0)
        }
        return isHit
    }
}
