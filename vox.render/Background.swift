//
//  Background.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/9.
//

import Foundation

/// Background of scene.
class Background {
    /// Background mode.
    /// - Note: defaultValue `BackgroundMode.SolidColor`
    /// - Remark: If using `BackgroundMode.Sky` mode and material or mesh of the `sky` is not defined,
    /// it will downgrade to `BackgroundMode.SolidColor`.
    var mode: BackgroundMode = .SolidColor

    /// Background solid color.
    /// - Note: defaultValue ` Color(0.25, 0.25, 0.25, 1.0)`
    /// - Remark: When `mode` is `BackgroundMode.SolidColor`, the property will take effects.
    var solidColor: Color = Color(0.25, 0.25, 0.25, 1.0)

    /// Background sky.
    /// - Remark: When `mode` is `BackgroundMode.Sky`, the property will take effects.
    var sky: Sky
    
    init(_ engine:Engine) {
        sky = Sky(engine)
    }
}
