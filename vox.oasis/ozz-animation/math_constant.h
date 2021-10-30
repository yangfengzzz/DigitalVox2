//
//  math_constant.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/30.
//

#ifndef math_constant_h
#define math_constant_h

// Defines math trigonometric constants.
static const float k2Pi = 6.283185307179586476925286766559f;
static const float kPi = 3.1415926535897932384626433832795f;
static const float kPi_2 = 1.5707963267948966192313216916398f;
static const float kPi_4 = .78539816339744830961566084581988f;
static const float kSqrt3 = 1.7320508075688772935274463415059f;
static const float kSqrt3_2 = 0.86602540378443864676372317075294f;
static const float kSqrt2 = 1.4142135623730950488016887242097f;
static const float kSqrt2_2 = 0.70710678118654752440084436210485f;

// Angle unit conversion constants.
static const float kDegreeToRadian = kPi / 180.f;
static const float kRadianToDegree = 180.f / kPi;

// Defines the square normalization tolerance value.
static const float kNormalizationToleranceSq = 1e-6f;
static const float kNormalizationToleranceEstSq = 2e-3f;

// Defines the square orthogonalisation tolerance value.
static const float kOrthogonalisationToleranceSq = 1e-16f;

#endif /* math_constant_h */
