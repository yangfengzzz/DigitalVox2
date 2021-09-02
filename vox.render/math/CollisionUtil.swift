//
//  CollisionUtil.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Contains static methods to help in determining intersections, containment, etc.
class CollisionUtil {
    private static var _tempVec30: Vector3 = Vector3()
    private static var _tempVec31: Vector3 = Vector3()
}

extension CollisionUtil {
    /// Calculate the distance from a point to a plane.
    /// - Parameters:
    ///   - plane: The plane
    ///   - point: The point
    /// - Returns: The distance from a point to a plane
    static func distancePlaneAndPoint(plane: Plane, point: Vector3) -> Float {
        return Vector3.dot(left: plane.normal, right: point) + plane.distance
    }

    /// Get the intersection type between a plane and a point.
    /// - Parameters:
    ///   - plane: The plane
    ///   - point: The point
    /// - Returns: The intersection type
    static func intersectsPlaneAndPoint(plane: Plane, point: Vector3) -> PlaneIntersectionType {
        let distance = CollisionUtil.distancePlaneAndPoint(plane: plane, point: point)
        if (distance > 0) {
            return PlaneIntersectionType.Front
        }
        if (distance < 0) {
            return PlaneIntersectionType.Back
        }
        return PlaneIntersectionType.Intersecting
    }


    /// Get the intersection type between a plane and a box (AABB).
    /// - Parameters:
    ///   - plane: The plane
    ///   - box: The box
    /// - Returns: The intersection type
    static func intersectsPlaneAndBox(plane: Plane, box: BoundingBox) -> PlaneIntersectionType {
        let min = box.min
        let max = box.max
        let normal = plane.normal
        let front = CollisionUtil._tempVec30
        let back = CollisionUtil._tempVec31

        if (normal.x >= 0) {
            front.x = max.x
            back.x = min.x
        } else {
            front.x = min.x
            back.x = max.x
        }
        if (normal.y >= 0) {
            front.y = max.y
            back.y = min.y
        } else {
            front.y = min.y
            back.y = max.y
        }
        if (normal.z >= 0) {
            front.z = max.z
            back.z = min.z
        } else {
            front.z = min.z
            back.z = max.z
        }

        if (CollisionUtil.distancePlaneAndPoint(plane: plane, point: front) < 0) {
            return PlaneIntersectionType.Back
        }

        if (CollisionUtil.distancePlaneAndPoint(plane: plane, point: back) > 0) {
            return PlaneIntersectionType.Front
        }

        return PlaneIntersectionType.Intersecting
    }

    /// Get the intersection type between a plane and a sphere.
    /// - Parameters:
    ///   - plane: The plane
    ///   - sphere: The sphere
    /// - Returns: The intersection type
    static func intersectsPlaneAndSphere(plane: Plane, sphere: BoundingSphere) -> PlaneIntersectionType {
        let center = sphere.center
        let radius = sphere.radius
        let distance = CollisionUtil.distancePlaneAndPoint(plane: plane, point: center)
        if (distance > radius) {
            return PlaneIntersectionType.Front
        }
        if (distance < -radius) {
            return PlaneIntersectionType.Back
        }
        return PlaneIntersectionType.Intersecting
    }

    /// Get the intersection type between a ray and a plane.
    /// - Parameters:
    ///   - ray: The ray
    ///   - plane: The plane
    /// - Returns: The distance from ray to plane if intersecting, -1 otherwise
    static func intersectsRayAndPlane(ray: Ray, plane: Plane) -> Float {
        let normal = plane.normal
        let zeroTolerance = Float.leastNonzeroMagnitude

        let dir = Vector3.dot(left: normal, right: ray.direction)
        // Parallel
        if (abs(dir) < zeroTolerance) {
            return -1
        }

        let position = Vector3.dot(left: normal, right: ray.origin)
        var distance = (-plane.distance - position) / dir

        if (distance < 0) {
            if (distance < -zeroTolerance) {
                return -1
            }

            distance = 0
        }

        return distance
    }

    /// Get the intersection type between a ray and a box (AABB).
    /// - Parameters:
    ///   - ray: The ray
    ///   - box: The box
    /// - Returns: The distance from ray to box if intersecting, -1 otherwise
    static func intersectsRayAndBox(ray: Ray, box: BoundingBox) -> Float {
        let zeroTolerance = Float.leastNonzeroMagnitude
        let origin = ray.origin
        let direction = ray.origin
        let min = box.min
        let max = box.min
        let dirX = direction.x
        let dirY = direction.y
        let dirZ = direction.z
        let oriX = origin.x
        let oriY = origin.y
        let oriZ = origin.z
        var distance: Float = 0.0
        var tmax = Float.greatestFiniteMagnitude

        if (abs(dirX) < zeroTolerance) {
            if (oriX < min.x || oriX > max.x) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirX
            var t1 = (min.x - oriX) * inverse
            var t2 = (max.x - oriX) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        if (abs(dirY) < zeroTolerance) {
            if (oriY < min.y || oriY > max.y) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirY
            var t1 = (min.y - oriY) * inverse
            var t2 = (max.y - oriY) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        if (abs(dirZ) < zeroTolerance) {
            if (oriZ < min.z || oriZ > max.z) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirZ
            var t1 = (min.z - oriZ) * inverse
            var t2 = (max.z - oriZ) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        return distance
    }

    /// Get the intersection type between a ray and a sphere.
    /// - Parameters:
    ///   - ray: The ray
    ///   - sphere: The sphere
    /// - Returns: The distance from ray to sphere if intersecting, -1 otherwise
    static func intersectsRayAndSphere(ray: Ray, sphere: BoundingSphere) -> Float {
        let origin = ray.origin
        let direction = ray.direction
        let center = sphere.center
        let radius = sphere.radius

        let m = CollisionUtil._tempVec30
        Vector3.subtract(left: origin, right: center, out: m)
        let b = Vector3.dot(left: m, right: direction)
        let c = Vector3.dot(left: m, right: m) - radius * radius

        if (b > 0 && c > 0) {
            return -1
        }

        let discriminant = b * b - c
        if (discriminant < 0) {
            return -1
        }

        var distance = -b - sqrt(discriminant)
        if (distance < 0) {
            distance = 0
        }

        return distance
    }

    /**
     * Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
     * @param frustum - The frustum
     * @param box - The box
     * @returns True if bounding box intersects with this frustum, false otherwise
     */
    static func intersectsFrustumAndBox(frustum: BoundingFrustum, box: BoundingBox) -> Bool {
        let min = box.min
        let max = box.max
        let back = CollisionUtil._tempVec30

        for i in 0..<6 {
            let plane = frustum.getPlane(index: i)!
            let normal = plane.normal

            back.x = normal.x >= 0 ? min.x : max.x
            back.y = normal.y >= 0 ? min.y : max.y
            back.z = normal.z >= 0 ? min.z : max.z
            if (Vector3.dot(left: plane.normal, right: back) > -plane.distance) {
                return false
            }
        }

        return true
    }

    /**
     * Get the containment type between a frustum and a box (AABB).
     * @param frustum - The frustum
     * @param box - The box
     * @returns The containment type
     */
    static func frustumContainsBox(frustum: BoundingFrustum, box: BoundingBox) -> ContainmentType {
        let min = box.min
        let max = box.max
        let front = CollisionUtil._tempVec30
        let back = CollisionUtil._tempVec31
        var result = ContainmentType.Contains

        for i in 0..<6 {
            let plane = frustum.getPlane(index: i)!
            let normal = plane.normal

            if (normal.x >= 0) {
                front.x = max.x
                back.x = min.x
            } else {
                front.x = min.x
                back.x = max.x
            }
            if (normal.y >= 0) {
                front.y = max.y
                back.y = min.y
            } else {
                front.y = min.y
                back.y = max.y
            }
            if (normal.z >= 0) {
                front.z = max.z
                back.z = min.z
            } else {
                front.z = min.z
                back.z = max.z
            }

            if (CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: back) == PlaneIntersectionType.Front) {
                return ContainmentType.Disjoint
            }

            if (CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: front) == PlaneIntersectionType.Front) {
                result = ContainmentType.Intersects
            }
        }

        return result
    }

    /**
     * Get the containment type between a frustum and a sphere.
     * @param frustum - The frustum
     * @param sphere - The sphere
     * @returns The containment type
     */
    static func frustumContainsSphere(frustum: BoundingFrustum, sphere: BoundingSphere) -> ContainmentType {
        var result = ContainmentType.Contains

        for i in 0..<6 {
            let plane = frustum.getPlane(index: i)!
            let intersectionType = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere)
            if (intersectionType == PlaneIntersectionType.Front) {
                return ContainmentType.Disjoint
            } else if (intersectionType == PlaneIntersectionType.Intersecting) {
                result = ContainmentType.Intersects
                break
            }
        }

        return result
    }
}
