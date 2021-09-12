//
//  GPUPrimitive.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal

/// WebGPU platform primitive.
class GPUPrimitive {
    var _primitive: Mesh
    private var _renderer: MetalGPURenderer

    init(_ rhi: MetalGPURenderer, _ primitive: Mesh) {
        _primitive = primitive
        _renderer = rhi
    }

}

extension GPUPrimitive: IPlatformPrimitive {
    /// Draw the primitive.
    func draw(_ renderPassEncoder: MTLRenderCommandEncoder, _ shaderProgram: AnyClass, _ subMesh: SubMesh) {
    }

    func destroy() {
    }
}
