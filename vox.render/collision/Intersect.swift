//
//  Intersect.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Check whether the boxes intersect.
/// - Parameters:
///   - boxA: The first box to check
///   - boxB: The second box to check
/// - Returns: True if the boxes intersect, false otherwise
func intersectBox2Box(boxA: BoundingBox, boxB: BoundingBox) -> Bool {
    boxA.min.x <= boxB.max.x &&
            boxA.max.x >= boxB.min.x &&
            boxA.min.y <= boxB.max.y &&
            boxA.max.y >= boxB.min.y &&
            boxA.min.z <= boxB.max.z &&
            boxA.max.z >= boxB.min.z
}

/// Check whether the spheres intersect.
/// - Parameters:
///   - sphereA: The first sphere to check
///   - sphereB: The second sphere to check
/// - Returns: True if the spheres intersect, false otherwise
func intersectSphere2Sphere(sphereA: BoundingSphere, sphereB: BoundingSphere) -> Bool {
    let distance = Vector3.distance(left: sphereA.center, right: sphereB.center)
    return distance < sphereA.radius + sphereA.radius
}

/// Check whether the sphere and the box intersect.
/// - Parameters:
///   - sphere: The sphere to check
///   - box: The box to check
/// - Returns: True if the sphere and the box intersect, false otherwise
func intersectSphere2Box(sphere: BoundingSphere, box: BoundingBox) -> Bool {
    let center: Vector3 = sphere.center

    let closestPoint: Vector3 = Vector3(
            max(box.min.x, min(center.x, box.max.x)),
            max(box.min.y, min(center.y, box.max.y)),
            max(box.min.z, min(center.z, box.max.z))
    )

    let distance = Vector3.distance(left: center, right: closestPoint)
    return distance < sphere.radius
}
