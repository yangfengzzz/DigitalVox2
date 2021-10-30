//
//  simd_math.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/30.
//

#ifndef simd_math_h
#define simd_math_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

// Vector of four floating point values.
typedef __m128 SimdFloat4;

// Argument type for Float4.
typedef const __m128 _SimdFloat4;

// Vector of four integer values.
typedef __m128i SimdInt4;

// Argument type for Int4.
typedef const __m128i _SimdInt4;

@interface OZZFloat4 : NSObject

/// Returns a +(SimdFloat4) vector with all components set to 0.
+ (SimdFloat4)zero;

/// Returns a +(SimdFloat4) vector with all components set to 1.
+ (SimdFloat4)one;

/// Returns a +(SimdFloat4) vector with the x component set to 1 and all the others to 0.
+ (SimdFloat4)x_axis;

/// Returns a +(SimdFloat4) vector with the y component set to 1 and all the others to 0.
+ (SimdFloat4)y_axis;

/// Returns a +(SimdFloat4) vector with the z component set to 1 and all the others to 0.
+ (SimdFloat4)z_axis;

/// Returns a +(SimdFloat4) vector with the w component set to 1 and all the others to 0.
+ (SimdFloat4)w_axis;

// Loads _x, _y, _z, _w to the returned vector.
// r.x = _x
// r.y = _y
// r.z = _z
// r.w = _w
+ (SimdFloat4)LoadWith:(float)_x :(float)_y :(float)_z :(float)_w;

// Loads _x to the x component of the returned vector, and sets y, z and w to 0.
// r.x = _x
// r.y = 0
// r.z = 0
// r.w = 0
+ (SimdFloat4)LoadXWith:(float)_x;

// Loads _x to the all the components of the returned vector.
// r.x = _x
// r.y = _x
// r.z = _x
// r.w = _x
+ (SimdFloat4)Load1With:(float)_x;

// Loads the 4 values of _f to the returned vector.
// _f must be aligned to 16 bytes.
// r.x = _f[0]
// r.y = _f[1]
// r.z = _f[2]
// r.w = _f[3]
+ (SimdFloat4)LoadPtrWith:(const float *)_f;

// Loads the 4 values of _f to the returned vector.
// _f must be aligned to 4 bytes.
// r.x = _f[0]
// r.y = _f[1]
// r.z = _f[2]
// r.w = _f[3]
+ (SimdFloat4)LoadPtrUWith:(const float *)_f;

// Loads _f[0] to the x component of the returned vector, and sets y, z and w
// to 0.
// _f must be aligned to 4 bytes.
// r.x = _f[0]
// r.y = 0
// r.z = 0
// r.w = 0
+ (SimdFloat4)LoadXPtrUWith:(const float *)_f;

// Loads _f[0] to all the components of the returned vector.
// _f must be aligned to 4 bytes.
// r.x = _f[0]
// r.y = _f[0]
// r.z = _f[0]
// r.w = _f[0]
+ (SimdFloat4)Load1PtrUWith:(const float *)_f;

// Loads the 2 first value of _f to the x and y components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 4 bytes.
// r.x = _f[0]
// r.y = _f[1]
// r.z = 0
// r.w = 0
+ (SimdFloat4)Load2PtrUWith:(const float *)_f;

// Loads the 3 first value of _f to the x, y and z components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 4 bytes.
// r.x = _f[0]
// r.y = _f[1]
// r.z = _f[2]
// r.w = 0
+ (SimdFloat4)Load3PtrUWith:(const float *)_f;

// Convert from integer to float.
+ (SimdFloat4)FromIntWith:(_SimdInt4)_i;

// Returns the x component of _v as a float.
+ (float)GetXWith:(_SimdFloat4)_v;

// Returns the y component of _v as a float.
+ (float)GetYWith:(_SimdFloat4)_v;

// Returns the z component of _v as a float.
+ (float)GetZWith:(_SimdFloat4)_v;

// Returns the w component of _v as a float.
+ (float)GetWWith:(_SimdFloat4)_v;

// Returns _v with the x component set to x component of _f.
+ (SimdFloat4)SetXWith:(_SimdFloat4)_v :(_SimdFloat4)_f;

// Returns _v with the y component set to  x component of _f.
+ (SimdFloat4)SetYWith:(_SimdFloat4)_v :(_SimdFloat4)_f;

// Returns _v with the z component set to  x component of _f.
+ (SimdFloat4)SetZWith:(_SimdFloat4)_v :(_SimdFloat4)_f;

// Returns _v with the w component set to  x component of _f.
+ (SimdFloat4)SetWWith:(_SimdFloat4)_v :(_SimdFloat4)_f;

// Returns _v with the _i th component set to _f.
// _i must be in range [0,3]
+ (SimdFloat4)SetIWith:(_SimdFloat4)_v :(_SimdFloat4)_f :(int)_i;

// Stores the 4 components of _v to the four first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
// _f[3] = _v.w
+ (void)StorePtrWith:(_SimdFloat4)_v :(float *)_f;

// Stores the x component of _v to the first float of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
+ (void)Store1PtrWith:(_SimdFloat4)_v :(float *)_f;

// Stores x and y components of _v to the two first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
+ (void)Store2PtrWith:(_SimdFloat4)_v :(float *)_f;

// Stores x, y and z components of _v to the three first floats of _f.
// _f must be aligned to 16 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
+ (void)Store3PtrWith:(_SimdFloat4)_v :(float *)_f;

// Stores the 4 components of _v to the four first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
// _f[3] = _v.w
+ (void)StorePtrUWith:(_SimdFloat4)_v :(float *)_f;

// Stores the x component of _v to the first float of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
+ (void)Store1PtrUWith:(_SimdFloat4)_v :(float *)_f;

// Stores x and y components of _v to the two first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
+ (void)Store2PtrUWith:(_SimdFloat4)_v :(float *)_f;

// Stores x, y and z components of _v to the three first floats of _f.
// _f must be aligned to 4 bytes.
// _f[0] = _v.x
// _f[1] = _v.y
// _f[2] = _v.z
+ (void)Store3PtrUWith:(_SimdFloat4)_v :(float *)_f;

// Replicates x of _a to all the components of the returned vector.
+ (SimdFloat4)SplatXWith:(_SimdFloat4)_v;

// Replicates y of _a to all the components of the returned vector.
+ (SimdFloat4)SplatYWith:(_SimdFloat4)_v;

// Replicates z of _a to all the components of the returned vector.
+ (SimdFloat4)SplatZWith:(_SimdFloat4)_v;

// Replicates w of _a to all the components of the returned vector.
+ (SimdFloat4)SplatWWith:(_SimdFloat4)_v;

// Swizzle x, y, z and w components based on compile time arguments _X, _Y, _Z
// and _W. Arguments can vary from 0 (x), to 3 (w).
+ (SimdFloat4)Swizzle0123With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0101With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2323With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0011With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2233With:(_SimdFloat4)_v;

// Transposes the x components of the 4 SimdFloat4 of _in into the 1
// SimdFloat4 of _out.
+ (void)Transpose4x1With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes x, y, z and w components of _in to the x components of _out.
// Remaining y, z and w are set to 0.
+ (void)Transpose1x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the 1 SimdFloat4 of _in into the x components of the 4
// SimdFloat4 of _out. Remaining y, z and w are set to 0.
+ (void)Transpose2x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the x and y components of the 4 SimdFloat4 of _in into the 2
// SimdFloat4 of _out.
+ (void)Transpose4x2With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the x, y and z components of the 4 SimdFloat4 of _in into the 3
// SimdFloat4 of _out.
+ (void)Transpose4x3With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the 3 SimdFloat4 of _in into the x, y and z components of the 4
// SimdFloat4 of _out. Remaining w are set to 0.
+ (void)Transpose3x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the 4 SimdFloat4 of _in into the 4 SimdFloat4 of _out.
+ (void)Transpose4x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Transposes the 16 SimdFloat4 of _in into the 16 SimdFloat4 of _out.
+ (void)Transpose16x16With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out;

// Multiplies _a and _b, then adds _c.
// v = (_a * _b) + _c
+ (SimdFloat4)MAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c;

// Multiplies _a and _b, then subs _c.
// v = (_a * _b) + _c
+ (SimdFloat4)MSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c;

// Multiplies _a and _b, negate it, then adds _c.
// v = -(_a * _b) + _c
+ (SimdFloat4)NMAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c;

// Multiplies _a and _b, negate it, then subs _c.
// v = -(_a * _b) + _c
+ (SimdFloat4)NMSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c;

// Divides the x component of _a by the _x component of _b and stores it in the
// x component of the returned vector. y, z, w of the returned vector are the
// same as _a respective components.
// r.x = _a.x / _b.x
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdFloat4)DivXWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Computes the (horizontal) addition of x and y components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdFloat4)HAdd2With:(_SimdFloat4)_v;

// Computes the (horizontal) addition of x, y and z components of _v. The result
// is stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y + _a.z
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdFloat4)HAdd3With:(_SimdFloat4)_v;

// Computes the (horizontal) addition of x and y components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y + _a.z + _a.w
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdFloat4)HAdd4With:(_SimdFloat4)_v;

// Computes the dot product of x and y components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are undefined.
// r.x = _a.x * _a.x + _a.y * _a.y
// r.y = ?
// r.z = ?
// r.w = ?
+ (SimdFloat4)Dot2With:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Computes the dot product of x, y and z components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are undefined.
// r.x = _a.x * _a.x + _a.y * _a.y + _a.z * _a.z
// r.y = ?
// r.z = ?
// r.w = ?
+ (SimdFloat4)Dot3With:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Computes the dot product of x, y, z and w components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are undefined.
// r.x = _a.x * _a.x + _a.y * _a.y + _a.z * _a.z + _a.w * _a.w
// r.y = ?
// r.z = ?
// r.w = ?
+ (SimdFloat4)Dot4With:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Computes the cross product of x, y and z components of _v. The result is
// stored in the x, y and z components of the returned value. w of the returned
// vector is undefined.
// r.x = _a.y * _b.z - _a.z * _b.y
// r.y = _a.z * _b.x - _a.x * _b.z
// r.z = _a.x * _b.y - _a.y * _b.x
// r.w = ?
+ (SimdFloat4)Cross3With:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Returns the per component estimated reciprocal of _v.
+ (SimdFloat4)RcpEstWith:(_SimdFloat4)_v;

// Returns the per component estimated reciprocal of _v, where approximation is
// improved with one more new Newton-Raphson step.
+ (SimdFloat4)RcpEstNRWith:(_SimdFloat4)_v;

// Returns the estimated reciprocal of the x component of _v and stores it in
// the x component of the returned vector. y, z, w of the returned vector are
// the same as their respective components in _v.
+ (SimdFloat4)RcpEstXWith:(_SimdFloat4)_v;

// Returns the estimated reciprocal of the x component of _v, where
// approximation is improved with one more new Newton-Raphson step. y, z, w of
// the returned vector are undefined.
+ (SimdFloat4)RcpEstXNRWith:(_SimdFloat4)_v;

// Returns the per component square root of _v.
+ (SimdFloat4)SqrtWith:(_SimdFloat4)_v;

// Returns the square root of the x component of _v and stores it in the x
// component of the returned vector. y, z, w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)SqrtXWith:(_SimdFloat4)_v;

// Returns the per component estimated reciprocal square root of _v.
+ (SimdFloat4)RSqrtEstWith:(_SimdFloat4)_v;

// Returns the per component estimated reciprocal square root of _v, where
// approximation is improved with one more new Newton-Raphson step.
+ (SimdFloat4)RSqrtEstNRWith:(_SimdFloat4)_v;

// Returns the estimated reciprocal square root of the x component of _v and
// stores it in the x component of the returned vector. y, z, w of the returned
// vector are the same as their respective components in _v.
+ (SimdFloat4)RSqrtEstXWith:(_SimdFloat4)_v;

// Returns the estimated reciprocal square root of the x component of _v, where
// approximation is improved with one more new Newton-Raphson step. y, z, w of
// the returned vector are undefined.
+ (SimdFloat4)RSqrtEstXNRWith:(_SimdFloat4)_v;

// Returns the per element absolute value of _v.
+ (SimdFloat4)AbsWith:(_SimdFloat4)_v;

// Returns the sign bit of _v.
+ (SimdInt4)SignWith:(_SimdFloat4)_v;

// Returns the per component minimum of _a and _b.
+ (SimdFloat4)MinWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Returns the per component maximum of _a and _b.
+ (SimdFloat4)MaxWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Returns the per component maximum of _v and 0.
+ (SimdFloat4)Max0With:(_SimdFloat4)_v;

// Clamps each element of _x between _a and _b.
// Result is unknown if _a is not less or equal to _b.
+ (SimdFloat4)ClampWith:(_SimdFloat4)_a :(_SimdFloat4)_v :(_SimdFloat4)_b;

// Computes the length of the components x and y of _v, and stores it in the x
// component of the returned vector. y, z, w of the returned vector are
// undefined.
+ (SimdFloat4)Length2With:(_SimdFloat4)_v;

// Computes the length of the components x, y and z of _v, and stores it in the
// x component of the returned vector. undefined.
+ (SimdFloat4)Length3With:(_SimdFloat4)_v;

// Computes the length of _v, and stores it in the x component of the returned
// vector. y, z, w of the returned vector are undefined.
+ (SimdFloat4)Length4With:(_SimdFloat4)_v;

// Computes the square length of the components x and y of _v, and stores it
// in the x component of the returned vector. y, z, w of the returned vector are
// undefined.
+ (SimdFloat4)Length2SqrWith:(_SimdFloat4)_v;

// Computes the square length of the components x, y and z of _v, and stores it
// in the x component of the returned vector. y, z, w of the returned vector are
// undefined.
+ (SimdFloat4)Length3SqrWith:(_SimdFloat4)_v;

// Computes the square length of the components x, y, z and w of _v, and stores
// it in the x component of the returned vector. y, z, w of the returned vector
// undefined.
+ (SimdFloat4)Length4SqrWith:(_SimdFloat4)_v;

// Returns the normalized vector of the components x and y of _v, and stores
// it in the x and y components of the returned vector. z and w of the returned
// vector are the same as their respective components in _v.
+ (SimdFloat4)Normalize2With:(_SimdFloat4)_v;

// Returns the normalized vector of the components x, y and z of _v, and stores
// it in the x, y and z components of the returned vector. w of the returned
// vector is the same as its respective component in _v.
+ (SimdFloat4)Normalize3With:(_SimdFloat4)_v;

// Returns the normalized vector _v.
+ (SimdFloat4)Normalize4With:(_SimdFloat4)_v;

// Returns the estimated normalized vector of the components x and y of _v, and
// stores it in the x and y components of the returned vector. z and w of the
// returned vector are the same as their respective components in _v.
+ (SimdFloat4)NormalizeEst2With:(_SimdFloat4)_v;

// Returns the estimated normalized vector of the components x, y and z of _v,
// and stores it in the x, y and z components of the returned vector. w of the
// returned vector is the same as its respective component in _v.
+ (SimdFloat4)NormalizeEst3With:(_SimdFloat4)_v;

// Returns the estimated normalized vector _v.
+ (SimdFloat4)NormalizeEst4With:(_SimdFloat4)_v;

// Tests if the components x and y of _v forms a normalized vector.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalized2With:(_SimdFloat4)_v;

// Tests if the components x, y and z of _v forms a normalized vector.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalized3With:(_SimdFloat4)_v;

// Tests if the _v is a normalized vector.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalized4With:(_SimdFloat4)_v;

// Tests if the components x and y of _v forms a normalized vector.
// Uses the estimated normalization coefficient, that matches estimated math
// functions (RecpEst, MormalizeEst...).
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalizedEst2With:(_SimdFloat4)_v;

// Tests if the components x, y and z of _v forms a normalized vector.
// Uses the estimated normalization coefficient, that matches estimated math
// functions (RecpEst, MormalizeEst...).
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalizedEst3With:(_SimdFloat4)_v;

// Tests if the _v is a normalized vector.
// Uses the estimated normalization coefficient, that matches estimated math
// functions (RecpEst, MormalizeEst...).
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsNormalizedEst4With:(_SimdFloat4)_v;

// Returns the normalized vector of the components x and y of _v if it is
// normalizable, otherwise returns _safe. z and w of the returned vector are
// the same as their respective components in _v.
+ (SimdFloat4)NormalizeSafe2With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Returns the normalized vector of the components x, y, z and w of _v if it is
// normalizable, otherwise returns _safe. w of the returned vector is the same
// as its respective components in _v.
+ (SimdFloat4)NormalizeSafe3With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Returns the normalized vector _v if it is normalizable, otherwise returns
// _safe.
+ (SimdFloat4)NormalizeSafe4With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Returns the estimated normalized vector of the components x and y of _v if it
// is normalizable, otherwise returns _safe. z and w of the returned vector are
// the same as their respective components in _v.
+ (SimdFloat4)NormalizeSafeEst2With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Returns the estimated normalized vector of the components x, y, z and w of _v
// if it is normalizable, otherwise returns _safe. w of the returned vector is
// the same as its respective components in _v.
+ (SimdFloat4)NormalizeSafeEst3With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Returns the estimated normalized vector _v if it is normalizable, otherwise
// returns _safe.
+ (SimdFloat4)NormalizeSafeEst4With:(_SimdFloat4)_v :(_SimdFloat4)_safe;

// Computes the per element linear interpolation of _a and _b, where _alpha is
// not bound to range [0,1].
+ (SimdFloat4)LerpWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_alpha;

// Computes the per element cosine of _v.
+ (SimdFloat4)CosWith:(_SimdFloat4)_v;

// Computes the cosine of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)CosXWith:(_SimdFloat4)_v;

// Computes the per element arccosine of _v.
+ (SimdFloat4)ACosWith:(_SimdFloat4)_v;

// Computes the arccosine of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)ACosXWith:(_SimdFloat4)_v;

// Computes the per element sines of _v.
+ (SimdFloat4)SinWith:(_SimdFloat4)_v;

// Computes the sines of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)SinXWith:(_SimdFloat4)_v;

// Computes the per element arcsine of _v.
+ (SimdFloat4)ASinWith:(_SimdFloat4)_v;

// Computes the arcsine of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)ASinXWith:(_SimdFloat4)_v;

// Computes the per element tangent of _v.
+ (SimdFloat4)TanWith:(_SimdFloat4)_v;

// Computes the tangent of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)TanXWith:(_SimdFloat4)_v;

// Computes the per element arctangent of _v.
+ (SimdFloat4)ATanWith:(_SimdFloat4)_v;

// Computes the arctangent of the x component of _v and stores it in the x
// component of the returned vector. y, z and w of the returned vector are the
// same as their respective components in _v.
+ (SimdFloat4)ATanXWith:(_SimdFloat4)_v;

// Returns boolean selection of vectors _true and _false according to condition
// _b. All bits a each component of _b must have the same value (O or
// 0xffffffff) to ensure portability.
+ (SimdFloat4)SelectWith:(_SimdInt4)_b :(_SimdFloat4)_true :(_SimdFloat4)_false;

// Per element "equal" comparison of _a and _b.
+ (SimdInt4)CmpEqWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Per element "not equal" comparison of _a and _b.
+ (SimdInt4)CmpNeWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Per element "less than" comparison of _a and _b.
+ (SimdInt4)CmpLtWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Per element "less than or equal" comparison of _a and _b.
+ (SimdInt4)CmpLeWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Per element "greater than" comparison of _a and _b.
+ (SimdInt4)CmpGtWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Per element "greater than or equal" comparison of _a and _b.
+ (SimdInt4)CmpGeWith:(_SimdFloat4)_a :(_SimdFloat4)_b;

// Returns per element binary and operation of _a and _b.
// _v[0...127] = _a[0...127] & _b[0...127]
+ (SimdFloat4)AndWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b;

// Returns per element binary or operation of _a and _b.
// _v[0...127] = _a[0...127] | _b[0...127]
+ (SimdFloat4)OrWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b;

// Returns per element binary logical xor operation of _a and _b.
// _v[0...127] = _a[0...127] ^ _b[0...127]
+ (SimdFloat4)XorWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b;

// Returns per element binary and operation of _a and _b.
// _v[0...127] = _a[0...127] & _b[0...127]
+ (SimdFloat4)AndWith:(_SimdFloat4)_a int4:(_SimdInt4)_b;

// Returns per element binary and operation of _a and ~_b.
// _v[0...127] = _a[0...127] & ~_b[0...127]
+ (SimdFloat4)AndNotWith:(_SimdFloat4)_a :(_SimdInt4)_b;

// Returns per element binary or operation of _a and _b.
// _v[0...127] = _a[0...127] | _b[0...127]
+ (SimdFloat4)OrWith:(_SimdFloat4)_a int4:(_SimdInt4)_b;

// Returns per element binary logical xor operation of _a and _b.
// _v[0...127] = _a[0...127] ^ _b[0...127]
+ (SimdFloat4)XorWith:(_SimdFloat4)_a int4:(_SimdInt4)_b;

@end

@interface OZZInt4 : NSObject
// Returns a SimdInt4 vector with all components set to 0.
+ (SimdInt4)zero;
@end

#endif /* simd_math_h */
