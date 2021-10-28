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
        _ = Shader.create("blinn-phong", "vertex_blinn_phong", "fragment_blinn_phong");
        _ = Shader.create("pbr", "vertex_blinn_phong", "fragment_pbr");
        _ = Shader.create("pbr-specular", "vertex_blinn_phong", "fragment_pbr");
        _ = Shader.create("unlit", "vertex_unlit", "fragment_unlit");
        _ = Shader.create("shadow-map", "vertex_shadow_map", "fragment_shadow_map");
        _ = Shader.create("shadow", "vertex_shadow_map", "fragment_shadow");
        _ = Shader.create("skybox", "vertex_skybox", "fragment_skybox");
        _ = Shader.create("particle-shader", "vertex_particle", "fragment_particle");
        _ = Shader.create("background-texture", "vertex_background_texture", "fragment_background_texture");
        
        _ = Shader.create("simple", "vertex_simple", "fragment_simple");
    }
}
