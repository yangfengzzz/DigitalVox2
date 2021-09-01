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

extension BoundingBox {
    
}
