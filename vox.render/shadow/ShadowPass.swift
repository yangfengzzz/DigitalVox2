//
//  ShadowPass.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// RenderPass for rendering shadow.
class ShadowPass: RenderPass {
   static var shadowMapCount = 0
    
    init() {
        super.init()
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

        ShadowPass.shadowMapCount = 0

        LightShadow.clearMap()
        for i in 0..<lights.count {
            let lgt = lights[i]
            if (lgt.enableShadow) {
                lgt.shadow!.appendData(ShadowPass.shadowMapCount)
                ShadowPass.shadowMapCount += 1
            }
        }

        if (ShadowPass.shadowMapCount != 0) {
            enabled = true
            LightShadow._updateShaderData(shaderData)
            shaderData.enableMacro(SHADOW_MAP_COUNT, (UnsafeRawPointer(&ShadowPass.shadowMapCount), .int))
        } else {
            shaderData.disableMacro(SHADOW_MAP_COUNT)
        }
    }
}
