//
//  soa_float.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

extension SoaFloat2 {
    static func load(_ _x: _SimdFloat4, _ _y: _SimdFloat4) -> SoaFloat2 {
        SoaFloat2(x: _x, y: _y)
    }

    static func zero() -> SoaFloat2 {
        SoaFloat2(x: simd_float4.zero(), y: simd_float4.zero())
    }

    static func one() -> SoaFloat2 {
        SoaFloat2(x: simd_float4.one(), y: simd_float4.one())
    }

    static func x_axis() -> SoaFloat2 {
        SoaFloat2(x: simd_float4.one(), y: simd_float4.zero())
    }

    static func y_axis() -> SoaFloat2 {
        SoaFloat2(x: simd_float4.zero(), y: simd_float4.one())
    }
}

extension SoaFloat3 {
    static func load(_ _x: _SimdFloat4, _ _y: _SimdFloat4,
                     _ _z: _SimdFloat4) -> SoaFloat3 {
        SoaFloat3(x: _x, y: _y, z: _z)
    }

    static func load(_ _v: SoaFloat2, _ _z: _SimdFloat4) -> SoaFloat3 {
        SoaFloat3(x: _v.x, y: _v.y, z: _z)
    }

    static func zero() -> SoaFloat3 {
        SoaFloat3(x: simd_float4.zero(), y: simd_float4.zero(), z: simd_float4.zero())
    }

    static func one() -> SoaFloat3 {
        SoaFloat3(x: simd_float4.one(), y: simd_float4.one(), z: simd_float4.one())
    }

    static func x_axis() -> SoaFloat3 {
        SoaFloat3(x: simd_float4.one(), y: simd_float4.zero(), z: simd_float4.zero())
    }

    static func y_axis() -> SoaFloat3 {
        SoaFloat3(x: simd_float4.zero(), y: simd_float4.one(), z: simd_float4.zero())
    }

    static func z_axis() -> SoaFloat3 {
        SoaFloat3(x: simd_float4.zero(), y: simd_float4.zero(), z: simd_float4.one())
    }
}

extension SoaFloat4 {
    static func load(_ _x: _SimdFloat4, _ _y: _SimdFloat4,
                     _ _z: _SimdFloat4, _ _w: SimdFloat4) -> SoaFloat4 {
        SoaFloat4(x: _x, y: _y, z: _z, w: _w)
    }

    static func load(_ _v: SoaFloat3, _ _w: _SimdFloat4) -> SoaFloat4 {
        SoaFloat4(x: _v.x, y: _v.y, z: _v.z, w: _w)
    }

    static func load(_ _v: SoaFloat2, _ _z: _SimdFloat4,
                     _ _w: _SimdFloat4) -> SoaFloat4 {
        SoaFloat4(x: _v.x, y: _v.y, z: _z, w: _w)
    }

    static func zero() -> SoaFloat4 {
        let zero = simd_float4.zero()
        return SoaFloat4(x: zero, y: zero, z: zero, w: zero)
    }

    static func one() -> SoaFloat4 {
        let one = simd_float4.one()
        return SoaFloat4(x: one, y: one, z: one, w: one)
    }

    static func x_axis() -> SoaFloat4 {
        let zero = simd_float4.zero()
        return SoaFloat4(x: simd_float4.one(), y: zero, z: zero, w: zero)
    }

    static func y_axis() -> SoaFloat4 {
        let zero = simd_float4.zero()
        return SoaFloat4(x: zero, y: simd_float4.one(), z: zero, w: zero)
    }

    static func z_axis() -> SoaFloat4 {
        let zero = simd_float4.zero()
        return SoaFloat4(x: zero, y: zero, z: simd_float4.one(), w: zero)
    }

    static func w_axis() -> SoaFloat4 {
        let zero = simd_float4.zero()
        return SoaFloat4(x: zero, y: zero, z: zero, w: simd_float4.one())
    }
}

// Returns per element addition of _a and _b using operator +.
func +(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x + _b.x, y: _a.y + _b.y, z: _a.z + _b.z, w: _a.w + _b.w)
}

func +(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: _a.x + _b.x, y: _a.y + _b.y, z: _a.z + _b.z)
}

func +(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: _a.x + _b.x, y: _a.y + _b.y)
}

// Returns per element subtraction of _a and _b using operator -.
func -(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x - _b.x, y: _a.y - _b.y, z: _a.z - _b.z, w: _a.w - _b.w)
}

func -(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: _a.x - _b.x, y: _a.y - _b.y, z: _a.z - _b.z)
}

func -(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: _a.x - _b.x, y: _a.y - _b.y)
}

// Returns per element negative value of _v.
prefix func -(_v: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: -_v.x, y: -_v.y, z: -_v.z, w: -_v.w)
}

prefix func -(_v: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: -_v.x, y: -_v.y, z: -_v.z)
}

prefix func -(_v: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: -_v.x, y: -_v.y)
}

// Returns per element multiplication of _a and _b using operator *.
func *(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x * _b.x, y: _a.y * _b.y, z: _a.z * _b.z, w: _a.w * _b.w)
}

func *(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: _a.x * _b.x, y: _a.y * _b.y, z: _a.z * _b.z)
}

func *(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: _a.x * _b.x, y: _a.y * _b.y)
}

// Returns per element multiplication of _a and scalar value _f using
// operator *.
func *(_a: SoaFloat4, _f: _SimdFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x * _f, y: _a.y * _f, z: _a.z * _f, w: _a.w * _f)
}

func *(_a: SoaFloat3, _f: _SimdFloat4) -> SoaFloat3 {
    SoaFloat3(x: _a.x * _f, y: _a.y * _f, z: _a.z * _f)
}

func *(_a: SoaFloat2, _f: _SimdFloat4) -> SoaFloat2 {
    SoaFloat2(x: _a.x * _f, y: _a.y * _f)
}

// Multiplies _a and _b, then adds _addend.
// v = (_a * _b) + _addend
func mAdd(_ _a: SoaFloat2, _ _b: SoaFloat2, _ _addend: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: mAdd(_a.x, _b.x, _addend.x),
            y: mAdd(_a.y, _b.y, _addend.y))
}

func mAdd(_ _a: SoaFloat3, _ _b: SoaFloat3, _ _addend: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: mAdd(_a.x, _b.x, _addend.x),
            y: mAdd(_a.y, _b.y, _addend.y),
            z: mAdd(_a.z, _b.z, _addend.z))
}

func mAdd(_ _a: SoaFloat4, _ _b: SoaFloat4, _ _addend: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: mAdd(_a.x, _b.x, _addend.x),
            y: mAdd(_a.y, _b.y, _addend.y),
            z: mAdd(_a.z, _b.z, _addend.z),
            w: mAdd(_a.w, _b.w, _addend.w))
}

// Returns per element division of _a and _b using operator /.
func /(_a: SoaFloat4, _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x / _b.x, y: _a.y / _b.y, z: _a.z / _b.z, w: _a.w / _b.w)
}

func /(_a: SoaFloat3, _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: _a.x / _b.x, y: _a.y / _b.y, z: _a.z / _b.z)
}

func /(_a: SoaFloat2, _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: _a.x / _b.x, y: _a.y / _b.y)
}

// Returns per element division of _a and scalar value _f using operator/.
func /(_a: SoaFloat4, _f: _SimdFloat4) -> SoaFloat4 {
    SoaFloat4(x: _a.x / _f, y: _a.y / _f, z: _a.z / _f, w: _a.w / _f)
}

func /(_a: SoaFloat3, _f: _SimdFloat4) -> SoaFloat3 {
    SoaFloat3(x: _a.x / _f, y: _a.y / _f, z: _a.z / _f)
}

func /(_a: SoaFloat2, _f: _SimdFloat4) -> SoaFloat2 {
    SoaFloat2(x: _a.x / _f, y: _a.y / _f)
}

// Returns true if each element of a is less than each element of _b.
func <(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpLt(_a.x, _b.x)
    let y = cmpLt(_a.y, _b.y)
    let z = cmpLt(_a.z, _b.z)
    let w = cmpLt(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}

func <(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpLt(_a.x, _b.x)
    let y = cmpLt(_a.y, _b.y)
    let z = cmpLt(_a.z, _b.z)
    return and(and(x, y), z)
}

func <(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpLt(_a.x, _b.x)
    let y = cmpLt(_a.y, _b.y)
    return and(x, y)
}

// Returns true if each element of a is less or equal to each element of _b.
func <=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpLe(_a.x, _b.x)
    let y = cmpLe(_a.y, _b.y)
    let z = cmpLe(_a.z, _b.z)
    let w = cmpLe(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}

func <=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpLe(_a.x, _b.x)
    let y = cmpLe(_a.y, _b.y)
    let z = cmpLe(_a.z, _b.z)
    return and(and(x, y), z)
}

func <=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpLe(_a.x, _b.x)
    let y = cmpLe(_a.y, _b.y)
    return and(x, y)
}

// Returns true if each element of a is greater than each element of _b.
func >(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpGt(_a.x, _b.x)
    let y = cmpGt(_a.y, _b.y)
    let z = cmpGt(_a.z, _b.z)
    let w = cmpGt(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}

func >(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpGt(_a.x, _b.x)
    let y = cmpGt(_a.y, _b.y)
    let z = cmpGt(_a.z, _b.z)
    return and(and(x, y), z)
}

func >(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpGt(_a.x, _b.x)
    let y = cmpGt(_a.y, _b.y)
    return and(x, y)
}

// Returns true if each element of a is greater or equal to each element of _b.
func >=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpGe(_a.x, _b.x)
    let y = cmpGe(_a.y, _b.y)
    let z = cmpGe(_a.z, _b.z)
    let w = cmpGe(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}

func >=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpGe(_a.x, _b.x)
    let y = cmpGe(_a.y, _b.y)
    let z = cmpGe(_a.z, _b.z)
    return and(and(x, y), z)
}

func >=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpGe(_a.x, _b.x)
    let y = cmpGe(_a.y, _b.y)
    return and(x, y)
}

// Returns true if each element of _a is equal to each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func ==(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpEq(_a.x, _b.x)
    let y = cmpEq(_a.y, _b.y)
    let z = cmpEq(_a.z, _b.z)
    let w = cmpEq(_a.w, _b.w)
    return and(and(and(x, y), z), w)
}

func ==(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpEq(_a.x, _b.x)
    let y = cmpEq(_a.y, _b.y)
    let z = cmpEq(_a.z, _b.z)
    return and(and(x, y), z)
}

func ==(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpEq(_a.x, _b.x)
    let y = cmpEq(_a.y, _b.y)
    return and(x, y)
}

// Returns true if each element of a is different from each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func !=(_a: SoaFloat4, _b: SoaFloat4) -> SimdInt4 {
    let x = cmpNe(_a.x, _b.x)
    let y = cmpNe(_a.y, _b.y)
    let z = cmpNe(_a.z, _b.z)
    let w = cmpNe(_a.w, _b.w)
    return or(or(or(x, y), z), w)
}

func !=(_a: SoaFloat3, _b: SoaFloat3) -> SimdInt4 {
    let x = cmpNe(_a.x, _b.x)
    let y = cmpNe(_a.y, _b.y)
    let z = cmpNe(_a.z, _b.z)
    return or(or(x, y), z)
}

func !=(_a: SoaFloat2, _b: SoaFloat2) -> SimdInt4 {
    let x = cmpNe(_a.x, _b.x)
    let y = cmpNe(_a.y, _b.y)
    return or(x, y)
}

// Returns the (horizontal) addition of each element of _v.
func hAdd(_ _v: SoaFloat4) -> SimdFloat4 {
    _v.x + _v.y + _v.z + _v.w
}

func hAdd(_ _v: SoaFloat3) -> SimdFloat4 {
    _v.x + _v.y + _v.z
}

func hAdd(_ _v: SoaFloat2) -> SimdFloat4 {
    _v.x + _v.y
}

// Returns the dot product of _a and _b.
func dot(_ _a: SoaFloat4, _ _b: SoaFloat4) -> SimdFloat4 {
    _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

func dot(_ _a: SoaFloat3, _ _b: SoaFloat3) -> SimdFloat4 {
    _a.x * _b.x + _a.y * _b.y + _a.z * _b.z
}

func dot(_ _a: SoaFloat2, _ _b: SoaFloat2) -> SimdFloat4 {
    _a.x * _b.x + _a.y * _b.y
}

// Returns the cross product of _a and _b.
func cross(_ _a: SoaFloat3, _ _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: _a.y * _b.z - _b.y * _a.z, y: _a.z * _b.x - _b.z * _a.x, z: _a.x * _b.y - _b.x * _a.y)
}

// Returns the length |_v| of _v.
func length(_ _v: SoaFloat4) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return sqrt(len2)
}

func length(_ _v: SoaFloat3) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return sqrt(len2)
}

func length(_ _v: SoaFloat2) -> SimdFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return sqrt(len2)
}

// Returns the square length |_v|^2 of _v.
func lengthSqr(_ _v: SoaFloat4) -> SimdFloat4 {
    _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
}

func lengthSqr(_ _v: SoaFloat3) -> SimdFloat4 {
    _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
}

func lengthSqr(_ _v: SoaFloat2) -> SimdFloat4 {
    _v.x * _v.x + _v.y * _v.y
}

// Returns the normalized vector _v.
func normalize(_ _v: SoaFloat4) -> SoaFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    guard areAllTrue(cmpNe(len2, simd_float4.zero())) else {
        fatalError("_v is not normalizable")
    }

    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat4(x: _v.x * inv_len, y: _v.y * inv_len, z: _v.z * inv_len, w: _v.w * inv_len)
}

func normalize(_ _v: SoaFloat3) -> SoaFloat3 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    guard areAllTrue(cmpNe(len2, simd_float4.zero())) else {
        fatalError("_v is not normalizable")
    }

    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat3(x: _v.x * inv_len, y: _v.y * inv_len, z: _v.z * inv_len)
}

func normalize(_ _v: SoaFloat2) -> SoaFloat2 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    guard areAllTrue(cmpNe(len2, simd_float4.zero())) else {
        fatalError("_v is not normalizable")
    }
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat2(x: _v.x * inv_len, y: _v.y * inv_len)
}

// Test if each vector _v is normalized.
func isNormalized(_ _v: SoaFloat4) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceSq))
}

func isNormalized(_ _v: SoaFloat3) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceSq))
}

func isNormalized(_ _v: SoaFloat2) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceSq))
}

// Test if each vector _v is normalized using estimated tolerance.
func isNormalizedEst(_ _v: SoaFloat4) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceEstSq))
}

func isNormalizedEst(_ _v: SoaFloat3) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceEstSq))
}

func isNormalizedEst(_ _v: SoaFloat2) -> SimdInt4 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return cmpLt(abs(len2 - simd_float4.one()),
            simd_float4.load1(kNormalizationToleranceEstSq))
}

// Returns the normalized vector _v if the norm of _v is not 0.
// Otherwise returns _safer.
func normalizeSafe(_ _v: SoaFloat4, _ _safer: SoaFloat4) -> SoaFloat4 {
    guard areAllTrue(isNormalizedEst(_safer)) else {
        fatalError("_safer is not normalized")
    }

    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    let b = cmpNe(len2, simd_float4.zero())
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat4(x: select(b, _v.x * inv_len, _safer.x), y: select(b, _v.y * inv_len, _safer.y),
            z: select(b, _v.z * inv_len, _safer.z), w: select(b, _v.w * inv_len, _safer.w))
}

func normalizeSafe(_ _v: SoaFloat3, _ _safer: SoaFloat3) -> SoaFloat3 {
    guard areAllTrue(isNormalizedEst(_safer)) else {
        fatalError("_safer is not normalized")
    }

    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    let b = cmpNe(len2, simd_float4.zero())
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat3(x: select(b, _v.x * inv_len, _safer.x),
            y: select(b, _v.y * inv_len, _safer.y),
            z: select(b, _v.z * inv_len, _safer.z))
}

func normalizeSafe(_ _v: SoaFloat2, _ _safer: SoaFloat2) -> SoaFloat2 {
    guard areAllTrue(isNormalizedEst(_safer)) else {
        fatalError("_safer is not normalized")
    }

    let len2 = _v.x * _v.x + _v.y * _v.y
    let b = cmpNe(len2, simd_float4.zero())
    let inv_len = simd_float4.one() / sqrt(len2)
    return SoaFloat2(x: select(b, _v.x * inv_len, _safer.x),
            y: select(b, _v.y * inv_len, _safer.y))
}

// Returns the linear interpolation of _a and _b with coefficient _f.
// _f is not limited to range [0,1].
func lerp(_ _a: SoaFloat4, _ _b: SoaFloat4, _ _f: _SimdFloat4) -> SoaFloat4 {
    SoaFloat4(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y,
            z: (_b.z - _a.z) * _f + _a.z, w: (_b.w - _a.w) * _f + _a.w)
}

func lerp(_ _a: SoaFloat3, _ _b: SoaFloat3, _ _f: _SimdFloat4) -> SoaFloat3 {
    SoaFloat3(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y,
            z: (_b.z - _a.z) * _f + _a.z)
}

func lerp(_ _a: SoaFloat2, _ _b: SoaFloat2, _ _f: _SimdFloat4) -> SoaFloat2 {
    SoaFloat2(x: (_b.x - _a.x) * _f + _a.x, y: (_b.y - _a.y) * _f + _a.y)
}

// Returns the minimum of each element of _a and _b.
func min(_ _a: SoaFloat4, _ _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: min(_a.x, _b.x), y: min(_a.y, _b.y),
            z: min(_a.z, _b.z), w: min(_a.w, _b.w))
}

func min(_ _a: SoaFloat3, _ _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: min(_a.x, _b.x), y: min(_a.y, _b.y), z: min(_a.z, _b.z))
}

func min(_ _a: SoaFloat2, _ _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: min(_a.x, _b.x), y: min(_a.y, _b.y))
}

// Returns the maximum of each element of _a and _b.
func max(_ _a: SoaFloat4, _ _b: SoaFloat4) -> SoaFloat4 {
    SoaFloat4(x: max(_a.x, _b.x), y: max(_a.y, _b.y),
            z: max(_a.z, _b.z), w: max(_a.w, _b.w))
}

func max(_ _a: SoaFloat3, _ _b: SoaFloat3) -> SoaFloat3 {
    SoaFloat3(x: max(_a.x, _b.x), y: max(_a.y, _b.y), z: max(_a.z, _b.z))
}

func max(_ _a: SoaFloat2, _ _b: SoaFloat2) -> SoaFloat2 {
    SoaFloat2(x: max(_a.x, _b.x), y: max(_a.y, _b.y))
}

// Clamps each element of _x between _a and _b.
// _a must be less or equal to b
func clamp(_ _a: SoaFloat4, _ _v: SoaFloat4, _ _b: SoaFloat4) -> SoaFloat4 {
    max(_a, min(_v, _b))
}

func clamp(_ _a: SoaFloat3, _ _v: SoaFloat3, _ _b: SoaFloat3) -> SoaFloat3 {
    max(_a, min(_v, _b))
}

func clamp(_ _a: SoaFloat2, _ _v: SoaFloat2, _ _b: SoaFloat2) -> SoaFloat2 {
    max(_a, min(_v, _b))
}
