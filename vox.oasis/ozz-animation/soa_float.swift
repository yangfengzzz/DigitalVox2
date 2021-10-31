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

// Returns per element addition of _a and _b using operator +.
func +(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z, _a.w + _b.w)
}

func +(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z)
}

func +(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(_a.x + _b.x, _a.y + _b.y)
}

// Returns per element subtraction of _a and _b using operator -.
func -(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x - _b.x, _a.y - _b.y, _a.z - _b.z, _a.w - _b.w)
}

func -(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    return SoaFloat3(_a.x - _b.x, _a.y - _b.y, _a.z - _b.z)
}

func -(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    return SoaFloat2(_a.x - _b.x, _a.y - _b.y)
}

// Returns per element negative value of _v.
prefix func -(_v: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(-_v.x, -_v.y, -_v.z, -_v.w)
}

prefix func -(_v: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(-_v.x, -_v.y, -_v.z)
}

prefix func -(_v: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(-_v.x, -_v.y)
}

// Returns per element multiplication of _a and _b using operator *.
func *(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x * _b.x, _a.y * _b.y, _a.z * _b.z, _a.w * _b.w)
}

func *(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(_a.x * _b.x, _a.y * _b.y, _a.z * _b.z)
}

func *(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(_a.x * _b.x, _a.y * _b.y)
}

// Returns per element multiplication of _a and scalar value _f using
// operator *.
func *(_a: SoaFloat4, _f: _SimdFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x * _f, _a.y * _f, _a.z * _f, _a.w * _f)
}

func *(_a: SoaFloat3, _f: _SimdFloat4) -> SoaFloat3 {
    SoaFloat3(_a.x * _f, _a.y * _f, _a.z * _f)
}

func *(_a: SoaFloat2, _f: _SimdFloat4) -> SoaFloat2 {
    SoaFloat2(_a.x * _f, _a.y * _f)
}

// Multiplies _a and _b, then adds _addend.
// v = (_a * _b) + _addend
func MAdd(_a: SoaFloat2, _b: SoaFloat2, _addend: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(OZZFloat4.mAdd(with: _a.x, _b.x, _addend.x),
            OZZFloat4.mAdd(with: _a.y, _b.y, _addend.y))
}

func MAdd(_a: SoaFloat3, _b: SoaFloat3, _addend: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(OZZFloat4.mAdd(with: _a.x, _b.x, _addend.x),
            OZZFloat4.mAdd(with: _a.y, _b.y, _addend.y),
            OZZFloat4.mAdd(with: _a.z, _b.z, _addend.z))
}

func MAdd(_a: SoaFloat4, _b: SoaFloat4, _addend: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(OZZFloat4.mAdd(with: _a.x, _b.x, _addend.x),
            OZZFloat4.mAdd(with: _a.y, _b.y, _addend.y),
            OZZFloat4.mAdd(with: _a.z, _b.z, _addend.z),
            OZZFloat4.mAdd(with: _a.w, _b.w, _addend.w))
}

// Returns per element division of _a and _b using operator /.
func /(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x / _b.x, _a.y / _b.y, _a.z / _b.z, _a.w / _b.w)
}

func /(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(_a.x / _b.x, _a.y / _b.y, _a.z / _b.z)
}

func /(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(_a.x / _b.x, _a.y / _b.y)
}

// Returns per element division of _a and scalar value _f using operator/.
func /(_a: SoaFloat4, _f: _SimdFloat4) -> SoaFloat4 {
    SoaFloat4(_a.x / _f, _a.y / _f, _a.z / _f, _a.w / _f)
}

func /(_a: SoaFloat3, _f: _SimdFloat4) -> SoaFloat3 {
    SoaFloat3(_a.x / _f, _a.y / _f, _a.z / _f)
}

func /(_a: SoaFloat2, _f: _SimdFloat4) -> SoaFloat2 {
    SoaFloat2(_a.x / _f, _a.y / _f)
}

// Returns true if each element of a is less than each element of _b.
func <(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpLt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLt(with: _a.y, _b.y)
    let z = OZZFloat4.cmpLt(with: _a.z, _b.z)
    let w = OZZFloat4.cmpLt(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}

func <(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpLt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLt(with: _a.y, _b.y)
    let z = OZZFloat4.cmpLt(with: _a.z, _b.z)
    return OZZInt4.and(with: OZZInt4.and(with: x, y), z)
}

func <(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpLt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLt(with: _a.y, _b.y)
    return OZZInt4.and(with: x, y)
}

// Returns true if each element of a is less or equal to each element of _b.
func <=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpLe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpLe(with: _a.z, _b.z)
    let w = OZZFloat4.cmpLe(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}

func <=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpLe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpLe(with: _a.z, _b.z)
    return OZZInt4.and(with: OZZInt4.and(with: x, y), z)
}

func <=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpLe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpLe(with: _a.y, _b.y)
    return OZZInt4.and(with: x, y)
}

// Returns true if each element of a is greater than each element of _b.
func >(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpGt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGt(with: _a.y, _b.y)
    let z = OZZFloat4.cmpGt(with: _a.z, _b.z)
    let w = OZZFloat4.cmpGt(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}

func >(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpGt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGt(with: _a.y, _b.y)
    let z = OZZFloat4.cmpGt(with: _a.z, _b.z)
    return OZZInt4.and(with: OZZInt4.and(with: x, y), z)
}

func >(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpGt(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGt(with: _a.y, _b.y)
    return OZZInt4.and(with: x, y)
}

// Returns true if each element of a is greater or equal to each element of _b.
func >=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpGe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpGe(with: _a.z, _b.z)
    let w = OZZFloat4.cmpGe(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}

func >=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpGe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpGe(with: _a.z, _b.z)
    return OZZInt4.and(with: OZZInt4.and(with: x, y), z)
}

func >=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpGe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpGe(with: _a.y, _b.y)
    return OZZInt4.and(with: x, y)
}

// Returns true if each element of _a is equal to each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func ==(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpEq(with: _a.x, _b.x)
    let y = OZZFloat4.cmpEq(with: _a.y, _b.y)
    let z = OZZFloat4.cmpEq(with: _a.z, _b.z)
    let w = OZZFloat4.cmpEq(with: _a.w, _b.w)
    return OZZInt4.and(with: OZZInt4.and(with: OZZInt4.and(with: x, y), z), w)
}

func ==(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpEq(with: _a.x, _b.x)
    let y = OZZFloat4.cmpEq(with: _a.y, _b.y)
    let z = OZZFloat4.cmpEq(with: _a.z, _b.z)
    return OZZInt4.and(with: OZZInt4.and(with: x, y), z)
}

func ==(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpEq(with: _a.x, _b.x)
    let y = OZZFloat4.cmpEq(with: _a.y, _b.y)
    return OZZInt4.and(with: x, y)
}

// Returns true if each element of a is different from each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func !=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = OZZFloat4.cmpNe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpNe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpNe(with: _a.z, _b.z)
    let w = OZZFloat4.cmpNe(with: _a.w, _b.w)
    return OZZInt4.or(with: OZZInt4.or(with: OZZInt4.or(with: x, y), z), w)
}

func !=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = OZZFloat4.cmpNe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpNe(with: _a.y, _b.y)
    let z = OZZFloat4.cmpNe(with: _a.z, _b.z)
    return OZZInt4.or(with: OZZInt4.or(with: x, y), z)
}

func !=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = OZZFloat4.cmpNe(with: _a.x, _b.x)
    let y = OZZFloat4.cmpNe(with: _a.y, _b.y)
    return OZZInt4.or(with: x, y)
}

// Returns the (horizontal) addition of each element of _v.
func HAdd(_v: SoaFloat4) -> SimdFloat4 {
    return _v.x + _v.y + _v.z + _v.w
}

func HAdd(_v: SoaFloat3) -> SimdFloat4 {
    return _v.x + _v.y + _v.z
}

func HAdd(_v: SoaFloat2) -> SimdFloat4 {
    return _v.x + _v.y
}

// Returns the dot product of _a and _b.
func Dot(_a: SoaFloat4, _b: SoaFloat4) -> SimdFloat4 {
    return _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

func Dot(_a: SoaFloat3, _b: SoaFloat3) -> SimdFloat4 {
    return _a.x * _b.x + _a.y * _b.y + _a.z * _b.z
}

func Dot(_a: SoaFloat2, _b: SoaFloat2) -> SimdFloat4 {
    return _a.x * _b.x + _a.y * _b.y
}

// Returns the cross product of _a and _b.
func Cross(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(_a.y * _b.z - _b.y * _a.z, _a.z * _b.x - _b.z * _a.x, _a.x * _b.y - _b.x * _a.y)
}

// Returns the length |_v| of _v.
func Length(_v: SoaFloat4) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return OZZFloat4.sqrt(with: len2)
}

func Length(_v: SoaFloat3) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return OZZFloat4.sqrt(with: len2)
}

func Length(_v: SoaFloat2) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return OZZFloat4.sqrt(with: len2)
}

// Returns the square length |_v|^2 of _v.
func LengthSqr(_v: SoaFloat4) -> SimdFloat4 {
    return _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
}

func LengthSqr(_v: SoaFloat3) -> SimdFloat4 {
    return _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
}

func LengthSqr(_v: SoaFloat2) -> SimdFloat4 {
    return _v.x * _v.x + _v.y * _v.y
}
