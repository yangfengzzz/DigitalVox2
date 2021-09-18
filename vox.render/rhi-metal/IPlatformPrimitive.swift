//
//  IPlatformPrimitive.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal

/// Platform primitive interface.
protocol IPlatformPrimitive {
    /// Draw primitive.
    /// - Parameters:
    ///   - shaderProgram: Shader
    ///   - subMesh: Sub primitive
    func draw(_ renderPassEncoder: MTLRenderCommandEncoder, _ shaderProgram: ShaderProgram, _ subMesh: SubMesh)

    func destroy()
}
