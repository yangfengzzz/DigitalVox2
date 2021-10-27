//
//  SkyBoxMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Metal

class SkyBoxMaterial: Material {
    private var _scene:Scene
    
    init(_ scene: Scene) {
        self._scene = scene
        super.init(scene.engine, Shader.find("skybox")!)

        renderState.rasterState.cullMode = .none
        renderState.depthState.compareFunction = .lessEqual
    }

    /// Texture cube map of the sky box material.
    var textureCubeMap: MTLTexture? {
        get {
            _scene.shaderData.getTexture("u_cube")
        }
        set {
            _scene.shaderData.setTexture("u_cube", newValue!)
        }
    }
}
