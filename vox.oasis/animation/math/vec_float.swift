//
//  vec_float.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Declares a 2d float vector.
struct VecFloat2 {
    var x: Float
    var y: Float

    // Constructs an uninitialized vector.
    init() {
        x = 0
        y = 0
    }

    // Constructs a vector initialized with _f value.
    init(_ _f: Float) {
        x = _f
        y = _f
    }

    // Constructs a vector initialized with _x and _y values.
    init(_ _x: Float, _ _y: Float) {
        x = _x
        y = _y
    }

    // Returns a vector with all components set to 0.
    static func zero() -> VecFloat2 {
        VecFloat2(0.0)
    }

    // Returns a vector with all components set to 1.
    static func one() -> VecFloat2 {
        VecFloat2(1.0)
    }

    // Returns a unitary vector x.
    static func x_axis() -> VecFloat2 {
        VecFloat2(1.0, 0.0)
    }

    // Returns a unitary vector y.
    static func y_axis() -> VecFloat2 {
        VecFloat2(0.0, 1.0)
    }
}

// Declares a 3d float vector.
struct VecFloat3 {
    var x: Float
    var y: Float
    var z: Float

    // Constructs an uninitialized vector.
    init() {
        x = 0
        y = 0
        z = 0
    }

    // Constructs a vector initialized with _f value.
    init(_ _f: Float) {
        x = _f
        y = _f
        z = _f
    }

    // Constructs a vector initialized with _x, _y and _z values.
    init(_ _x: Float, _  _y: Float, _  _z: Float) {
        x = _x
        y = _y
        z = _z
    }

    // Returns a vector initialized with _v.x, _v.y and _z values.
    init(_ _v: VecFloat3, _  _z: Float) {
        x = _v.x
        y = _v.y
        z = _z
    }

    // Returns a vector with all components set to 0.
    static func zero() -> VecFloat3 {
        VecFloat3(0.0)
    }

    // Returns a vector with all components set to 1.
    static func one() -> VecFloat3 {
        VecFloat3(1.0)
    }

    // Returns a unitary vector x.
    static func x_axis() -> VecFloat3 {
        VecFloat3(1.0, 0.0, 0.0)
    }

    // Returns a unitary vector y.
    static func y_axis() -> VecFloat3 {
        VecFloat3(0.0, 1.0, 0.0)
    }

    // Returns a unitary vector z.
    static func z_axis() -> VecFloat3 {
        VecFloat3(0.0, 0.0, 1.0)
    }
}

// Declares a 4d float vector.
struct VecFloat4 {
    var x: Float
    var y: Float
    var z: Float
    var w: Float

    // Constructs an uninitialized vector.
    init() {
        x = 0
        y = 0
        z = 0
        w = 0
    }

    // Constructs a vector initialized with _f value.
    init(_  _f: Float) {
        x = _f
        y = _f
        z = _f
        w = _f
    }

    // Constructs a vector initialized with _x, _y, _z and _w values.
    init(_  _x: Float, _  _y: Float, _  _z: Float, _  _w: Float) {
        x = _x
        y = _y
        z = _z
        w = _w
    }

    // Constructs a vector initialized with _v.x, _v.y, _v.z and _w values.
    init(_ _v: VecFloat3, _ _w: Float) {
        x = _v.x
        y = _v.y
        z = _v.z
        w = _w
    }

    // Constructs a vector initialized with _v.x, _v.y, _z and _w values.
    init(_ _v: VecFloat2, _ _z: Float, _ _w: Float) {
        x = _v.x
        y = _v.y
        z = _z
        w = _w
    }

    // Returns a vector with all components set to 0.
    static func zero() -> VecFloat4 {
        VecFloat4(0.0)
    }

    // Returns a vector with all components set to 1.
    static func one() -> VecFloat4 {
        VecFloat4(1.0)
    }

    // Returns a unitary vector x.
    static func x_axis() -> VecFloat4 {
        VecFloat4(1.0, 0.0, 0.0, 0.0)
    }

    // Returns a unitary vector y.
    static func y_axis() -> VecFloat4 {
        VecFloat4(0.0, 1.0, 0.0, 0.0)
    }

    // Returns a unitary vector z.
    static func z_axis() -> VecFloat4 {
        VecFloat4(0.0, 0.0, 1.0, 0.0)
    }

    // Returns a unitary vector w.
    static func w_axis() -> VecFloat4 {
        VecFloat4(0.0, 0.0, 0.0, 1.0)
    }
}

// Returns per element addition of _a and _b using operator +.
func +(_a: VecFloat4, _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z, _a.w + _b.w)
}

func +(_a: VecFloat3, _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x + _b.x, _a.y + _b.y, _a.z + _b.z)
}

func +(_a: VecFloat2, _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x + _b.x, _a.y + _b.y)
}

// Returns per element subtraction of _a and _b using operator -.
func -(_a: VecFloat4, _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x - _b.x, _a.y - _b.y, _a.z - _b.z, _a.w - _b.w)
}

func -(_a: VecFloat3, _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x - _b.x, _a.y - _b.y, _a.z - _b.z)
}

func -(_a: VecFloat2, _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x - _b.x, _a.y - _b.y)
}

// Returns per element negative value of _v.
prefix func -(_v: VecFloat4) -> VecFloat4 {
    VecFloat4(-_v.x, -_v.y, -_v.z, -_v.w)
}

prefix func -(_v: VecFloat3) -> VecFloat3 {
    VecFloat3(-_v.x, -_v.y, -_v.z)
}

prefix func -(_v: VecFloat2) -> VecFloat2 {
    VecFloat2(-_v.x, -_v.y)
}

// Returns per element multiplication of _a and _b using operator *.
func *(_a: VecFloat4, _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x * _b.x, _a.y * _b.y, _a.z * _b.z, _a.w * _b.w)
}

func *(_a: VecFloat3, _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x * _b.x, _a.y * _b.y, _a.z * _b.z)
}

func *(_a: VecFloat2, _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x * _b.x, _a.y * _b.y)
}

// Returns per element multiplication of _a and scalar value _f using
// operator *.
func *(_a: VecFloat4, _f: Float) -> VecFloat4 {
    VecFloat4(_a.x * _f, _a.y * _f, _a.z * _f, _a.w * _f)
}

func *(_a: VecFloat3, _f: Float) -> VecFloat3 {
    VecFloat3(_a.x * _f, _a.y * _f, _a.z * _f)
}

func *(_a: VecFloat2, _f: Float) -> VecFloat2 {
    VecFloat2(_a.x * _f, _a.y * _f)
}

// Returns per element division of _a and _b using operator /.
func /(_a: VecFloat4, _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x / _b.x, _a.y / _b.y, _a.z / _b.z, _a.w / _b.w)
}

func /(_a: VecFloat3, _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x / _b.x, _a.y / _b.y, _a.z / _b.z)
}

func /(_a: VecFloat2, _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x / _b.x, _a.y / _b.y)
}

// Returns per element division of _a and scalar value _f using operator/.
func /(_a: VecFloat4, _f: Float) -> VecFloat4 {
    VecFloat4(_a.x / _f, _a.y / _f, _a.z / _f, _a.w / _f)
}

func /(_a: VecFloat3, _f: Float) -> VecFloat3 {
    VecFloat3(_a.x / _f, _a.y / _f, _a.z / _f)
}

func /(_a: VecFloat2, _f: Float) -> VecFloat2 {
    VecFloat2(_a.x / _f, _a.y / _f)
}

// Returns the (horizontal) addition of each element of _v.
func hAdd(_ _v: VecFloat4) -> Float {
    _v.x + _v.y + _v.z + _v.w
}

func hAdd(_ _v: VecFloat3) -> Float {
    _v.x + _v.y + _v.z
}

func hAdd(_ _v: VecFloat2) -> Float {
    _v.x + _v.y
}

// Returns the dot product of _a and _b.
func dot(_ _a: VecFloat4, _ _b: VecFloat4) -> Float {
    _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
}

func dot(_ _a: VecFloat3, _ _b: VecFloat3) -> Float {
    _a.x * _b.x + _a.y * _b.y + _a.z * _b.z
}

func dot(_ _a: VecFloat2, _ _b: VecFloat2) -> Float {
    _a.x * _b.x + _a.y * _b.y
}

// Returns the cross product of _a and _b.
func cross(_ _a: VecFloat3, _ _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.y * _b.z - _b.y * _a.z, _a.z * _b.x - _b.z * _a.x,
            _a.x * _b.y - _b.x * _a.y)
}

// Returns the length |_v| of _v.
func length(_ _v: VecFloat4) -> Float {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return sqrt(len2)
}

func length(_ _v: VecFloat3) -> Float {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return sqrt(len2)
}

func length(_ _v: VecFloat2) -> Float {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return sqrt(len2)
}

// Returns the square length |_v|^2 of _v.
func lengthSqr(_ _v: VecFloat4) -> Float {
    _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
}

func lengthSqr(_ _v: VecFloat3) -> Float {
    _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
}

func lengthSqr(_ _v: VecFloat2) -> Float {
    _v.x * _v.x + _v.y * _v.y
}

// Returns the normalized vector _v.
func normalize(_ _v: VecFloat4) -> VecFloat4 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    guard len2 != 0.0 else {
        fatalError("_v is not normalizable")
    }
    let len = sqrt(len2)
    return VecFloat4(_v.x / len, _v.y / len, _v.z / len, _v.w / len)
}

func normalize(_ _v: VecFloat3) -> VecFloat3 {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    guard len2 != 0.0 else {
        fatalError("_v is not normalizable")
    }
    let len = sqrt(len2)
    return VecFloat3(_v.x / len, _v.y / len, _v.z / len)
}

func normalize(_ _v: VecFloat2) -> VecFloat2 {
    let len2 = _v.x * _v.x + _v.y * _v.y
    guard len2 != 0.0 else {
        fatalError("_v is not normalizable")
    }
    let len = sqrt(len2)
    return VecFloat2(_v.x / len, _v.y / len)
}

// Returns true if _v is normalized.
func isNormalized(_ _v: VecFloat4) -> Bool {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    return abs(len2 - 1.0) < kNormalizationToleranceSq
}

func isNormalized(_ _v: VecFloat3) -> Bool {
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    return abs(len2 - 1.0) < kNormalizationToleranceSq
}

func isNormalized(_ _v: VecFloat2) -> Bool {
    let len2 = _v.x * _v.x + _v.y * _v.y
    return abs(len2 - 1.0) < kNormalizationToleranceSq
}

// Returns the normalized vector _v if the norm of _v is not 0.
// Otherwise returns _safer.
func normalizeSafe(_ _v: VecFloat4, _ _safer: VecFloat4) -> VecFloat4 {
    guard isNormalized(_safer) else {
        fatalError("_safer is not normalized")
    }
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z + _v.w * _v.w
    if (len2 <= 0.0) {
        return _safer
    }
    let len = sqrt(len2)
    return VecFloat4(_v.x / len, _v.y / len, _v.z / len, _v.w / len)
}

func normalizeSafe(_ _v: VecFloat3, _ _safer: VecFloat3) -> VecFloat3 {
    guard isNormalized(_safer) else {
        fatalError("_safer is not normalized")
    }
    let len2 = _v.x * _v.x + _v.y * _v.y + _v.z * _v.z
    if (len2 <= 0.0) {
        return _safer
    }
    let len = sqrt(len2)
    return VecFloat3(_v.x / len, _v.y / len, _v.z / len)
}

func normalizeSafe(_ _v: VecFloat2, _ _safer: VecFloat2) -> VecFloat2 {
    guard isNormalized(_safer) else {
        fatalError("_safer is not normalized")
    }
    let len2 = _v.x * _v.x + _v.y * _v.y
    if (len2 <= 0.0) {
        return _safer
    }
    let len = sqrt(len2)
    return VecFloat2(_v.x / len, _v.y / len)
}

// Returns the linear interpolation of _a and _b with coefficient _f.
// _f is not limited to range [0,1].
func lerp(_ _a: VecFloat4, _ _b: VecFloat4, _ _f: Float) -> VecFloat4 {
    VecFloat4((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z, (_b.w - _a.w) * _f + _a.w)
}

func lerp(_ _a: VecFloat3, _ _b: VecFloat3, _ _f: Float) -> VecFloat3 {
    VecFloat3((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y,
            (_b.z - _a.z) * _f + _a.z)
}

func lerp(_ _a: VecFloat2, _ _b: VecFloat2, _ _f: Float) -> VecFloat2 {
    VecFloat2((_b.x - _a.x) * _f + _a.x, (_b.y - _a.y) * _f + _a.y)
}

// Returns true if the distance between _a and _b is less than _tolerance.
func compare(_ _a: VecFloat4, _ _b: VecFloat4, _ _tolerance: Float) -> Bool {
    let diff = _a - _b
    return dot(diff, diff) <= _tolerance * _tolerance
}

func compare(_ _a: VecFloat3, _ _b: VecFloat3, _ _tolerance: Float) -> Bool {
    let diff = _a - _b
    return dot(diff, diff) <= _tolerance * _tolerance
}

func compare(_ _a: VecFloat2, _ _b: VecFloat2, _ _tolerance: Float) -> Bool {
    let diff = _a - _b
    return dot(diff, diff) <= _tolerance * _tolerance
}

// Returns true if each element of a is less than each element of _b.
func <(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x < _b.x && _a.y < _b.y && _a.z < _b.z && _a.w < _b.w
}

func <(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x < _b.x && _a.y < _b.y && _a.z < _b.z
}

func <(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x < _b.x && _a.y < _b.y
}

// Returns true if each element of a is less or equal to each element of _b.
func <=(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x <= _b.x && _a.y <= _b.y && _a.z <= _b.z && _a.w <= _b.w
}

func <=(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x <= _b.x && _a.y <= _b.y && _a.z <= _b.z
}

func <=(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x <= _b.x && _a.y <= _b.y
}

// Returns true if each element of a is greater than each element of _b.
func >(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x > _b.x && _a.y > _b.y && _a.z > _b.z && _a.w > _b.w
}

func >(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x > _b.x && _a.y > _b.y && _a.z > _b.z
}

func >(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x > _b.x && _a.y > _b.y
}

// Returns true if each element of a is greater or equal to each element of _b.
func >=(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x >= _b.x && _a.y >= _b.y && _a.z >= _b.z && _a.w >= _b.w
}

func >=(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x >= _b.x && _a.y >= _b.y && _a.z >= _b.z
}

func >=(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x >= _b.x && _a.y >= _b.y
}

// Returns true if each element of a is equal to each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func ==(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x == _b.x && _a.y == _b.y && _a.z == _b.z && _a.w == _b.w
}

func ==(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x == _b.x && _a.y == _b.y && _a.z == _b.z
}

func ==(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x == _b.x && _a.y == _b.y
}

// Returns true if each element of a is different from each element of _b.
// Uses a bitwise comparison of _a and _b, no tolerance is applied.
func !=(_a: VecFloat4, _b: VecFloat4) -> Bool {
    _a.x != _b.x || _a.y != _b.y || _a.z != _b.z || _a.w != _b.w
}

func !=(_a: VecFloat3, _b: VecFloat3) -> Bool {
    _a.x != _b.x || _a.y != _b.y || _a.z != _b.z
}

func !=(_a: VecFloat2, _b: VecFloat2) -> Bool {
    _a.x != _b.x || _a.y != _b.y
}

// Returns the minimum of each element of _a and _b.
func min(_ _a: VecFloat4, _ _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x < _b.x ? _a.x : _b.x, _a.y < _b.y ? _a.y : _b.y,
            _a.z < _b.z ? _a.z : _b.z, _a.w < _b.w ? _a.w : _b.w)
}

func min(_ _a: VecFloat3, _ _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x < _b.x ? _a.x : _b.x, _a.y < _b.y ? _a.y : _b.y,
            _a.z < _b.z ? _a.z : _b.z)
}

func min(_ _a: VecFloat2, _ _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x < _b.x ? _a.x : _b.x, _a.y < _b.y ? _a.y : _b.y)
}

// Returns the maximum of each element of _a and _b.
func max(_ _a: VecFloat4, _ _b: VecFloat4) -> VecFloat4 {
    VecFloat4(_a.x > _b.x ? _a.x : _b.x, _a.y > _b.y ? _a.y : _b.y,
            _a.z > _b.z ? _a.z : _b.z, _a.w > _b.w ? _a.w : _b.w)
}

func max(_ _a: VecFloat3, _ _b: VecFloat3) -> VecFloat3 {
    VecFloat3(_a.x > _b.x ? _a.x : _b.x, _a.y > _b.y ? _a.y : _b.y,
            _a.z > _b.z ? _a.z : _b.z)
}

func max(_ _a: VecFloat2, _ _b: VecFloat2) -> VecFloat2 {
    VecFloat2(_a.x > _b.x ? _a.x : _b.x, _a.y > _b.y ? _a.y : _b.y)
}

// Clamps each element of _x between _a and _b.
// _a must be less or equal to b
func clamp(_ _a: VecFloat4, _ _v: VecFloat4, _ _b: VecFloat4) -> VecFloat4 {
    let min = VecFloat4(_v.x < _b.x ? _v.x : _b.x, _v.y < _b.y ? _v.y : _b.y,
            _v.z < _b.z ? _v.z : _b.z, _v.w < _b.w ? _v.w : _b.w)
    return VecFloat4(_a.x > min.x ? _a.x : min.x, _a.y > min.y ? _a.y : min.y,
            _a.z > min.z ? _a.z : min.z, _a.w > min.w ? _a.w : min.w)
}

func clamp(_ _a: VecFloat3, _ _v: VecFloat3, _ _b: VecFloat3) -> VecFloat3 {
    let min = VecFloat3(_v.x < _b.x ? _v.x : _b.x, _v.y < _b.y ? _v.y : _b.y,
            _v.z < _b.z ? _v.z : _b.z)
    return VecFloat3(_a.x > min.x ? _a.x : min.x, _a.y > min.y ? _a.y : min.y,
            _a.z > min.z ? _a.z : min.z)
}

func clamp(_ _a: VecFloat2, _ _v: VecFloat2, _ _b: VecFloat2) -> VecFloat2 {
    let min = VecFloat2(_v.x < _b.x ? _v.x : _b.x, _v.y < _b.y ? _v.y : _b.y)
    return VecFloat2(_a.x > min.x ? _a.x : min.x, _a.y > min.y ? _a.y : min.y)
}
