//
//  DiffuseMode.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Diffuse mode.
enum DiffuseMode {
    /// Solid color mode.
    case SolidColor

    /// SH mode
    /// - Remark:
    /// Use SH3 to represent irradiance environment maps efficiently,
    //// allowing for interactive rendering of diffuse objects under distant illumination.
    case SphericalHarmonics
}
