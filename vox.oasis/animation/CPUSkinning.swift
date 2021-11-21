//
//  CPUSkinning.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

import Foundation

class CPUSkinning: Script {
    let skinning = CCPUSkinning()
    var meshes: [BufferMesh] = []

    func load(_ skeleton: String, _ animation: String, _ mesh: String) {
        guard let skeletonUrl = Bundle.main.url(forResource: skeleton, withExtension: nil) else {
            fatalError("Model: \(skeleton) not found")
        }
        guard let animationUrl = Bundle.main.url(forResource: animation, withExtension: nil) else {
            fatalError("Model: \(animation) not found")
        }
        guard let meshUrl = Bundle.main.url(forResource: mesh, withExtension: nil) else {
            fatalError("Model: \(mesh) not found")
        }

        skinning.onInitialize(skeletonUrl.path, animationUrl.path, meshUrl.path)
    }

    override func onUpdate(_ deltaTime: Float) {
        skinning.onUpdate(deltaTime)

        var index = 0
        skinning.freshSkinnedMesh(_engine._hardwareRenderer.device) { [self]vertexBuffer, indexBuffer, indexCount, vertexDescriptor in
            let mesh = BufferMesh(_engine)
            mesh.setVertexDescriptor(vertexDescriptor)
            mesh.setVertexBufferBinding(vertexBuffer, 0, 0)
            _ = mesh.addSubMesh(
                    MeshBuffer(indexBuffer, indexCount * MemoryLayout<UInt16>.stride, .index),
                    .uint16, indexCount, .triangle)

            if index < meshes.count {
                meshes[index] = mesh
            } else {
                let child = entity.createChild("part\(index)")
                let renderer: MeshRenderer = child.addComponent()
                renderer.mesh = mesh
                renderer.setMaterial(PBRMaterial(_engine))

                meshes.append(mesh)
            }
            index += 1
        }
    }
}
