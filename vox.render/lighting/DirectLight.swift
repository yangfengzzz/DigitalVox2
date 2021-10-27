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
            color: [SIMD3<Float>](repeating: SIMD3<Float>(), count: Light._maxLight),
            direction: [SIMD3<Float>](repeating: SIMD3<Float>(), count: Light._maxLight)
    )

    var color: Vector3 = Vector3(1, 1, 1)
    var intensity: Float = 1

    private var _forward: Vector3 = Vector3()
    private var _lightColor: Vector3 = Vector3(1, 1, 1)
    private var _reverseDirection: Vector3 = Vector3()

    /// Get direction.
    var direction: Vector3 {
        get {
            entity.transform.getWorldForward(forward: _forward)
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

    /// Get the opposite direction of the directional light direction.
    var reverseDirection: Vector3 {
        get {
            Vector3.scale(left: direction, s: -1, out: _reverseDirection)
            return _reverseDirection
        }
    }

    internal static func _updateShaderData(_ shaderData: ShaderData) {
        let data = DirectLight._combinedData

        shaderData.setVector3Array(DirectLight._colorProperty, data.color)
        shaderData.setVector3Array(DirectLight._directionProperty, data.direction)
    }

    internal func _appendData(_ lightIndex: Int) {
        DirectLight._combinedData.color[lightIndex] = lightColor.elements
        DirectLight._combinedData.direction[lightIndex] = direction.elements
    }
}
