//
//  Assets.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import MetalKit

class Assets {
    var meshes: [Mesh] = []
    var materials: [PBRMaterial] = []

    private var _engine: Engine

    init(_ engine: Engine) {
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
            mesh.setVertexDescriptor(VertexDescriptor(mdlMesh.vertexDescriptor))
            for (index, vertexBuffer) in mtkMesh.vertexBuffers.enumerated() {
                mesh.setVertexBufferBinding(vertexBuffer.buffer, 0, index)
            }

            zip(mdlMesh.submeshes!, mtkMesh.submeshes).forEach { (mdlSubmesh, mtkSubmesh: MTKSubmesh) in
                _ = mesh.addSubMesh(
                        MeshBuffer(mtkSubmesh.indexBuffer.buffer, mtkSubmesh.indexBuffer.length, mtkSubmesh.indexBuffer.type),
                        mtkSubmesh.indexType, mtkSubmesh.indexCount, mtkSubmesh.primitiveType)

                let mdlSubmesh = mdlSubmesh as! MDLSubmesh
                let mat = PBRMaterial(_engine)
                func property(with semantic: MDLMaterialSemantic) -> Texture2D? {
                    let texture = Texture2D(_engine, 1, 1)
                    guard let property = mdlSubmesh.material?.property(with: semantic),
                          property.type == .string,
                          let filename = property.stringValue
                            else {
                        return nil
                    }
                    try? texture.loadTexture(filename)
                    return texture
                }
                materials.append(mat)
            }


            mtkMesh.submeshes.forEach { subMesh in
                _ = mesh.addSubMesh(
                        MeshBuffer(subMesh.indexBuffer.buffer, subMesh.indexBuffer.length, subMesh.indexBuffer.type),
                        subMesh.indexType, subMesh.indexCount, subMesh.primitiveType)
            }

            return mesh
        }
    }
}

private extension MaterialConstant {
  init(_ material: MDLMaterial?) {
    self.init()
    if let baseColor = material?.property(with: .baseColor),
      baseColor.type == .float3 {
      self.baseColor = baseColor.float3Value
    }
    if let specular = material?.property(with: .specular),
      specular.type == .float3 {
      self.specularColor = specular.float3Value
    }
    if let shininess = material?.property(with: .specularExponent),
      shininess.type == .float {
      self.shininess = shininess.floatValue
    }
    if let roughness = material?.property(with: .roughness),
      roughness.type == .float3 {
      self.roughness = roughness.floatValue
    }
  }
}
