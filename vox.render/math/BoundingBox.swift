//
//  BoundingBox.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

/// Axis Aligned Bound Box (AABB).
class BoundingBox {
    private static var _tempVec30: Vector3 = Vector3()
    private static var _tempVec31: Vector3 = Vector3()

    /// The minimum point of the box.
    public var min: Vector3 = Vector3()
    /// The maximum point of the box. 
    public var max: Vector3 = Vector3()

    /// Constructor of BoundingBox.
    /// - Parameters:
    ///   - min: The minimum point of the box
    ///   - max: The maximum point of the box
    init(_ min: Vector3?, _ max: Vector3?) {
        if min != nil {
            min!.cloneTo(target: self.min)
        }
        if max != nil {
            max!.cloneTo(target: self.max)
        }
    }
}

extension BoundingBox: IClone {
    typealias Object = BoundingBox

    func clone() -> BoundingBox {
        BoundingBox(min, max)
    }

    func cloneTo(target: BoundingBox) {
        min.cloneTo(target: target.min)
        max.cloneTo(target: target.max)
    }
}

//MARK:- Static Methods
extension BoundingBox {
    /// Calculate a bounding box from the center point and the extent of the bounding box.
    /// - Parameters:
    ///   - center: The center point
    ///   - extent: The extent of the bounding box
    ///   - out: The calculated bounding box
    static func fromCenterAndExtent(center: Vector3, extent: Vector3, out: BoundingBox) {
        Vector3.subtract(left: center, right: extent, out: out.min)
        Vector3.add(left: center, right: extent, out: out.max)
    }

    /// Calculate a bounding box that fully contains the given points.
    /// - Parameters:
    ///   - points: The given points
    ///   - out: The calculated bounding box
    static func fromPoints(points: [Vector3], out: BoundingBox) {
        if (points.count == 0) {
            fatalError("points must be array and length must > 0")
        }

        let min = out.min
        let max = out.max
        min.x = Float.greatestFiniteMagnitude
        min.y = Float.greatestFiniteMagnitude
        min.z = Float.greatestFiniteMagnitude
        max.x = -Float.greatestFiniteMagnitude
        max.y = -Float.greatestFiniteMagnitude
        max.z = -Float.greatestFiniteMagnitude

        for i in 0..<points.count {
            let point = points[i]
            Vector3.min(left: min, right: point, out: min)
            Vector3.max(left: max, right: point, out: max)
        }
    }

    /// Calculate a bounding box from a given sphere.
    /// - Parameters:
    ///   - sphere: The given sphere
    ///   - out: The calculated bounding box
    static func fromSphere(sphere: BoundingSphere, out: BoundingBox) {
        let center = sphere.center
        let radius = sphere.radius
        let min = out.min
        let max = out.max

        min.x = center.x - radius
        min.y = center.y - radius
        min.z = center.z - radius
        max.x = center.x + radius
        max.y = center.y + radius
        max.z = center.z + radius
    }

    /// Transform a bounding box.
    /// - Parameters:
    ///   - source: The original bounding box
    ///   - matrix: The transform to apply to the bounding box
    ///   - out: The transformed bounding box
    static func transform(source: BoundingBox, matrix: Matrix, out: BoundingBox) {
        // https://zeux.io/2010/10/17/aabb-from-obb-with-component-wise-abs/
        let center = BoundingBox._tempVec30
        let extent = BoundingBox._tempVec31
        _ = source.getCenter(out: center)
        _ = source.getExtent(out: extent)
        Vector3.transformCoordinate(v: center, m: matrix, out: center)

        let x = extent.x
        let y = extent.y
        let z = extent.z

        extent.x = abs(x * matrix.elements.columns.0[0]) + abs(y * matrix.elements.columns.1[0]) + abs(z * matrix.elements.columns.2[0])
        extent.y = abs(x * matrix.elements.columns.0[1]) + abs(y * matrix.elements.columns.1[1]) + abs(z * matrix.elements.columns.2[1])
        extent.z = abs(x * matrix.elements.columns.0[2]) + abs(y * matrix.elements.columns.1[2]) + abs(z * matrix.elements.columns.2[2])

        // set min、max
        Vector3.subtract(left: center, right: extent, out: out.min)
        Vector3.add(left: center, right: extent, out: out.max)
    }

    /// Calculate a bounding box that is as large as the total combined area of the two specified boxes.
    /// - Parameters:
    ///   - box1: The first box to merge
    ///   - box2: The second box to merge
    ///   - out: The merged bounding box
    /// - Returns: The merged bounding box
    static func merge(box1: BoundingBox, box2: BoundingBox, out: BoundingBox) -> BoundingBox {
        Vector3.min(left: box1.min, right: box2.min, out: out.min)
        Vector3.max(left: box1.max, right: box2.max, out: out.max)
        return out
    }
}

extension BoundingBox {
    /// Get the center point of this bounding box.
    /// - Parameter out: The center point of this bounding box
    /// - Returns: The center point of this bounding box
    func getCenter(out: Vector3) -> Vector3 {
        Vector3.add(left: min, right: max, out: out)
        Vector3.scale(left: out, s: 0.5, out: out)
        return out
    }

    /// Get the extent of this bounding box.
    /// - Parameter out: The extent of this bounding box
    /// - Returns: The extent of this bounding box
    func getExtent(out: Vector3) -> Vector3 {
        Vector3.subtract(left: max, right: min, out: out)
        Vector3.scale(left: out, s: 0.5, out: out)
        return out
    }

    /// Get the eight corners of this bounding box.
    /// - Parameter out: An array of points representing the eight corners of this bounding box
    /// - Returns: An array of points representing the eight corners of this bounding box
    func getCorners(out: inout [Vector3]) -> [Vector3] {
        let minX = min.x
        let minY = min.y
        let minZ = min.z
        let maxX = max.x
        let maxY = max.y
        let maxZ = max.z
        let len = out.count

        // The array length is less than 8 to make up
        if (len < 8) {
            for i in 0..<(8 - len) {
                out[len + i] = Vector3()
            }
        }

        _ = out[0].setValue(x: minX, y: maxY, z: maxZ)
        _ = out[1].setValue(x: maxX, y: maxY, z: maxZ)
        _ = out[2].setValue(x: maxX, y: minY, z: maxZ)
        _ = out[3].setValue(x: minX, y: minY, z: maxZ)
        _ = out[4].setValue(x: minX, y: maxY, z: minZ)
        _ = out[5].setValue(x: maxX, y: maxY, z: minZ)
        _ = out[6].setValue(x: maxX, y: minY, z: minZ)
        _ = out[7].setValue(x: minX, y: minY, z: minZ)

        return out
    }

    /// Transform a bounding box.
    /// - Parameter matrix: The transform to apply to the bounding box
    /// - Returns: The transformed bounding box
    func transform(matrix: Matrix) -> BoundingBox {
        BoundingBox.transform(source: self, matrix: matrix, out: self)
        return self
    }
}
