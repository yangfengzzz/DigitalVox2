//
//  ShadowFeature.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Foundation

/// Shadow plug-in.
class ShadowFeature {
    private var _shadowPass: ShadowPass!
    private var _shadowMapMaterial: ShadowMapMaterial!

    /// Add RenderPass for rendering shadows.
    /// - Parameter camera: The camera for rendering
    func addShadowPass(_ camera: Camera) {
        let shadowMaterial = ShadowMaterial(camera.engine)
        _shadowPass = ShadowPass("ShadowPass", 1, nil, shadowMaterial, Layer.Layer30) // SHADOW
        let renderer = camera._renderPipeline
        renderer!.addRenderPass(_shadowPass)
    }

    /// Add RenderPass for rendering shadow map.
    /// - Parameters:
    ///   - camera: The camera for rendering
    ///   - light: The light that the shadow belongs to
    /// - Returns: ShadowMapPass
    func addShadowMapPass(_ camera: Camera, _ light: Light) -> ShadowMapPass {
        // Share shadow map material.
        if _shadowMapMaterial == nil {
            _shadowMapMaterial = ShadowMapMaterial(camera.engine)
        }

        let shadowMapPass = ShadowMapPass(
                "ShadowMapPass",
                -1,
                light.shadow!.renderTarget,
                _shadowMapMaterial,
                Layer.Layer31, // SHADOW_MAP
                light
        )
        let renderer = camera._renderPipeline
        renderer!.addRenderPass(shadowMapPass)

        return shadowMapPass
    }


    /// Update the renderPassFlag state of renderers in the scene.
    /// - Parameter renderQueue: Render queue
    func updatePassRenderFlag(_ renderQueue: RenderQueue) {
        let items = renderQueue.items
        for i in 0..<items.count {
            let item = items[i]
            let ability = item.component!

            let receiveShadow = ability.receiveShadow
            let castShadow = ability.castShadow
            if (receiveShadow) {
                ability.entity.layer = Layer(rawValue: ability.entity.layer.rawValue | Layer.Layer30.rawValue)! //SHADOW
            } else if (!receiveShadow) {
                ability.entity.layer = Layer(rawValue: ability.entity.layer.rawValue & ~Layer.Layer30.rawValue)! //SHADOW
            }

            if (castShadow) {
                ability.entity.layer = Layer(rawValue: ability.entity.layer.rawValue | Layer.Layer31.rawValue)! //SHADOW_MAP
            } else if (!castShadow) {
                ability.entity.layer = Layer(rawValue: ability.entity.layer.rawValue & ~Layer.Layer31.rawValue)! //SHADOW_MAP
            }
        }
    }
}

extension ShadowFeature: SceneFeature {
    func preUpdate(_ scene: Scene) {
    }

    func postUpdate(_ scene: Scene) {
    }

    func preRender(_ scene: Scene, _ camera: Camera) {
        let lightMgr: LightFeature? = scene.findFeature()
        let lights = lightMgr!.visibleLights

        if (lights.count > 0) {
            // Check RenderPass for rendering shadows.
            if _shadowPass == nil {
                addShadowPass(camera)
            }

            // Check RenderPass for rendering shadow map.
            let renderPipeline = camera._renderPipeline

            for i in 0..<lights.count {
                let lgt = lights[i]
                if (lgt.enableShadow && lgt.shadowMapPass == nil) {
                    lgt.shadowMapPass = addShadowMapPass(camera, lgt)
                } else if (!lgt.enableShadow && lgt.shadowMapPass != nil) {
                    renderPipeline!.removeRenderPass(lgt.shadowMapPass!)
                    lgt.shadowMapPass = nil
                }
            }

            updatePassRenderFlag(renderPipeline!._opaqueQueue)
            updatePassRenderFlag(renderPipeline!._alphaTestQueue)
            updatePassRenderFlag(renderPipeline!._transparentQueue)
        }
    }

    func postRender(_ scene: Scene, _ camera: Camera) {
    }

    func destroy(_ scene: Scene) {
    }
}
