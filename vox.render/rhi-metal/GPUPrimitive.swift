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
    private var _renderer: MetalRenderer

    init(_ rhi: MetalRenderer, _ primitive: Mesh) {
        _primitive = primitive
        _renderer = rhi
    }

}

extension GPUPrimitive: IPlatformPrimitive {
    /// Draw the primitive.
    func draw(_ renderPassEncoder: MTLRenderCommandEncoder, _ shaderProgram: ShaderProgram, _ subMesh: SubMesh) {
        renderPassEncoder.setVertexBuffer(_primitive._vertexBufferBindings[0]._buffer, offset: 0, index: Int(BufferIndexVertices.rawValue))
        renderPassEncoder.drawIndexedPrimitives(type: .triangle, indexCount: subMesh.count, indexType: .uint32,
                indexBuffer: _primitive._indexBufferBinding.buffer!, indexBufferOffset: 0)
    }

    func destroy() {
    }
}
