//
//  Ray.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Represents a ray with an origin and a direction in 3D space.
class Ray {
    /// The origin of the ray.
    let origin: Vector3 = Vector3()
    /// The normalized direction of the ray.
    let direction: Vector3 = Vector3()

    /// Constructor of Ray.
    /// - Parameters:
    ///   - origin: The origin vector
    ///   - direction: The direction vector
    init(origin: Vector3? = nil, direction: Vector3? = nil) {
        if origin != nil {
            origin!.cloneTo(target: self.origin)
        }
        if direction != nil {
            direction!.cloneTo(target: self.direction)
        }
    }
}

extension Ray {
    /// Check if this ray intersects the specified plane.
    /// - Parameter plane: The specified plane
    /// - Returns: The distance from this ray to the specified plane if intersecting, -1 otherwise
    func intersectPlane(plane: Plane) -> Float {
        CollisionUtil.intersectsRayAndPlane(ray: self, plane: plane)
    }

    /// Check if this ray intersects the specified sphere.
    /// - Parameter sphere: The specified sphere
    /// - Returns: The distance from this ray to the specified sphere if intersecting, -1 otherwise
    func intersectSphere(sphere: BoundingSphere) -> Float {
        CollisionUtil.intersectsRayAndSphere(ray: self, sphere: sphere)
    }

    /// Check if this ray intersects the specified box (AABB).
    /// - Parameter box: The specified box
    /// - Returns: The distance from this ray to the specified box if intersecting, -1 otherwise
    func intersectBox(box: BoundingBox) -> Float {
        CollisionUtil.intersectsRayAndBox(ray: self, box: box)
    }

    /// The coordinates of the specified distance from the origin in the ray direction.
    /// - Parameters:
    ///   - distance:  The specified distance
    ///   - out: The coordinates as an output parameter
    /// - Returns: The out
    func getPoint(distance: Float, out: Vector3) -> Vector3 {
        Vector3.scale(left: direction, s: distance, out: out)
        return out.add(right: origin)
    }
}
