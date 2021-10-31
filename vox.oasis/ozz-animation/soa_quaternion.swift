//
//  soa_quaternion.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

struct SoaQuaternion {
    var x: SimdFloat4
    var y: SimdFloat4
    var z: SimdFloat4
    var w: SimdFloat4

    init(_ x: SimdFloat4,
         _ y: SimdFloat4,
         _ z: SimdFloat4,
         _ w: SimdFloat4) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    // Loads a quaternion from 4 SimdFloat4 values.
    static func Load(_x: _SimdFloat4, _y: _SimdFloat4,
                     _z: _SimdFloat4, _w: SimdFloat4) -> SoaQuaternion {
        return SoaQuaternion(_x, _y, _z, _w)
    }

    // Returns the identity SoaQuaternion.
    static func identity() -> SoaQuaternion {
        let zero = OZZFloat4.zero()
        return SoaQuaternion(zero, zero, zero, OZZFloat4.one())
    }

}
