//
//  DirectLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Directional light.
class DirectLight: Light {
    private static var _colorProperty: ShaderProperty = Shader.getPropertyByName("u_directLightColor")
    private static var _directionProperty: ShaderProperty = Shader.getPropertyByName("u_directLightDirection")

    private static var _combinedData = (
            color: [Float](repeating: 0, count: 3 * Light._maxLight),
            direction: [Float](repeating: 0, count: 3 * Light._maxLight)
    )

    var color: Color = Color(1, 1, 1, 1)
    var intensity: Float = 1

    private var _forward: Vector3 = Vector3()
    private var _lightColor: Color = Color(1, 1, 1, 1)
    private var _reverseDirection: Vector3 = Vector3()

    /// Get direction.
    var direction: Vector3 {
        get {
            entity.transform.getWorldForward(forward: _forward)
        }
    }

    /// Get the final light color.
    var lightColor: Color {
        get {
            _lightColor.r = color.r * intensity
            _lightColor.g = color.g * intensity
            _lightColor.b = color.b * intensity
            _lightColor.a = color.a * intensity
            return _lightColor
        }
    }

    /// Get the opposite direction of the directional light direction.
    var reverseDirection: Vector3 {
        get {
            Vector3.scale(left: direction, s: -1, out: _reverseDirection)
            return _reverseDirection
        }
    }

    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = DirectLight._combinedData

        shaderData.setFloatArray(DirectLight._colorProperty, data.color)
        shaderData.setFloatArray(DirectLight._directionProperty, data.direction)
    }

    internal func _appendData(_ lightIndex: Int) {
        let colorStart = lightIndex * 3
        let directionStart = lightIndex * 3

        DirectLight._combinedData.color[colorStart] = lightColor.r
        DirectLight._combinedData.color[colorStart + 1] = lightColor.g
        DirectLight._combinedData.color[colorStart + 2] = lightColor.b
        DirectLight._combinedData.direction[directionStart] = direction.x
        DirectLight._combinedData.direction[directionStart + 1] = direction.y
        DirectLight._combinedData.direction[directionStart + 2] = direction.z
    }
}
