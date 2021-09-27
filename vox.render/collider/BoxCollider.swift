//
//  BoxCollider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

class BoxCollider: ABoxCollider {
    private var _center: Vector3 = Vector3()
    private var _size: Vector3 = Vector3()

    var center: Vector3 {
        get {
            _center
        }
        set {
            _center = newValue
            setBoxCenterSize(_center, _size)
        }
    }

    var size: Vector3 {
        get {
            _size
        }
        set {
            _size = newValue
            setBoxCenterSize(_center, _size)
        }
    }

    required init(_ entity: Entity) {
        super.init(entity)
        center = center
        size = size
    }
}
