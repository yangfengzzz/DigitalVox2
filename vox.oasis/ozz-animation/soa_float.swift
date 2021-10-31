//
//  soa_float.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

struct SoaFloat2 {
    var x: SimdFloat4
    var y: SimdFloat4

    init(_ x: SimdFloat4, _ y: SimdFloat4) {
        self.x = x
        self.y = y
    }

    static func Load(_x: _SimdFloat4, _y: _SimdFloat4) -> SoaFloat2 {
        return SoaFloat2(_x, _y)
    }

    static func zero() -> SoaFloat2 {
        return SoaFloat2(OZZFloat4.zero(), OZZFloat4.zero())
    }

    static func one() -> SoaFloat2 {
        return SoaFloat2(OZZFloat4.one(), OZZFloat4.one())
    }

    static func x_axis() -> SoaFloat2 {
        return SoaFloat2(OZZFloat4.one(), OZZFloat4.zero())
    }

    static func y_axis() -> SoaFloat2 {
        return SoaFloat2(OZZFloat4.zero(), OZZFloat4.one())
    }
}

struct SoaFloat3 {
    var x: SimdFloat4
    var y: SimdFloat4
    var z: SimdFloat4

    init(_ x: SimdFloat4, _ y: SimdFloat4, _ z: SimdFloat4) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func Load(_x: _SimdFloat4, _y: _SimdFloat4,
                     _z: _SimdFloat4) -> SoaFloat3 {
        return SoaFloat3(_x, _y, _z)
    }

    static func Load(_v: SoaFloat2, _z: _SimdFloat4) -> SoaFloat3 {
        return SoaFloat3(_v.x, _v.y, _z)
    }

    static func zero() -> SoaFloat3 {
        return SoaFloat3(OZZFloat4.zero(), OZZFloat4.zero(),
                OZZFloat4.zero())
    }

    static func one() -> SoaFloat3 {
        return SoaFloat3(OZZFloat4.one(), OZZFloat4.one(),
                OZZFloat4.one())
    }

    static func x_axis() -> SoaFloat3 {
        return SoaFloat3(OZZFloat4.one(), OZZFloat4.zero(),
                OZZFloat4.zero())
    }

    static func y_axis() -> SoaFloat3 {
        return SoaFloat3(OZZFloat4.zero(), OZZFloat4.one(),
                OZZFloat4.zero())
    }

    static func z_axis() -> SoaFloat3 {
        return SoaFloat3(OZZFloat4.zero(), OZZFloat4.zero(),
                OZZFloat4.one())
    }
}

struct SoaFloat4 {
    var x: SimdFloat4
    var y: SimdFloat4
    var z: SimdFloat4
    var w: SimdFloat4

    init(_ x: SimdFloat4, _ y: SimdFloat4, _ z: SimdFloat4, _ w: SimdFloat4) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    static func Load(_x: _SimdFloat4, _y: _SimdFloat4,
                     _z: _SimdFloat4, _w: SimdFloat4) -> SoaFloat4 {
        return SoaFloat4(_x, _y, _z, _w)
    }

    static func Load(_v: SoaFloat3, _w: _SimdFloat4) -> SoaFloat4 {
        return SoaFloat4(_v.x, _v.y, _v.z, _w)
    }

    static func Load(_v: SoaFloat2, _z: _SimdFloat4,
                     _w: _SimdFloat4) -> SoaFloat4 {
        return SoaFloat4(_v.x, _v.y, _z, _w)
    }

    static func zero() -> SoaFloat4 {
        let zero = OZZFloat4.zero()
        return SoaFloat4(zero, zero, zero, zero)
    }

    static func one() -> SoaFloat4 {
        let one = OZZFloat4.one()
        return SoaFloat4(one, one, one, one)
    }

    static func x_axis() -> SoaFloat4 {
        let zero = OZZFloat4.zero()
        return SoaFloat4(OZZFloat4.one(), zero, zero, zero)
    }

    static func y_axis() -> SoaFloat4 {
        let zero = OZZFloat4.zero()
        return SoaFloat4(zero, OZZFloat4.one(), zero, zero)
    }

    static func z_axis() -> SoaFloat4 {
        let zero = OZZFloat4.zero()
        return SoaFloat4(zero, zero, OZZFloat4.one(), zero)
    }

    static func w_axis() -> SoaFloat4 {
        let zero = OZZFloat4.zero()
        return SoaFloat4(zero, zero, zero, OZZFloat4.one())
    }
}
