//
//  ShaderUniformBlock.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Shader uniform block.
internal class ShaderUniformBlock {
    var constUniforms: [ShaderUniform] = [];
    var textureUniforms: [ShaderUniform] = [];
}
