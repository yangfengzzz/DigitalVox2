//
//  ShadowMapPass.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Metal

/// RenderPass for rendering shadow map.
class ShadowMapPass: RenderPass {
    private static var _viewMatFromLightProperty = Shader.getPropertyByName("u_viewMatFromLight")
    private static var _projMatFromLightProperty = Shader.getPropertyByName("u_projMatFromLight")

    var light: Light

    /// Constructor.
    /// - Parameters:
    ///   - light: The light that the shadow belongs to
    init(_ name: String,
         _ priority: Int,
         _ renderTarget: MTLRenderPassDescriptor,
         _ replaceMaterial: Material,
         _ mask: Layer,
         _ light: Light) {
        self.light = light

        super.init(name, priority, renderTarget, replaceMaterial, mask)
        clearColor = Color(1, 1, 1, 1)
    }

    override func preRender(_ camera: Camera, _ opaqueQueue: RenderQueue,
                            _ alphaTestQueue: RenderQueue, _ transparentQueue: RenderQueue) {
        // The viewProjection matrix from the light.
        let shaderData = replaceMaterial!.shaderData
        shaderData.setMatrix(ShadowMapPass._viewMatFromLightProperty, light.viewMatrix)
        shaderData.setMatrix(ShadowMapPass._projMatFromLightProperty, light.shadow!.projectionMatrix)
    }
}
