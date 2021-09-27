//
//  LightFeature.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Light plug-in.
class LightFeature {
    var visibleLights: [Light] = []

    var directLightCount: Int = 0
    var pointLightCount: Int = 0
    var spotLightCount: Int = 0

    /// Register a light object to the current scene.
    /// - Parameter light: light
    func attachRenderLight(light: Light) {
        let isContain = visibleLights.contains { l in
            l === light
        }

        if isContain {
            logger.warning("Light already attached.")
        } else {
            visibleLights.append(light)
        }
    }

    /// Remove a light object from the current scene.
    /// - Parameter light: light
    func detachRenderLight(light: Light) {
        visibleLights.removeAll { l in
            l === light
        }
    }

    internal func _updateShaderData(shaderData: ShaderData) {
        /// ambientLight and envMapLight only use the last one in the scene
        directLightCount = 0
        pointLightCount = 0
        spotLightCount = 0

        let lights = visibleLights
        for i in 0..<lights.count {
            let light = lights[i]
            if (light is DirectLight) {
                (light as! DirectLight)._appendData(directLightCount)
                directLightCount += 1
            } else if (light is PointLight) {
                (light as! PointLight)._appendData(pointLightCount)
                pointLightCount += 1
            } else if (light is SpotLight) {
                (light as! SpotLight)._appendData(spotLightCount)
                spotLightCount += 1
            }
        }

        if (directLightCount != 0) {
            DirectLight._updateShaderData(shaderData)
            withUnsafePointer(to: &directLightCount) { pointer in
                shaderData.enableMacro(DIRECT_LIGHT_COUNT, (UnsafeRawPointer(pointer), .int))
            }
        } else {
            shaderData.disableMacro(DIRECT_LIGHT_COUNT)
        }

        if (pointLightCount != 0) {
            PointLight._updateShaderData(shaderData)
            withUnsafePointer(to: &pointLightCount) { pointer in
                shaderData.enableMacro(POINT_LIGHT_COUNT, (UnsafeRawPointer(pointer), .int))
            }
        } else {
            shaderData.disableMacro(POINT_LIGHT_COUNT)
        }

        if (spotLightCount != 0) {
            SpotLight._updateShaderData(shaderData)
            withUnsafePointer(to: &spotLightCount) { pointer in
                shaderData.enableMacro(SPOT_LIGHT_COUNT, (UnsafeRawPointer(pointer), .int))
            }
        } else {
            shaderData.disableMacro(SPOT_LIGHT_COUNT)
        }
    }
}

extension LightFeature: SceneFeature {
    func preUpdate(_ scene: Scene) {
        fatalError()
    }

    func postUpdate(_ scene: Scene) {
        fatalError()
    }

    func preRender(_ scene: Scene, _ camera: Camera) {
        fatalError()
    }

    func postRender(_ scene: Scene, _ camera: Camera) {
        fatalError()
    }

    func destroy(_ scene: Scene) {
        fatalError()
    }
}
