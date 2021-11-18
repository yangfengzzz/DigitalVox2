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
#import "soa_float.h"

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
+ (SimdFloat4)Swizzle3332With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0122With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0120With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle3330With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle1201With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2011With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2013With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle1203With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0123With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0101With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2323With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle0011With:(_SimdFloat4)_v;

+ (SimdFloat4)Swizzle2233With:(_SimdFloat4)_v;

// Transposes the x components of the 4 SimdFloat4 of _in into the 1
// SimdFloat4 of _out.
+ (void)Transpose4x1With:(const SimdFloat4[4])_in :(SimdFloat4[1])_out;

// Transposes x, y, z and w components of _in to the x components of _out.
// Remaining y, z and w are set to 0.
+ (void)Transpose1x4With:(const SimdFloat4[1])_in :(SimdFloat4[4])_out;

// Transposes the 1 SimdFloat4 of _in into the x components of the 4
// SimdFloat4 of _out. Remaining y, z and w are set to 0.
+ (void)Transpose2x4With:(const SimdFloat4[2])_in :(SimdFloat4[4])_out;

// Transposes the x and y components of the 4 SimdFloat4 of _in into the 2
// SimdFloat4 of _out.
+ (void)Transpose4x2With:(const SimdFloat4[4])_in :(SimdFloat4[2])_out;

// Transposes the x, y and z components of the 4 SimdFloat4 of _in into the 3
// SimdFloat4 of _out.
+ (void)Transpose4x3With:(const SimdFloat4[4])_in :(struct SoaFloat3[1])_out;

// Transposes the 3 SimdFloat4 of _in into the x, y and z components of the 4
// SimdFloat4 of _out. Remaining w are set to 0.
+ (void)Transpose3x4With:(const struct SoaFloat3[1])_in :(SimdFloat4[4])_out;

// Transposes the 4 SimdFloat4 of _in into the 4 SimdFloat4 of _out.
+ (void)Transpose4x4With:(const SimdFloat4[4])_in toQuat:(struct SoaQuaternion[1])_out;

+ (void)Transpose4x4FromQuat:(const struct SoaQuaternion[1])_in :(SimdFloat4[4])_out;

// Transposes the 16 SimdFloat4 of _in into the 16 SimdFloat4 of _out.
+ (void)Transpose16x16With:(const struct SoaFloat4x4[1])_in :(simd_float4x4[4])_out;

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

// Returns the per component minimum of _v and 0.
+ (SimdFloat4)Min0With:(_SimdFloat4)_v;

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

//MARK: - OZZInt4
@interface OZZInt4 : NSObject
// Returns a SimdInt4 vector with all components set to 0.
+ (SimdInt4)zero;

// Returns a SimdInt4 vector with all components set to 1.
+ (SimdInt4)one;

// Returns a SimdInt4 vector with the x component set to 1 and all the others
// to 0.
+ (SimdInt4)x_axis;

// Returns a SimdInt4 vector with the y component set to 1 and all the others
// to 0.
+ (SimdInt4)y_axis;

// Returns a SimdInt4 vector with the z component set to 1 and all the others
// to 0.
+ (SimdInt4)z_axis;

// Returns a SimdInt4 vector with the w component set to 1 and all the others
// to 0.
+ (SimdInt4)w_axis;

// Returns a SimdInt4 vector with all components set to true (0xffffffff).
+ (SimdInt4)all_true;

// Returns a SimdInt4 vector with all components set to false (0).
+ (SimdInt4)all_false;

// Returns a SimdInt4 vector with sign bits set to 1.
+ (SimdInt4)mask_sign;

// Returns a SimdInt4 vector with all bits set to 1 except sign.
+ (SimdInt4)mask_not_sign;

// Returns a SimdInt4 vector with sign bits of x, y and z components set to 1.
+ (SimdInt4)mask_sign_xyz;

// Returns a SimdInt4 vector with sign bits of w component set to 1.
+ (SimdInt4)mask_sign_w;

// Returns a SimdInt4 vector with all bits set to 1.
+ (SimdInt4)mask_ffff;

// Returns a SimdInt4 vector with all bits set to 0.
+ (SimdInt4)mask_0000;

// Returns a SimdInt4 vector with all the bits of the x, y, z components set to
// 1, while z is set to 0.
+ (SimdInt4)mask_fff0;

// Returns a SimdInt4 vector with all the bits of the x component set to 1,
// while the others are set to 0.
+ (SimdInt4)mask_f000;

// Returns a SimdInt4 vector with all the bits of the y component set to 1,
// while the others are set to 0.
+ (SimdInt4)mask_0f00;

// Returns a SimdInt4 vector with all the bits of the z component set to 1,
// while the others are set to 0.
+ (SimdInt4)mask_00f0;

// Returns a SimdInt4 vector with all the bits of the w component set to 1,
// while the others are set to 0.
+ (SimdInt4)mask_000f;

// Loads _x, _y, _z, _w to the returned vector.
// r.x = _x
// r.y = _y
// r.z = _z
// r.w = _w
+ (SimdInt4)LoadWithInt:(int)_x :(int)_y :(int)_z :(int)_w;

// Loads _x, _y, _z, _w to the returned vector using the following conversion
// rule.
// r.x = _x ? 0xffffffff:0
// r.y = _y ? 0xffffffff:0
// r.z = _z ? 0xffffffff:0
// r.w = _w ? 0xffffffff:0
+ (SimdInt4)LoadWithBool:(bool)_x :(bool)_y :(bool)_z :(bool)_w;

// Loads _x to the x component of the returned vector using the following
// conversion rule, and sets y, z and w to 0.
// r.x = _x ? 0xffffffff:0
// r.y = 0
// r.z = 0
// r.w = 0
+ (SimdInt4)LoadXWithBool:(bool)_x;

+ (SimdInt4)LoadXWithInt:(int)_x;

// Loads _x to the all the components of the returned vector using the following
// conversion rule.
// r.x = _x ? 0xffffffff:0
// r.y = _x ? 0xffffffff:0
// r.z = _x ? 0xffffffff:0
// r.w = _x ? 0xffffffff:0
+ (SimdInt4)Load1WithBool:(bool)_x;

+ (SimdInt4)Load1WithInt:(int)_x;

// Loads the 4 values of _f to the returned vector.
// _i must be aligned to 16 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = _i[2]
// r.w = _i[3]
+ (SimdInt4)LoadPtrWith:(const int *)_i;

// Loads _i[0] to the x component of the returned vector, and sets y, z and w
// to 0.
// _i must be aligned to 16 bytes.
// r.x = _i[0]
// r.y = 0
// r.z = 0
// r.w = 0
+ (SimdInt4)LoadXPtrWith:(const int *)_i;

// Loads _i[0] to all the components of the returned vector.
// _i must be aligned to 16 bytes.
// r.x = _i[0]
// r.y = _i[0]
// r.z = _i[0]
// r.w = _i[0]
+ (SimdInt4)Load1PtrWith:(const int *)_i;

// Loads the 2 first value of _i to the x and y components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 4 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = 0
// r.w = 0
+ (SimdInt4)Load2PtrWith:(const int *)_i;

// Loads the 3 first value of _i to the x, y and z components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 16 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = _i[2]
// r.w = 0
+ (SimdInt4)Load3PtrWith:(const int *)_i;

// Loads the 4 values of _f to the returned vector.
// _i must be aligned to 16 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = _i[2]
// r.w = _i[3]
+ (SimdInt4)LoadPtrUWith:(const int *)_i;

// Loads _i[0] to the x component of the returned vector, and sets y, z and w
// to 0.
// _f must be aligned to 4 bytes.
// r.x = _i[0]
// r.y = 0
// r.z = 0
// r.w = 0
+ (SimdInt4)LoadXPtrUWith:(const int *)_i;

// Loads the 4 values of _i to the returned vector.
// _i must be aligned to 4 bytes.
// r.x = _i[0]
// r.y = _i[0]
// r.z = _i[0]
// r.w = _i[0]
+ (SimdInt4)Load1PtrUWith:(const int *)_i;

// Loads the 2 first value of _i to the x and y components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 4 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = 0
// r.w = 0
+ (SimdInt4)Load2PtrUWith:(const int *)_i;

// Loads the 3 first value of _i to the x, y and z components of the returned
// vector. The remaining components are set to 0.
// _f must be aligned to 4 bytes.
// r.x = _i[0]
// r.y = _i[1]
// r.z = _i[2]
// r.w = 0
+ (SimdInt4)Load3PtrUWith:(const int *)_i;

// Convert from float to integer by rounding the nearest value.
+ (SimdInt4)FromFloatRoundWith:(_SimdFloat4)_f;

// Convert from float to integer by truncating.
+ (SimdInt4)FromFloatTruncWith:(_SimdFloat4)_f;

// Returns the x component of _v as an integer.
+ (int)GetXWith:(_SimdInt4)_v;

// Returns the y component of _v as a integer.
+ (int)GetYWith:(_SimdInt4)_v;

// Returns the z component of _v as a integer.
+ (int)GetZWith:(_SimdInt4)_v;

// Returns the w component of _v as a integer.
+ (int)GetWWith:(_SimdInt4)_v;

// Returns _v with the x component set to x component of _i.
+ (SimdInt4)SetXWith:(_SimdInt4)_v :(_SimdInt4)_i;

// Returns _v with the y component set to x component of _i.
+ (SimdInt4)SetYWith:(_SimdInt4)_v :(_SimdInt4)_i;

// Returns _v with the z component set to x component of _i.
+ (SimdInt4)SetZWith:(_SimdInt4)_v :(_SimdInt4)_i;

// Returns _v with the w component set to x component of _i.
+ (SimdInt4)SetWWith:(_SimdInt4)_v :(_SimdInt4)_i;

// Returns _v with the _ith component set to _i.
// _i must be in range [0,3]
+ (SimdInt4)SetIWith:(_SimdInt4)_v :(_SimdInt4)_i :(int)_ith;

// Stores the 4 components of _v to the four first integers of _i.
// _i must be aligned to 16 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
// _i[2] = _v.z
// _i[3] = _v.w
+ (void)StorePtrWith:(_SimdInt4)_v :(int *)_i;

// Stores the x component of _v to the first integers of _i.
// _i must be aligned to 16 bytes.
// _i[0] = _v.x
+ (void)Store1PtrWith:(_SimdInt4)_v :(int *)_i;

// Stores x and y components of _v to the two first integers of _i.
// _i must be aligned to 16 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
+ (void)Store2PtrWith:(_SimdInt4)_v :(int *)_i;

// Stores x, y and z components of _v to the three first integers of _i.
// _i must be aligned to 16 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
// _i[2] = _v.z
+ (void)Store3PtrWith:(_SimdInt4)_v :(int *)_i;

// Stores the 4 components of _v to the four first integers of _i.
// _i must be aligned to 4 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
// _i[2] = _v.z
// _i[3] = _v.w
+ (void)StorePtrUWith:(_SimdInt4)_v :(int *)_i;

// Stores the x component of _v to the first float of _i.
// _i must be aligned to 4 bytes.
// _i[0] = _v.x
+ (void)Store1PtrUWith:(_SimdInt4)_v :(int *)_i;

// Stores x and y components of _v to the two first integers of _i.
// _i must be aligned to 4 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
+ (void)Store2PtrUWith:(_SimdInt4)_v :(int *)_i;

// Stores x, y and z components of _v to the three first integers of _i.
// _i must be aligned to 4 bytes.
// _i[0] = _v.x
// _i[1] = _v.y
// _i[2] = _v.z
+ (void)Store3PtrUWith:(_SimdInt4)_v :(int *)_i;

// Replicates x of _a to all the components of the returned vector.
+ (SimdInt4)SplatXWith:(_SimdInt4)_v;

// Replicates y of _a to all the components of the returned vector.
+ (SimdInt4)SplatYWith:(_SimdInt4)_v;

// Replicates z of _a to all the components of the returned vector.
+ (SimdInt4)SplatZWith:(_SimdInt4)_v;

// Replicates w of _a to all the components of the returned vector.
+ (SimdInt4)SplatWWith:(_SimdInt4)_v;

// Swizzle x, y, z and w components based on compile time arguments _X, _Y, _Z
// and _W. Arguments can vary from 0 (x), to 3 (w).
+ (SimdInt4)Swizzle0123With:(_SimdInt4)_v;

// Creates a 4-bit mask from the most significant bits of each component of _v.
// i := sign(a3)<<3 | sign(a2)<<2 | sign(a1)<<1 | sign(a0)
+ (int)MoveMaskWith:(_SimdInt4)_v;

// Returns true if all the components of _v are not 0.
+ (bool)AreAllTrueWith:(_SimdInt4)_v;

// Returns true if x, y and z components of _v are not 0.
+ (bool)AreAllTrue3With:(_SimdInt4)_v;

// Returns true if x and y components of _v are not 0.
+ (bool)AreAllTrue2With:(_SimdInt4)_v;

// Returns true if x component of _v is not 0.
+ (bool)AreAllTrue1With:(_SimdInt4)_v;

// Returns true if all the components of _v are 0.
+ (bool)AreAllFalseWith:(_SimdInt4)_v;

// Returns true if x, y and z components of _v are 0.
+ (bool)AreAllFalse3With:(_SimdInt4)_v;

// Returns true if x and y components of _v are 0.
+ (bool)AreAllFalse2With:(_SimdInt4)_v;

// Returns true if x component of _v is 0.
+ (bool)AreAllFalse1With:(_SimdInt4)_v;

// Computes the (horizontal) addition of x and y components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdInt4)HAdd2With:(_SimdInt4)_v;

// Computes the (horizontal) addition of x, y and z components of _v. The result
// is stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y + _a.z
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdInt4)HAdd3With:(_SimdInt4)_v;

// Computes the (horizontal) addition of x and y components of _v. The result is
// stored in the x component of the returned value. y, z, w of the returned
// vector are the same as their respective components in _v.
// r.x = _a.x + _a.y + _a.z + _a.w
// r.y = _a.y
// r.z = _a.z
// r.w = _a.w
+ (SimdInt4)HAdd4With:(_SimdInt4)_v;

// Returns the per element absolute value of _v.
+ (SimdInt4)AbsWith:(_SimdInt4)_v;

// Returns the sign bit of _v.
+ (SimdInt4)SignWith:(_SimdInt4)_v;

// Returns the per component minimum of _a and _b.
+ (SimdInt4)MinWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns the per component maximum of _a and _b.
+ (SimdInt4)MaxWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns the per component minimum of _v and 0.
+ (SimdInt4)Min0With:(_SimdInt4)_v;

// Returns the per component maximum of _v and 0.
+ (SimdInt4)Max0With:(_SimdInt4)_v;

// Clamps each element of _x between _a and _b.
// Result is unknown if _a is not less or equal to _b.
+ (SimdInt4)ClampWith:(_SimdInt4)_a :(_SimdInt4)_v :(_SimdInt4)_b;

// Returns boolean selection of vectors _true and _false according to consition
// _b. All bits a each component of _b must have the same value (O or
// 0xffffffff) to ensure portability.
+ (SimdInt4)SelectWith:(_SimdInt4)_b :(_SimdInt4)_true :(_SimdInt4)_false;

// Returns per element binary and operation of _a and _b.
// _v[0...127] = _a[0...127] & _b[0...127]
+ (SimdInt4)AndWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns per element binary and operation of _a and ~_b.
// _v[0...127] = _a[0...127] & ~_b[0...127]
+ (SimdInt4)AndNotWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns per element binary or operation of _a and _b.
// _v[0...127] = _a[0...127] | _b[0...127]
+ (SimdInt4)OrWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns per element binary logical xor operation of _a and _b.
// _v[0...127] = _a[0...127] ^ _b[0...127]
+ (SimdInt4)XorWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Returns per element binary complement of _v.
// _v[0...127] = ~_b[0...127]
+ (SimdInt4)NotWith:(_SimdInt4)_v;

// Shifts the 4 signed or unsigned 32-bit integers in a left by count _bits
// while shifting in zeros.
+ (SimdInt4)ShiftLWith:(_SimdInt4)_v :(int)_bits;

// Shifts the 4 signed 32-bit integers in a right by count bits while shifting
// in the sign bit.
+ (SimdInt4)ShiftRWith:(_SimdInt4)_v :(int)_bits;

// Shifts the 4 signed or unsigned 32-bit integers in a right by count bits
// while shifting in zeros.
+ (SimdInt4)ShiftRuWith:(_SimdInt4)_v :(int)_bits;

// Per element "equal" comparison of _a and _b.
+ (SimdInt4)CmpEqWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Per element "not equal" comparison of _a and _b.
+ (SimdInt4)CmpNeWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Per element "less than" comparison of _a and _b.
+ (SimdInt4)CmpLtWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Per element "less than or equal" comparison of _a and _b.
+ (SimdInt4)CmpLeWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Per element "greater than" comparison of _a and _b.
+ (SimdInt4)CmpGtWith:(_SimdInt4)_a :(_SimdInt4)_b;

// Per element "greater than or equal" comparison of _a and _b.
+ (SimdInt4)CmpGeWith:(_SimdInt4)_a :(_SimdInt4)_b;

@end

//MARK: - Float4x4
// Declare the 4x4 matrix type. Uses the column major convention where the
// matrix-times-vector is written v'=Mv:
// [ m.cols[0].x m.cols[1].x m.cols[2].x m.cols[3].x ]   {v.x}
// | m.cols[0].y m.cols[1].y m.cols[2].y m.cols[3].y | * {v.y}
// | m.cols[0].z m.cols[1].y m.cols[2].y m.cols[3].y |   {v.z}
// [ m.cols[0].w m.cols[1].w m.cols[2].w m.cols[3].w ]   {v.1}
@interface OZZFloat4x4 : NSObject

// Returns the identity matrix.
+ (simd_float4x4)identity;

// Returns a translation matrix.
// _v.w is ignored.
+ (simd_float4x4)TranslationWith:(_SimdFloat4)_v;

// Returns a scaling matrix that scales along _v.
// _v.w is ignored.
+ (simd_float4x4)ScalingWith:(_SimdFloat4)_v;

// Returns the rotation matrix built from Euler angles defined by x, y and z
// components of _v. Euler angles are ordered Heading, Elevation and Bank, or
// Yaw, Pitch and Roll. _v.w is ignored.
+ (simd_float4x4)FromEulerWith:(_SimdFloat4)_v;

// Returns the rotation matrix built from axis defined by _axis.xyz and
// _angle.x
+ (simd_float4x4)FromAxisAngleWith
        :(_SimdFloat4)_axis
        :(_SimdFloat4)_angle;

// Returns the rotation matrix built from quaternion defined by x, y, z and w
// components of _v.
+ (simd_float4x4)FromQuaternionWith:(_SimdFloat4)_v;

// Returns the affine transformation matrix built from split translation,
// rotation (quaternion) and scale.
+ (simd_float4x4)FromAffineWith
        :(_SimdFloat4)_translation
        :(_SimdFloat4)_quaternion
        :(_SimdFloat4)_scale;

// Returns the transpose of matrix _m.
+ (simd_float4x4)TransposeWith:(simd_float4x4)_m;

// Returns the inverse of matrix _m.
// If _invertible is not nullptr, its x component will be set to true if matrix is
// invertible. If _invertible is nullptr, then an assert is triggered in case the
// matrix isn't invertible.
+ (simd_float4x4)InvertWith:(simd_float4x4)_m :(SimdInt4 *)_invertible;

// Translates matrix _m along the axis defined by _v components.
// _v.w is ignored.
+ (simd_float4x4)TranslateWith:(simd_float4x4)_m :(_SimdFloat4)_v;

// Scales matrix _m along each axis with x, y, z components of _v.
// _v.w is ignored.
+ (simd_float4x4)ScaleWith:(simd_float4x4)_m :(_SimdFloat4)_v;

// Multiply each column of matrix _m with vector _v.
+ (simd_float4x4)ColumnMultiplyWith:(simd_float4x4)_m :(_SimdFloat4)_v;

// Tests if each 3 column of upper 3x3 matrix of _m is a normal matrix.
// Returns the result in the x, y and z component of the returned vector. w is
// set to 0.
+ (SimdInt4)IsNormalizedWith:(simd_float4x4)_m;

// Tests if each 3 column of upper 3x3 matrix of _m is a normal matrix.
// Uses the estimated tolerance
// Returns the result in the x, y and z component of the returned vector. w is
// set to 0.
+ (SimdInt4)IsNormalizedEstWith:(simd_float4x4)_m;

// Tests if the upper 3x3 matrix of _m is an orthogonal matrix.
// A matrix that contains a reflexion cannot be considered orthogonal.
// Returns the result in the x component of the returned vector. y, z and w are
// set to 0.
+ (SimdInt4)IsOrthogonalWith:(simd_float4x4)_m;

// Returns the quaternion that represent the rotation of matrix _m.
// _m must be normalized and orthogonal.
// the return quaternion is normalized.
+ (SimdFloat4)ToQuaternionWith:(simd_float4x4)_m;

// Decompose a general 3D transformation matrix _m into its scalar, rotational
// and translational components.
// Returns false if it was not possible to decompose the matrix. This would be
// because more than 1 of the 3 first column of _m are scaled to 0.
+ (bool)ToAffineWith:(simd_float4x4)_m :(SimdFloat4 *)_translation
        :(SimdFloat4 *)_quaternion :(SimdFloat4 *)_scale;

// Computes the transformation of a Float4x4 matrix and a point _p.
// This is equivalent to multiplying a matrix by a SimdFloat4 with a w component
// of 1.
+ (SimdFloat4)TransformPointWith:(simd_float4x4)_m
        :(_SimdFloat4)_v;

// Computes the transformation of a Float4x4 matrix and a vector _v.
// This is equivalent to multiplying a matrix by a SimdFloat4 with a w component
// of 0.
+ (SimdFloat4)TransformVectorWith:(simd_float4x4)_m
        :(_SimdFloat4)_v;

// Computes the multiplication of matrix Float4x4 and vector _v.
+ (SimdFloat4)MulWith:(simd_float4x4)_m
                  vec:(_SimdFloat4)_v;

// Computes the multiplication of two matrices _a and _b.
+ (simd_float4x4)MulWith:(simd_float4x4)_a
                     mat:(simd_float4x4)_b;

// Computes the per element addition of two matrices _a and _b.
+ (simd_float4x4)AddWith:(simd_float4x4)_a
        :(simd_float4x4)_b;

// Computes the per element subtraction of two matrices _a and _b.
+ (simd_float4x4)SubWith:(simd_float4x4)_a
        :(simd_float4x4)_b;

@end

@interface OZZMath : NSObject

// Converts from a float to a half.
+ (uint16_t)FloatToHalfWith:(float)_f;

// Converts from a half to a float.
+ (float)HalfToFloatWith:(uint16_t)_h;

// Converts from a float to a half.
+ (SimdInt4)FloatToHalfWithSIMD:(_SimdFloat4)_f;

// Converts from a half to a float.
+ (SimdFloat4)HalfToFloatWithSIMD:(_SimdInt4)_h;

+ (int)FloatCastI32:(float)_f;

+ (uint)FloatCastU32:(float)_f;

@end

// Declare the Quaternion type.
struct SimdQuaternion {
    SimdFloat4 xyzw;
};

#endif /* simd_math_h */
