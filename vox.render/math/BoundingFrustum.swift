//
//  BoundingFrustum.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// A bounding frustum.
class BoundingFrustum {
    /// The near plane of this frustum.
    public var near: Plane
    /// The far plane of this frustum.
    public var far: Plane
    /// The left plane of this frustum.
    public var left: Plane
    /// The right plane of this frustum.
    public var right: Plane
    /// The top plane of this frustum.
    public var top: Plane
    /// The bottom plane of this frustum.
    public var bottom: Plane

    /// Constructor of BoundingFrustum.
    /// - Parameter matrix: The view-projection matrix
    init(matrix: Matrix? = nil) {
        near = Plane()
        far = Plane()
        left = Plane()
        right = Plane()
        top = Plane()
        bottom = Plane()

        if matrix != nil {
            calculateFromMatrix(matrix: matrix!)
        }
    }
}

extension BoundingFrustum: IClone {
    typealias Object = BoundingFrustum

    func clone() -> BoundingFrustum {
        let bf = BoundingFrustum()
        cloneTo(target: bf)
        return bf
    }

    func cloneTo(target: BoundingFrustum) {
        near.cloneTo(target: target.near)
        far.cloneTo(target: target.far)
        left.cloneTo(target: target.left)
        right.cloneTo(target: target.right)
        top.cloneTo(target: target.top)
        bottom.cloneTo(target: target.bottom)
    }
}

extension BoundingFrustum {
    /**
     *

     * @param index - The index
     * @returns The plane get
     */


    /// Get the plane by the given index.
    /// - Remark:
    /// 0: near
    /// 1: far
    /// 2: left
    /// 3: right
    /// 4: top
    /// 5: bottom
    /// - Parameter index: The index
    /// - Returns: The plane get
    func getPlane(index: Int) -> Plane? {
        switch (index) {
        case 0:
            return near
        case 1:
            return far
        case 2:
            return left
        case 3:
            return right
        case 4:
            return top
        case 5:
            return bottom
        default:
            return nil
        }
    }

    /// Update all planes from the given matrix.
    /// - Parameter matrix: The given view-projection matrix
    public func calculateFromMatrix(matrix: Matrix) {
        let m11 = matrix.elements.columns.0[0]
        let m12 = matrix.elements.columns.0[1]
        let m13 = matrix.elements.columns.0[2]
        let m14 = matrix.elements.columns.0[3]

        let m21 = matrix.elements.columns.1[0]
        let m22 = matrix.elements.columns.1[1]
        let m23 = matrix.elements.columns.1[2]
        let m24 = matrix.elements.columns.1[3]

        let m31 = matrix.elements.columns.2[0]
        let m32 = matrix.elements.columns.2[1]
        let m33 = matrix.elements.columns.2[2]
        let m34 = matrix.elements.columns.2[3]

        let m41 = matrix.elements.columns.3[0]
        let m42 = matrix.elements.columns.3[1]
        let m43 = matrix.elements.columns.3[2]
        let m44 = matrix.elements.columns.3[3]

        // near
        let nearNormal = near.normal
        nearNormal.x = -m14 - m13
        nearNormal.y = -m24 - m23
        nearNormal.z = -m34 - m33
        near.distance = -m44 - m43
        _ = near.normalize()

        // far
        let farNormal = far.normal
        farNormal.x = m13 - m14
        farNormal.y = m23 - m24
        farNormal.z = m33 - m34
        far.distance = m43 - m44

        _ = far.normalize()

        // left
        let leftNormal = left.normal
        leftNormal.x = -m14 - m11
        leftNormal.y = -m24 - m21
        leftNormal.z = -m34 - m31
        left.distance = -m44 - m41
        _ = left.normalize()

        // right
        let rightNormal = right.normal
        rightNormal.x = m11 - m14
        rightNormal.y = m21 - m24
        rightNormal.z = m31 - m34
        right.distance = m41 - m44
        _ = right.normalize()

        // top
        let topNormal = top.normal
        topNormal.x = m12 - m14
        topNormal.y = m22 - m24
        topNormal.z = m32 - m34
        top.distance = m42 - m44
        _ = top.normalize()

        // bottom
        let bottomNormal = bottom.normal
        bottomNormal.x = -m14 - m12
        bottomNormal.y = -m24 - m22
        bottomNormal.z = -m34 - m32
        bottom.distance = -m44 - m42
        _ = bottom.normalize()
    }
    
    /// Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
    /// - Parameter box: The box for testing
    /// - Returns: True if bounding box intersects with this frustum, false otherwise
    public func intersectsBox(box: BoundingBox)->Bool {
        fatalError("TODO")
    }
    
    /// Get whether or not a specified bounding sphere intersects with this frustum (Contains or Intersects).
    /// - Parameter sphere: The sphere for testing
    /// - Returns: True if bounding sphere intersects with this frustum, false otherwise
    public func intersectsSphere(sphere: BoundingSphere)->Bool {
        fatalError("TODO")
    }
}
