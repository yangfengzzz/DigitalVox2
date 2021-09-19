//
//  Texture2D.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import MetalKit

/// Two-dimensional texture.
class Texture2D: Texture {
    private var _format: MTLPixelFormat

    /// Texture format.
    var format: MTLPixelFormat {
        get {
            _format
        }
    }

    /// Create Texture2D.
    /// - Parameters:
    ///   - engine: Define the engine to use to render this texture
    ///   - width: Texture width
    ///   - height: Texture height
    ///   - format: Texture format. default  `MTLPixelFormat.rgba8Sint`
    ///   - mipmap: Whether to use multi-level texture
    init(_ engine: Engine,
         _ width: Int,
         _ height: Int,
         _ format: MTLPixelFormat = .rgba8Sint,
         _ mipmap: Bool = true
    ) {
        _format = format

        super.init(engine)
        _mipmap = mipmap
        _width = width
        _height = height
        _mipmapCount = _getMipmapCount()
    }

    /// static method to load texture from name of image.
    /// - Parameter imageName: name of image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTexture(_ imageName: String) throws {
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
            self._platformTexture = try? textureLoader.newTexture(name: imageName,
                    scaleFactor: 1.0,
                    bundle: Bundle.main, options: nil)
            if self._platformTexture == nil {
                print("WARNING: Texture not found: \(imageName)")
            }
            return
        }

        self._platformTexture = try textureLoader.newTexture(URL: url,
                options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
    }

    /// static method to load texture from a instance of MDLTexture
    /// - Parameter texture: a source of texel data
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTexture(_ texture: MDLTexture) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: _engine._hardwareRenderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.bottomLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: true)]

        let texture = try? textureLoader.newTexture(texture: texture,
                options: textureLoaderOptions)
        return texture
    }

    /// configure a texture descriptor and create a texture using that descriptor.
    /// - Parameters:
    ///   - size: size of the 2D texture image
    ///   - label: a string that identifies the resource
    ///   - pixelFormat: the format describing how every pixel on the texture image is stored
    ///   - usage: options that determine how you can use the texture
    /// - Returns: a fully loaded and initialized Metal texture
    func buildTexture(_ size: CGSize,
                      _ label: String,
                      _ pixelFormat: MTLPixelFormat,
                      _ usage: MTLTextureUsage) -> MTLTexture {
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
