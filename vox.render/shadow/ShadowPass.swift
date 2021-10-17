//
//  ShadowPass.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// RenderPass for rendering shadow.
class ShadowPass: RenderPass {
    override init(_ name: String? = nil,
                  _ priority: Int = 0,
                  _ renderTarget: RenderTarget? = nil,
                  _ replaceMaterial: Material? = nil,
                  _ mask: Layer = Layer.Everything) {
        super.init(name, priority, renderTarget, replaceMaterial, mask)
        clearFlags = CameraClearFlags.None
    }

    override func preRender(_ camera: Camera, _ opaqueQueue: RenderQueue,
                            _ alphaTestQueue: RenderQueue, _ transparentQueue: RenderQueue) {
        enabled = false
        let lightMgr: LightFeature? = camera.scene.findFeature()
        let lights = lightMgr!.visibleLights
        let shaderData = replaceMaterial!.shaderData

        // keep render based on default render pass
        let pass = camera._renderPipeline.defaultRenderPass
        renderTarget = pass.renderTarget

        var shadowMapCount = 0

        LightShadow.clearMap()
        for i in 0..<lights.count {
            let lgt = lights[i]
            if (lgt.enableShadow) {
                lgt.shadow!.appendData(shadowMapCount)
                shadowMapCount += 1
            }
        }

        if (shadowMapCount != 0) {
            enabled = true
            LightShadow._updateShaderData(shaderData)
            shaderData.enableMacro(SHADOW_MAP_COUNT, (shadowMapCount, .int))
        } else {
            shaderData.disableMacro(SHADOW_MAP_COUNT)
        }
    }
}
