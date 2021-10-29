//
//  InterpolationType.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Animation interpolation method.
enum InterpolationType {
    /// Linear interpolation
    case Linear
    /// Cubic spline interpolation
    case CubicSpine
    /// Stepped interpolation
    case Step
    /// Hermite interpolation
    case Hermite
}
