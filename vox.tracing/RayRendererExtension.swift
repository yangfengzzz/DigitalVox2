//
//  RayRendererExtension.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

extension RayRenderer {
    func vertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] =
                MDLVertexAttribute(name: MDLVertexAttributePosition,
                        format: .float3,
                        offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] =
                MDLVertexAttribute(name: MDLVertexAttributeNormal,
                        format: .float2,
                        offset: 0, bufferIndex: 1)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        vertexDescriptor.layouts[1] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        return vertexDescriptor
    }

    func loadAsset(name: String, position: SIMD3<Float>, scale: Float) {
        let assetURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL,
                vertexDescriptor: vertexDescriptor(),
                bufferAllocator: allocator)
        guard let mdlMesh = asset.object(at: 0) as? MDLMesh,
              let mdlSubmeshes = mdlMesh.submeshes as? [MDLSubmesh] else {
            return
        }
        let mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        let count = mesh.vertexBuffers[0].buffer.length / MemoryLayout<SIMD3<Float>>.size
        let positionBuffer = mesh.vertexBuffers[0].buffer
        let normalsBuffer = mesh.vertexBuffers[1].buffer
        let normalsPtr = normalsBuffer.contents().bindMemory(to: SIMD3<Float>.self, capacity: count)
        let positionPtr = positionBuffer.contents().bindMemory(to: SIMD3<Float>.self, capacity: count)
        for (mdlIndex, submesh) in mesh.submeshes.enumerated() {
            let indexBuffer = submesh.indexBuffer.buffer
            let offset = submesh.indexBuffer.offset
            let indexPtr = indexBuffer.contents().advanced(by: offset)
            var indices = indexPtr.bindMemory(to: uint.self, capacity: submesh.indexCount)
            for _ in 0..<submesh.indexCount {
                let index = Int(indices.pointee)
                vertices.append(positionPtr[index] * scale + position)
                normals.append(normalsPtr[index])
                indices = indices.advanced(by: 1)
                let mdlSubmesh = mdlSubmeshes[mdlIndex]
                let color: SIMD3<Float>
                if let baseColor = mdlSubmesh.material?.property(with: .baseColor),
                   baseColor.type == .float3 {
                    color = baseColor.float3Value
                } else {
                    color = [1, 0, 0]
                }
                colors.append(color)
            }
        }
    }

}
