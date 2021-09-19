//
//  Assets.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import MetalKit

class Assets {
    var meshes: [Mesh] = []
    
    private var _engine:Engine
    
    init(_ engine:Engine) {
        _engine = engine
    }

    func load(name: String) {
        guard let assetUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: _engine._hardwareRenderer.device)
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
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: _engine._hardwareRenderer.device))
        }

        meshes = zip(mdlMeshes, mtkMeshes).map { (mdlMesh, mtkMesh) in
            let mesh = BufferMesh(_engine)
            mesh.setVertexDescriptor( VertexDescriptor(mdlMesh.vertexDescriptor))
            for (index, vertexBuffer) in mtkMesh.vertexBuffers.enumerated() {
                mesh.setVertexBufferBinding(vertexBuffer.buffer, 0, index)
            }
            
            mtkMesh.submeshes.forEach { subMesh in
                _ = mesh.addSubMesh(
                    MeshBuffer(subMesh.indexBuffer.buffer, subMesh.indexBuffer.length, subMesh.indexBuffer.type),
                    subMesh.indexType,subMesh.indexCount, subMesh.primitiveType)
            }
            
            return mesh
        }
    }
}
