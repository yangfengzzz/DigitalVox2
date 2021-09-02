//
//  Plane.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Represents a plane in three dimensional space.
class Plane {
    /// The normal of the plane.
    public let normal: Vector3 = Vector3()
    /// The distance of the plane along its normal to the origin.
    public var distance: Float = 0

    /// Constructor of Plane.
    /// - Parameters:
    ///   - normal: The normal vector
    ///   - distance: The distance of the plane along its normal to the origin
    init(_ normal: Vector3? = nil, _ distance: Float = 0) {
        if normal != nil {
            normal!.cloneTo(target: self.normal)
        }
        self.distance = distance
    }
}

extension Plane: IClone {
    typealias Object = Plane

    func clone() -> Plane {
        let out = Plane()
        cloneTo(target: out)
        return out
    }

    func cloneTo(target: Plane) {
        normal.cloneTo(target: target.normal)
        target.distance = distance
    }
}

extension Plane {
    /// Normalize the normal vector of the specified plane.
    /// - Parameters:
    ///   - p: The specified plane
    ///   - out: A normalized version of the specified plane
    static func normalize(p: Plane, out: Plane) {
        let normal = p.normal
        let factor = 1.0 / normal.length()

        let outNormal = out.normal
        outNormal.x = normal.x * factor
        outNormal.y = normal.y * factor
        outNormal.z = normal.z * factor
        out.distance = p.distance * factor
    }

    /// Calculate the plane that contains the three specified points.
    /// - Parameters:
    ///   - point0: The first point
    ///   - point1: The second point
    ///   - point2: The third point
    ///   - out: The calculated plane
    static func fromPoints(point0: Vector3, point1: Vector3, point2: Vector3, out: Plane) {
        let x0 = point0.x
        let y0 = point0.y
        let z0 = point0.z
        let x1 = point1.x - x0
        let y1 = point1.y - y0
        let z1 = point1.z - z0
        let x2 = point2.x - x0
        let y2 = point2.y - y0
        let z2 = point2.z - z0
        let yz = y1 * z2 - z1 * y2
        let xz = z1 * x2 - x1 * z2
        let xy = x1 * y2 - y1 * x2
        let invPyth = 1.0 / sqrt(yz * yz + xz * xz + xy * xy)

        let x = yz * invPyth
        let y = xz * invPyth
        let z = xy * invPyth

        let normal = out.normal
        normal.x = x
        normal.y = y
        normal.z = z

        out.distance = -(x * x0 + y * y0 + z * z0)
    }
}

extension Plane {
    /// Normalize the normal vector of this plane.
    /// - Returns: The plane after normalize
    func normalize() -> Plane {
        Plane.normalize(p: self, out: self)
        return self
    }
}
