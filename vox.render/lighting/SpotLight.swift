//
//  SpotLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Spot light.
class SpotLight: Light {
    private static var _colorProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightColor")
    private static var _positionProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightPosition")
    private static var _directionProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightDirection")
    private static var _distanceProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightDistance")
    private static var _angleCosProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightAngleCos")
    private static var _penumbraCosProperty: ShaderProperty = Shader.getPropertyByName("u_spotLightPenumbraCos")

    private static var _combinedData = (
            color: [Float](repeating: 0, count: 3 * Light._maxLight),
            position: [Float](repeating: 0, count: 3 * Light._maxLight),
            direction: [Float](repeating: 0, count: 3 * Light._maxLight),
            distance: [Float](repeating: 0, count: Light._maxLight),
            angleCos: [Float](repeating: 0, count: Light._maxLight),
            penumbraCos: [Float](repeating: 0, count: Light._maxLight)
    )

    /// Light color.
    var color: Color = Color(1, 1, 1, 1)
    /// Light intensity.
    var intensity: Float = 1.0
    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    var distance: Float = 100
    /// Angle, in radians, from centre of spotlight where falloff begins.
    var angle: Float = Float.pi / 6
    /// Angle, in radians, from falloff begins to ends.
    var penumbra: Float = Float.pi / 12

    private var _forward: Vector3 = Vector3()
    private var _lightColor: Color = Color(1, 1, 1, 1)
    private var _inverseDirection: Vector3 = Vector3()

    /// Get light position.
    var position: Vector3 {
        get {
            entity.transform.worldPosition
        }
    }

    /// Get light direction.
    var direction: Vector3 {
        get {
            return entity.transform.getWorldForward(forward: _forward)
        }
    }

    /// Get the opposite direction of the spotlight.
    var reverseDirection: Vector3 {
        Vector3.scale(left: direction, s: -1, out: _inverseDirection)
        return _inverseDirection
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


    internal static func _updateShaderData(shaderData: ShaderData) {
        let data = SpotLight._combinedData

        shaderData.setFloatArray(SpotLight._colorProperty, data.color)
        shaderData.setFloatArray(SpotLight._positionProperty, data.position)
        shaderData.setFloatArray(SpotLight._directionProperty, data.direction)
        shaderData.setFloatArray(SpotLight._distanceProperty, data.distance)
        shaderData.setFloatArray(SpotLight._angleCosProperty, data.angleCos)
        shaderData.setFloatArray(SpotLight._penumbraCosProperty, data.penumbraCos)
    }

    internal func _appendData(lightIndex: Int) {
        let colorStart = lightIndex * 3
        let positionStart = lightIndex * 3
        let directionStart = lightIndex * 3
        let distanceStart = lightIndex
        let penumbraCosStart = lightIndex
        let angleCosStart = lightIndex

        SpotLight._combinedData.color[colorStart] = lightColor.r
        SpotLight._combinedData.color[colorStart + 1] = lightColor.g
        SpotLight._combinedData.color[colorStart + 2] = lightColor.b
        SpotLight._combinedData.position[positionStart] = position.x
        SpotLight._combinedData.position[positionStart + 1] = position.y
        SpotLight._combinedData.position[positionStart + 2] = position.z
        SpotLight._combinedData.direction[directionStart] = direction.x
        SpotLight._combinedData.direction[directionStart + 1] = direction.y
        SpotLight._combinedData.direction[directionStart + 2] = direction.z
        SpotLight._combinedData.distance[distanceStart] = distance
        SpotLight._combinedData.angleCos[angleCosStart] = cos(angle)
        SpotLight._combinedData.penumbraCos[penumbraCosStart] = cos(angle + penumbra)
    }
}
