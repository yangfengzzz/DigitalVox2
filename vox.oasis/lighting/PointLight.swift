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
            color: [SIMD3<Float>](repeating: SIMD3<Float>(), count: Light._maxLight),
            position: [SIMD3<Float>](repeating: SIMD3<Float>(), count: Light._maxLight),
            distance: [Float](repeating: 0, count: Light._maxLight)
    )

    /// Light color.
    var color: Vector3 = Vector3(1, 1, 1)
    /// Light intensity.
    var intensity: Float = 1.0
    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    var distance: Float = 100

    private var _lightColor: Vector3 = Vector3(1, 1, 1)

    /// Get light position.
    var position: Vector3 {
        get {
            entity.transform.worldPosition
        }
    }

    /// Get the final light color.
    var lightColor: Vector3 {
        get {
            _lightColor.x = color.x * intensity
            _lightColor.y = color.y * intensity
            _lightColor.z = color.z * intensity
            return _lightColor
        }
    }

    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = PointLight._combinedData

        shaderData.setBytes(PointLight._colorProperty, data.color)
        shaderData.setBytes(PointLight._positionProperty, data.position)
        shaderData.setBytes(PointLight._distanceProperty, data.distance)
    }

    internal func _appendData(_ lightIndex: Int) {
        PointLight._combinedData.color[lightIndex] = lightColor.elements
        PointLight._combinedData.position[lightIndex] = position.elements
        PointLight._combinedData.distance[lightIndex] = distance
    }
}
