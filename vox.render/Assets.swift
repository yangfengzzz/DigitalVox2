//
//  Assets.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import MetalKit

class Assets {
    var meshes: [Mesh] = []
    var materials: [MetalMaterial] = []
    var entities:[Entity] = []

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

        // load Model I/O textures
        asset.loadTextures()

        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        _ = mdlMeshes.map { mdlMesh in
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
            MDLVertexAttributeTextureCoordinate,
                    tangentAttributeNamed: MDLVertexAttributeTangent,
                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: _engine._hardwareRenderer.device))
        }
        
        let entity = Entity(_engine, name)

        meshes = zip(mdlMeshes, mtkMeshes).map { (mdlMesh, mtkMesh) in
            let mesh = BufferMesh(_engine)
            mesh.setVertexDescriptor(mdlMesh.vertexDescriptor)
            for (index, vertexBuffer) in mtkMesh.vertexBuffers.enumerated() {
                mesh.setVertexBufferBinding(vertexBuffer.buffer, 0, index)
            }
            
            let renderer:MeshRenderer = entity.addComponent()
            renderer.mesh = mesh
            
            var subCount = 0
            zip(mdlMesh.submeshes!, mtkMesh.submeshes).forEach { (mdlSubmesh, mtkSubmesh: MTKSubmesh) in
                let mdlSubmesh = mdlSubmesh as! MDLSubmesh

                _ = mesh.addSubMesh(
                        MeshBuffer(mtkSubmesh.indexBuffer.buffer, mtkSubmesh.indexBuffer.length, mtkSubmesh.indexBuffer.type),
                        mtkSubmesh.indexType, mtkSubmesh.indexCount, mtkSubmesh.primitiveType)

                let mat = MetalMaterial(_engine)
                loadMaterial(mat, mdlSubmesh.material)
                materials.append(mat)
                renderer.setMaterial(subCount, mat)
                subCount += 1
            }

            entities.append(entity)
            return mesh
        }
    }

    func loadMaterial(_ pbr: MetalMaterial, _ material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                  property.type == .string,
                  let filename = property.stringValue,
                  let texture = try? loadTexture(imageName: filename)
                    else {
                if let property = material?.property(with: semantic),
                   property.type == .texture,
                   let mdlTexture = property.textureSamplerValue?.texture {
                    return try? loadTexture(texture: mdlTexture)
                }
                return nil
            }
            return texture
        }

        pbr.baseTexture = property(with: MDLMaterialSemantic.baseColor)
        
        if let baseColor = material?.property(with: .baseColor),
            baseColor.type == .float3 {
            let color = pbr.baseColor
            pbr.baseColor = color.setValue(r: baseColor.float3Value.x, g: baseColor.float3Value.y, b: baseColor.float3Value.z, a: 1.0)
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
                 .textureUsage: NSNumber(value: MTLTextureUsage.pixelFormatView.rawValue),
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
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        guard textures.count > 0 else {
            return nil
        }
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

extension MDLVertexDescriptor {
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0

        // position attribute
        vertexDescriptor.attributes[Int(Position.rawValue)]
                = MDLVertexAttribute(name: MDLVertexAttributePosition,
                format: .float3,
                offset: 0,
                bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 3

        // normal attribute
        vertexDescriptor.attributes[Int(Normal.rawValue)] =
                MDLVertexAttribute(name: MDLVertexAttributeNormal,
                        format: .float3,
                        offset: offset,
                        bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 3

        // uv attribute
        vertexDescriptor.attributes[Int(UV_0.rawValue)] =
                MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                        format: .float2,
                        offset: offset,
                        bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 2

        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }()
}
