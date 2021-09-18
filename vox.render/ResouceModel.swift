//
//  ResouceModel.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import MetalKit

class ResouceModel: Component {
    var meshes: [ResouceMesh] = []
    var tiling: UInt32 = 1
    var samplerState: MTLSamplerState!
    var vertexDescriptor: MDLVertexDescriptor!
    
    func load(name: String) {
        guard let assetUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: engine._hardwareRenderer.device)
        let asset = MDLAsset(url: assetUrl,
                vertexDescriptor: MDLVertexDescriptor.defaultVertexDescriptor,
                bufferAllocator: allocator)
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        _ = mdlMeshes.map { mdlMesh in
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
            MDLVertexAttributeTextureCoordinate,
                    tangentAttributeNamed: MDLVertexAttributeTangent,
                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            vertexDescriptor = mdlMesh.vertexDescriptor
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: engine._hardwareRenderer.device))
        }

        meshes = zip(mdlMeshes, mtkMeshes).map {
            ResouceMesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        samplerState = buildSamplerState()
    }

    private func buildSamplerState() -> MTLSamplerState? {
        let descriptor = MTLSamplerDescriptor()
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        descriptor.mipFilter = .linear
        descriptor.maxAnisotropy = 8
        let samplerState = engine._hardwareRenderer.device.makeSamplerState(descriptor: descriptor)
        return samplerState
    }
}



