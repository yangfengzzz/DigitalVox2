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

extension Assets {
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
    
    /// static method to load texture from a instance of MDLTexture
    /// - Parameter texture: a source of texel data
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTexture(texture: MDLTexture) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: _engine._hardwareRenderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
            [.origin: MTKTextureLoader.Origin.bottomLeft,
             .SRGB: false,
             .generateMipmaps: NSNumber(booleanLiteral: true)]
        
        let texture = try? textureLoader.newTexture(texture: texture,
                                                    options: textureLoaderOptions)
        return texture
    }
    
    /// static method to load cube texture from name of image.
    /// - Parameter imageName: name of cube image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadCubeTexture(imageName: String) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: _engine._hardwareRenderer.device)
        if let texture = MDLTexture(cubeWithImagesNamed: [imageName]) {
            let options: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: false)]
            return try textureLoader.newTexture(texture: texture, options: options)
        }
        let texture = try textureLoader.newTexture(name: imageName, scaleFactor: 1.0,
                                                   bundle: .main)
        return texture
    }
    
    /// static method to load up the textures into a temporary array of MTLTextures.
    /// - Parameter imageName: lists about name of image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTextureArray(textureNames: [String]) -> MTLTexture? {
        var textures: [MTLTexture] = []
        for textureName in textureNames {
            do {
                if let texture = try self.loadTexture(imageName: textureName) {
                    textures.append(texture)
                }
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
        guard textures.count > 0 else { return nil }
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2DArray
        descriptor.pixelFormat = textures[0].pixelFormat
        descriptor.width = textures[0].width
        descriptor.height = textures[0].height
        descriptor.arrayLength = textures.count
        let arrayTexture = _engine._hardwareRenderer.device.makeTexture(descriptor: descriptor)!
        let commandBuffer = _engine._hardwareRenderer.commandQueue.makeCommandBuffer()!
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        let origin = MTLOrigin(x: 0, y: 0, z: 0)
        let size = MTLSize(width: arrayTexture.width,
                           height: arrayTexture.height, depth: 1)
        for (index, texture) in textures.enumerated() {
            blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                             sourceOrigin: origin, sourceSize: size,
                             to: arrayTexture, destinationSlice: index,
                             destinationLevel: 0, destinationOrigin: origin)
        }
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return arrayTexture
    }
    
    /// conﬁgure a texture descriptor and create a texture using that descriptor.
    /// - Parameters:
    ///   - size: size of the 2D texture image
    ///   - label: a string that identifies the resource
    ///   - pixelFormat: the format describing how every pixel on the texture image is stored
    ///   - usage: options that determine how you can use the texture
    /// - Returns: a fully loaded and initialized Metal texture
    func buildTexture(size: CGSize,
                             label: String,
                             pixelFormat: MTLPixelFormat,
                             usage: MTLTextureUsage) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: Int(size.width),
                                                                  height: Int(size.height),
                                                                  mipmapped: false)
        descriptor.sampleCount = 1
        descriptor.storageMode = .private
        descriptor.textureType = .type2D
        descriptor.usage = usage
        guard let texture = _engine._hardwareRenderer.device.makeTexture(descriptor: descriptor) else {
            fatalError("Texture not created")
        }
        texture.label = label
        return texture
    }
}
