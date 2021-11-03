//
//  box.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Defines an axis aligned box.
struct Box {
    // Constructs an invalid box.
    init() {
        min = VecFloat3(Float.greatestFiniteMagnitude)
        max = VecFloat3(-Float.greatestFiniteMagnitude)
    }

    // Constructs a box with the specified _min and _max bounds.
    init(_ _min: VecFloat3, _ _max: VecFloat3) {
        min = _min
        max = _max
    }

    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points.
    init(_ _point: VecFloat3) {
        min = _point
        max = _point
    }

    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points, it must be greater or
    // equal to sizeof(Float3).
    init(_ _points: [VecFloat3]) {
        var local_min = VecFloat3(Float.greatestFiniteMagnitude)
        var local_max = VecFloat3(-Float.greatestFiniteMagnitude)

        for i in 0..<_points.count {
            local_min = vox_oasis.min(local_min, _points[i])
            local_max = vox_oasis.max(local_max, _points[i])
        }

        min = local_min
        max = local_max
    }

    // Tests whether *this is a valid box.
    func is_valid() -> Bool {
        min <= max
    }

    // Tests whether _p is within box bounds.
    func is_inside(_ _p: VecFloat3) -> Bool {
        _p >= min && _p <= max
    }

    // Box's min and max bounds.
    var min: VecFloat3
    var max: VecFloat3
}

// Merges two boxes _a and _b.
// Both _a and _b can be invalid.
func merge(_ _a: Box, _ _b: Box) -> Box {
    if (!_a.is_valid()) {
        return _b
    } else if (!_b.is_valid()) {
        return _a
    }
    return Box(min(_a.min, _b.min), max(_a.max, _b.max))
}

// Compute box transformation by a matrix.
func transformBox(_  _matrix: simd_float4x4, _  _box: Box) -> Box {
    var box_min = [_box.min.x, _box.min.y, _box.min.z, 0.0]
    var box_max = [_box.max.x, _box.max.y, _box.max.z, 0.0]
    let min = simd_float4.load3PtrU(&box_min)
    let max = simd_float4.load3PtrU(&box_max)

    // Transforms min and max.
    let ta = transformPoint(_matrix, min)
    let tb = transformPoint(_matrix, max)

    // Finds new min and max and store them in box.
    var tbox = Box()
    OZZFloat4.store3PtrU(with: OZZFloat4.min(with: ta, tb), &tbox.min.x)
    OZZFloat4.store3PtrU(with: OZZFloat4.max(with: ta, tb), &tbox.max.x)
    return tbox
}
