//
//  GPUPrimitive.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal

/// WebGPU platform primitive.
class GPUPrimitive {
    private var _renderer: MetalRenderer

    init(_ rhi: MetalRenderer) {
        _renderer = rhi
    }

}

extension GPUPrimitive: IPlatformPrimitive {
    /// Draw the primitive.
    func draw(_ shaderProgram: ShaderProgram, _ subMesh: SubMesh) {
        _renderer.renderEncoder.drawIndexedPrimitives(type: subMesh.topology, indexCount: subMesh.indexCount,
                                                indexType: subMesh.indexType,
                                                indexBuffer: subMesh.indexBuffer!.buffer,
                                                indexBufferOffset: subMesh.indexBuffer!.offset)
    }

    func destroy() {
    }
}
