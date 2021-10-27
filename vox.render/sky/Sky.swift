//
//  Sky.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import MetalKit

class Sky {
    struct SkySettings {
        var turbidity: Float = 0.28
        var sunElevation: Float = 0.6
        var upperAtmosphereScattering: Float = 0.1
        var groundAlbedo: Float = 4
    }

    var skySettings = SkySettings()

    /// Material of the sky.
    var material: SkyBoxMaterial
    /// Mesh of the sky. 
    var mesh: BufferMesh
    internal var _matrix: Matrix = Matrix()
    private var _engine: Engine

    init(_ _engine: Engine) {
        self._engine = _engine
        material = SkyBoxMaterial(_engine)
        mesh = BufferMesh(_engine)
    }

    func load(_ textureName: String?) {
        let allocator = MTKMeshBufferAllocator(device: _engine._hardwareRenderer.device)
        let cube = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1],
                inwardNormals: true, geometryType: .triangles,
                allocator: allocator)
        do {
            let mtkMesh = try MTKMesh(mesh: cube,
                    device: _engine._hardwareRenderer.device)

            mesh.setVertexDescriptor(mtkMesh.vertexDescriptor)
            for (index, vertexBuffer) in mtkMesh.vertexBuffers.enumerated() {
                mesh.setVertexBufferBinding(vertexBuffer.buffer, 0, index)
            }

            mtkMesh.submeshes.forEach { (mtkSubmesh: MTKSubmesh) in
                _ = mesh.addSubMesh(
                        MeshBuffer(mtkSubmesh.indexBuffer.buffer, mtkSubmesh.indexBuffer.length, mtkSubmesh.indexBuffer.type),
                        mtkSubmesh.indexType, mtkSubmesh.indexCount, mtkSubmesh.primitiveType)
            }
        } catch {
            fatalError("failed to create skybox mesh")
        }

        if let textureName = textureName {
            do {
                material.textureCubeMap = try USDZAssetsLoader(_engine).loadCubeTexture(imageName: textureName)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            material.textureCubeMap = loadGeneratedSkyboxTexture(dimensions: [256, 256])
        }
    }

    func loadGeneratedSkyboxTexture(dimensions: SIMD2<Int32>) -> MTLTexture? {
        var texture: MTLTexture?
        let skyTexture = MDLSkyCubeTexture(name: "sky",
                channelEncoding: .uInt8,
                textureDimensions: dimensions,
                turbidity: skySettings.turbidity,
                sunElevation: skySettings.sunElevation,
                upperAtmosphereScattering: skySettings.upperAtmosphereScattering,
                groundAlbedo: skySettings.groundAlbedo)
        do {
            let textureLoader = MTKTextureLoader(device: _engine._hardwareRenderer.device)
            texture = try textureLoader.newTexture(texture: skyTexture, options: nil)
        } catch {
            print(error.localizedDescription)
        }
        return texture
    }
}
