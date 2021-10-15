//
//  SkyBoxMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

class SkyBoxMaterial: Material {
    init(_ engine: Engine) {
        super.init(engine, Shader.find("skybox")!)

        renderState.rasterState.cullMode = .none
        renderState.depthState.compareFunction = .lessEqual
    }

    /// Texture cube map of the sky box material.
    var textureCubeMap: TextureCubeMap {
        get {
            shaderData.getTexture("u_cube") as! TextureCubeMap
        }
        set {
            shaderData.setTexture("u_cube", newValue)
        }
    }
}
