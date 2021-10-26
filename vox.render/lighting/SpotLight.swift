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
            color: [Vector3](repeating: Vector3(), count: Light._maxLight),
            position: [Vector3](repeating: Vector3(), count: Light._maxLight),
            direction: [Vector3](repeating: Vector3(), count: Light._maxLight),
            distance: [Float](repeating: 0, count: Light._maxLight),
            angleCos: [Float](repeating: 0, count: Light._maxLight),
            penumbraCos: [Float](repeating: 0, count: Light._maxLight)
    )

    /// Light color.
    var color: Vector3 = Vector3(1, 1, 1)
    /// Light intensity.
    var intensity: Float = 1.0
    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    var distance: Float = 100
    /// Angle, in radians, from centre of spotlight where falloff begins.
    var angle: Float = Float.pi / 6
    /// Angle, in radians, from falloff begins to ends.
    var penumbra: Float = Float.pi / 12

    private var _forward: Vector3 = Vector3()
    private var _lightColor: Vector3 = Vector3(1, 1, 1)
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
    var lightColor: Vector3 {
        get {
            _lightColor.x = color.x * intensity
            _lightColor.y = color.y * intensity
            _lightColor.z = color.z * intensity
            return _lightColor
        }
    }


    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = SpotLight._combinedData

        shaderData.setVector3Array(SpotLight._colorProperty, data.color)
        shaderData.setVector3Array(SpotLight._positionProperty, data.position)
        shaderData.setVector3Array(SpotLight._directionProperty, data.direction)
        shaderData.setFloatArray(SpotLight._distanceProperty, data.distance)
        shaderData.setFloatArray(SpotLight._angleCosProperty, data.angleCos)
        shaderData.setFloatArray(SpotLight._penumbraCosProperty, data.penumbraCos)
    }

    internal func _appendData(_ lightIndex: Int) {
        let colorStart = lightIndex * 3
        let positionStart = lightIndex * 3
        let directionStart = lightIndex * 3
        let distanceStart = lightIndex
        let penumbraCosStart = lightIndex
        let angleCosStart = lightIndex

        SpotLight._combinedData.color[colorStart] = lightColor
        SpotLight._combinedData.position[positionStart] = position
        SpotLight._combinedData.direction[directionStart] = direction
        SpotLight._combinedData.distance[distanceStart] = distance
        SpotLight._combinedData.angleCos[angleCosStart] = cos(angle)
        SpotLight._combinedData.penumbraCos[penumbraCosStart] = cos(angle + penumbra)
    }
}
