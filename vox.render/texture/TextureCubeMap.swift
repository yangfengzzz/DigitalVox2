//
//  TextureCubeMap.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import MetalKit

/// Two-dimensional texture.
class TextureCubeMap: Texture {
    private var _format: MTLPixelFormat

    /// Texture format.
    var format: MTLPixelFormat {
        get {
            _format
        }
    }
    
    /// Create TextureCube.
    /// - Parameters:
    ///   - engine: Define the engine to use to render this texture
    ///   - size: Texture size. texture width must be equal to height in cube texture
    ///   - format: Texture format. default  `MTLPixelFormat.rgba8Sint`
    ///   - mipmap: Whether to use multi-level texture
    init(engine: Engine,
         size: Int,
         format: MTLPixelFormat = .rgba8Sint,
         mipmap: Bool = true
    ) {
        _format = format

        super.init(engine)
        _mipmap = mipmap
        _width = size
        _height = size
        _mipmapCount = _getMipmapCount()
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
}
