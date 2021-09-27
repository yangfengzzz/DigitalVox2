//
//  PointLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Point light.
class PointLight: Light {
    private static var _colorProperty: ShaderProperty = Shader.getPropertyByName("u_pointLightColor")
    private static var _positionProperty: ShaderProperty = Shader.getPropertyByName("u_pointLightPosition")
    private static var _distanceProperty: ShaderProperty = Shader.getPropertyByName("u_pointLightDistance")
    private static var _combinedData = (
            color: [Float](repeating: 0, count: Light._maxLight),
            position: [Float](repeating: 0, count: 3 * Light._maxLight),
            distance: [Float](repeating: 0, count: Light._maxLight)
    )

    /// Light color.
    var color: Color = Color(1, 1, 1, 1)
    /// Light intensity.
    var intensity: Float = 1.0
    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    var distance: Float = 100

    private var _lightColor: Color = Color(1, 1, 1, 1)

    /// Get light position.
    var position: Vector3 {
        get {
            entity.transform.worldPosition
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

    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = PointLight._combinedData

        shaderData.setFloatArray(PointLight._colorProperty, data.color)
        shaderData.setFloatArray(PointLight._positionProperty, data.position)
        shaderData.setFloatArray(PointLight._distanceProperty, data.distance)
    }

    internal func _appendData(_ lightIndex: Int) {
        let colorStart = lightIndex * 3
        let positionStart = lightIndex * 3
        let distanceStart = lightIndex

        PointLight._combinedData.color[colorStart] = lightColor.r
        PointLight._combinedData.color[colorStart + 1] = lightColor.g
        PointLight._combinedData.color[colorStart + 2] = lightColor.b
        PointLight._combinedData.position[positionStart] = position.x
        PointLight._combinedData.position[positionStart + 1] = position.y
        PointLight._combinedData.position[positionStart + 2] = position.z
        PointLight._combinedData.distance[distanceStart] = distance
    }
}
