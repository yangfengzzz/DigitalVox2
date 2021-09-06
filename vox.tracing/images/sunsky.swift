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
func make_sunsky(_ width: Int, _ height: Int, _ sun_angle: Float,
                 _ turbidity: Float = 3, _ has_sun: Bool = false, _ sun_intensity: Float = 1,
                 _ sun_radius: Float = 1, _ ground_albedo: vec3f = [0.2, 0.2, 0.2]) -> image_data {
    fatalError()
}

// Make a sunsky HDR model with sun at sun_angle elevation in [0,pif/2],
// turbidity in [1.7,10] with or without sun. The sun can be enabled or
// disabled with has_sun. The sun parameters can be slightly modified by
// changing the sun intensity and temperature. Has a convention, a temperature
// of 0 sets the eath sun defaults (ignoring intensity too).
func make_sunsky(_ pixels: inout [vec4f], _ width: Int, _  height: Int, _ sun_angle: Float,
                 _ turbidity: Float = 3, _ has_sun: Bool = false, _ sun_intensity: Float = 1,
                 _ sun_radius: Float = 1, _ ground_albedo: vec3f = [0.2, 0.2, 0.2]) {
    fatalError()
}
