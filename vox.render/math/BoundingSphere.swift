//
//  BoundingSphere.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

class BoundingSphere {
    /// The center point of the sphere.
    public var center: Vector3 = Vector3()

    /// The radius of the sphere.
    public var radius: Float = 0

    /// Constructor of BoundingSphere.
    /// - Parameters:
    ///   - center: The center point of the sphere
    ///   - radius: The radius of the sphere
    init(_ center: Vector3?, _ radius: Float = 0) {
        if center != nil {
            center!.cloneTo(target: self.center)
        }
        self.radius = radius
    }

    private static var _tempVec30: Vector3 = Vector3()
}

extension BoundingSphere: IClone {
    typealias Object = BoundingSphere

    func clone() -> BoundingSphere {
        BoundingSphere(center, radius)
    }

    func cloneTo(target: BoundingSphere) {
        center.cloneTo(target: target.center)
        target.radius = radius
    }
}

extension BoundingSphere {
    /// Calculate a bounding sphere that fully contains the given points.
    /// - Parameters:
    ///   - points: The given points
    ///   - out: The calculated bounding sphere
    static func fromPoints(points: [Vector3], out: BoundingSphere) {
        if (points.count == 0) {
            fatalError("points must be array and length must > 0")
        }

        let len = points.count
        let center = BoundingSphere._tempVec30
        center.x = 0
        center.y = 0
        center.z = 0

        // Calculate the center of the sphere.
        for i in 0..<len {
            Vector3.add(left: points[i], right: center, out: center)
        }

        // The center of the sphere.
        Vector3.scale(left: center, s: 1.0 / Float(len), out: out.center)

        // Calculate the radius of the sphere.
        var radius: Float = 0.0
        for i in 0..<len {
            let distance = Vector3.distanceSquared(left: center, right: points[i])
            if distance > radius {
                radius = distance
            }
        }
        // The radius of the sphere.
        out.radius = sqrt(radius)
    }

    /// Calculate a bounding sphere from a given box.
    /// - Parameters:
    ///   - box: The given box
    ///   - out: The calculated bounding sphere
    static func fromBox(box: BoundingBox, out: BoundingSphere) {
        let center = out.center
        let min = box.min
        let max = box.max

        center.x = (min.x + max.x) * 0.5
        center.y = (min.y + max.y) * 0.5
        center.z = (min.z + max.z) * 0.5
        out.radius = Vector3.distance(left: center, right: max)
    }
}
