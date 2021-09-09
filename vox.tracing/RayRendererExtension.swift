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
        masks = .init(repeating: UInt32(TRIANGLE_MASK_GEOMETRY), count: vertices.count / 3)
    }
}


extension RayRenderer {
    func getTriangleNormal(_ v0: vec3f, _ v1: vec3f, _ v2: vec3f) -> vec3f {
        let e1 = normalize(v1 - v0)
        let e2 = normalize(v2 - v0)

        return cross(e1, e2)
    }

    func createCubeFace(_ vertices: inout [vec3f],
                        _ normals: inout [vec3f],
                        _ colors: inout [vec3f],
                        _ cubeVertices: [vec3f],
                        _ color: vec3f,
                        _ i0: Int,
                        _ i1: Int,
                        _ i2: Int,
                        _ i3: Int,
                        _ inwardNormals: Bool,
                        _ triangleMask: UInt32) {
        let v0 = cubeVertices[i0]
        let v1 = cubeVertices[i1]
        let v2 = cubeVertices[i2]
        let v3 = cubeVertices[i3]

        var n0 = getTriangleNormal(v0, v1, v2)
        var n1 = getTriangleNormal(v0, v2, v3)

        if (inwardNormals) {
            n0 = -n0
            n1 = -n1
        }

        vertices.append(v0)
        vertices.append(v1)
        vertices.append(v2)
        vertices.append(v0)
        vertices.append(v2)
        vertices.append(v3)

        for _ in 0..<3 {
            normals.append(n0)
        }
        for _ in 0..<3 {
            normals.append(n1)
        }
        for _ in 0..<6 {
            colors.append(color)
        }
        for _ in 0..<2 {
            masks.append(triangleMask)
        }
    }

    func monkey(_ transform: mat4f) {
        var shape = make_monkey()

        for i in 0..<shape.positions.count {
            let vertex = shape.positions[i]

            var transformedVertex = vec4f(vertex.x, vertex.y, vertex.z, 1.0)
            transformedVertex = transform * transformedVertex

            shape.positions[i] = xyz(transformedVertex)
        }

        for i in 0..<shape.quads.count {
            let quad = shape.quads[i]
            createCubeFace(&vertices, &normals, &colors, shape.positions, [0.5, 0.8, 0.5],
                    quad[0], quad[1], quad[2], quad[3], false, UInt32(TRIANGLE_MASK_GEOMETRY))
        }
    }
}
