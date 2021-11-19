//
//  math_constant.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/19.
//

import Foundation

// Defines math trigonometric constants.
let k2Pi: Float = 6.283185307179586476925286766559
let kPi: Float = 3.1415926535897932384626433832795
let kPi_2: Float = 1.5707963267948966192313216916398
let kPi_4: Float = 0.78539816339744830961566084581988
let kSqrt3: Float = 1.7320508075688772935274463415059
let kSqrt3_2: Float = 0.86602540378443864676372317075294
let kSqrt2: Float = 1.4142135623730950488016887242097
let kSqrt2_2: Float = 0.70710678118654752440084436210485

// Angle unit conversion constants.
let kDegreeToRadian: Float = kPi / 180.0
let kRadianToDegree: Float = 180.0 / kPi;

// Defines the square normalization tolerance value.
let kNormalizationToleranceSq: Float = 1e-6
let kNormalizationToleranceEstSq: Float = 2e-3

// Defines the square orthogonalisation tolerance value.
let kOrthogonalisationToleranceSq: Float = 1e-16
