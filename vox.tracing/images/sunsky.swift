//
//  sunsky.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Make a sunsky HDR model with sun at sun_angle elevation in [0,pif/2],
// turbidity in [1.7,10] with or without sun. The sun can be enabled or
// disabled with has_sun. The sun parameters can be slightly modified by
// changing the sun intensity and temperature. Has a convention, a temperature
// of 0 sets the eath sun defaults (ignoring intensity too).
func make_sunsky(width: Int, height: Int, sun_angle: Float,
                 turbidity: Float = 3, has_sun: Bool = false, sun_intensity: Float = 1,
                 sun_radius: Float = 1, ground_albedo: vec3f = [0.2, 0.2, 0.2]) -> image_data {
    fatalError()
}
