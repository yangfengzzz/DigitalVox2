//
//  ShaderPool.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Internal shader pool.
internal class ShaderPool {
    static func initialization() {
        _ = Shader.create("simple", "vertex_simple", "fragment_simple");
        _ = Shader.create("pbr", "vertex_main", "fragment_mainPBR");
        _ = Shader.create("background-texture", "vertex_main", "fragment_mainPBR");
        _ = Shader.create("skybox", "vertex_main", "fragment_mainPBR")
    }
}
