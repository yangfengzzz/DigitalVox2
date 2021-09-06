//
//  color.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// -----------------------------------------------------------------------------
//MARK:- COLOR GRADING
// -----------------------------------------------------------------------------
// minimal color grading
public struct colorgrade_params {
    var exposure: Float = 0
    var tint: vec3f = [1, 1, 1]
    var lincontrast: Float = 0.5
    var logcontrast: Float = 0.5
    var linsaturation: Float = 0.5
    var filmic: Bool = false
    var srgb: Bool = true
    var contrast: Float = 0.5
    var saturation: Float = 0.5
    var shadows: Float = 0.5
    var midtones: Float = 0.5
    var highlights: Float = 0.5
    var shadows_color: vec3f = [1, 1, 1]
    var midtones_color: vec3f = [1, 1, 1]
    var highlights_color: vec3f = [1, 1, 1]
}

// Apply color grading from a linear or srgb color to an srgb color.
@inlinable
func colorgrade(_ color: vec3f, _ linear: Bool, _ params: colorgrade_params) -> vec3f {
    fatalError()
}

@inlinable
func colorgrade(_ color: vec4f, _ linear: Bool, _ params: colorgrade_params) -> vec4f {
    fatalError()
}
