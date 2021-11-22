//
//  CPUSkinning.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

import Foundation

class CPUSkinning: Script {
    let skinning = CCPUSkinning()
    var renderers: [MeshRenderer] = []
    var mat: PBRMaterial!

    required init(_ entity: Entity) {
        super.init(entity)

        _ = Shader.create("skin", "skin_vertex", "skin_fragment")
        mat = PBRMaterial(_engine)
        loadMaterial(mat)
    }

    func load(_ skeleton: String, _ mesh: String) {
        guard let skeletonUrl = Bundle.main.url(forResource: skeleton, withExtension: nil) else {
            fatalError("Model: \(skeleton) not found")
        }
        guard let meshUrl = Bundle.main.url(forResource: mesh, withExtension: nil) else {
            fatalError("Model: \(mesh) not found")
        }

        skinning.onInitialize(skeletonUrl.path, meshUrl.path)
    }

    func loadAnimation(_ animation: String) {
        guard let animationUrl = Bundle.main.url(forResource: animation, withExtension: nil) else {
            fatalError("Model: \(animation) not found")
        }
        skinning.loadAnimation(animationUrl.path)
    }

    func adjustWeight(_ index: Int, _ weight: Float) {
        skinning.updateWeight(Int32(index), weight);
    }

    override func onUpdate(_ deltaTime: Float) {
        skinning.onUpdate(deltaTime)

        var index = 0
        skinning.freshSkinnedMesh(_engine._hardwareRenderer.device) { [self]vertexBuffers, indexBuffer, indexCount, vertexDescriptor in
            let mesh = BufferMesh(_engine)
            mesh.setVertexDescriptor(vertexDescriptor)
            for (index, vertexBuffer) in vertexBuffers.enumerated() {
                mesh.setVertexBufferBinding(vertexBuffer, 0, index)
            }
            _ = mesh.addSubMesh(
                    MeshBuffer(indexBuffer, indexCount * MemoryLayout<UInt16>.stride, .index),
                    .uint16, indexCount, .triangle)

            if index < renderers.count {
                renderers[index].mesh = mesh
            } else {
                let child = entity.createChild("part\(index)")
                let renderer: MeshRenderer = child.addComponent()
                renderer.mesh = mesh
                renderer.setMaterial(mat)

                renderers.append(renderer)
            }
            index += 1
        }
    }

    func loadMaterial(_ pbr: PBRMaterial) {
        pbr.baseTexture = try? loadTexture(imageName: "T_Doggy_1_diffuse.png")
        pbr.normalTexture = try? loadTexture(imageName: "T_Doggy_normal.png")
        pbr.roughnessTexture = try? loadTexture(imageName: "T_Doggy_roughness.png")
        pbr.metallicTexture = try? loadTexture(imageName: "T_Doggy_metallic.png")
        pbr.occlusionTexture = try? loadTexture(imageName: "T_Doggy_1_ao.png")
    }

    /// static method to load texture from name of image.
    /// - Parameter imageName: name of image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTexture(imageName: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: _engine._hardwareRenderer.device)

        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.bottomLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: true)]
        let fileExtension =
                URL(fileURLWithPath: imageName).pathExtension.isEmpty ?
                        "png" : nil
        guard let url = Bundle.main.url(forResource: imageName,
                withExtension: fileExtension)
                else {
            let texture = try? textureLoader.newTexture(name: imageName,
                    scaleFactor: 1.0,
                    bundle: Bundle.main, options: nil)
            if texture == nil {
                print("WARNING: Texture not found: \(imageName)")
            }
            return texture
        }

        let texture = try textureLoader.newTexture(URL: url,
                options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
}
