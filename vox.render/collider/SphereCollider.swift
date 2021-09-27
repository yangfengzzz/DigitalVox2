//
//  SphereCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

class SphereCollider: ASphereCollider {
    private var __center: Vector3 = Vector3()
    private var __radius: Float = 1.0

    var _center: Vector3 {
        get {
            __center
        }
        set {
            __center = newValue
            self.setSphere(center: __center, radius: __radius)
        }
    }

    var _radius: Float {
        get {
            __radius
        }
        set {
            __radius = newValue
            self.setSphere(center: __center, radius: __radius)
        }
    }

    required init(_ entity: Entity) {
        super.init(entity)

        _center = _center
        _radius = _radius
    }
}
