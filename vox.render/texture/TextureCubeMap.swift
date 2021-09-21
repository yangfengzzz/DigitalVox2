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
    ///   - format: Texture format,default TextureFormat.R8G8B8A8
    ///   - mipmap: Whether to use multi-level texture
    init(_ engine: Engine, _ size: Int, _ format: MTLPixelFormat = .rgba8Sint, _ mipmap: Bool = true) {
        _format = format

        super.init(engine)

        _mipmap = mipmap
        _width = size
        _height = size
        _mipmapCount = _getMipmapCount()

        _platformTexture = engine._hardwareRenderer.createPlatformTextureCubeMap(self)

        filterMode = .linear
        wrapModeU = .clampToZero
        wrapModeV = .clampToZero
    }

    /// Setting pixels data through cube face,color buffer data, designated area and texture mipmapping level,
    /// it's also applicable to compressed formats.
    /// - Parameters:
    ///   - face: Cube face
    ///   - colorBuffer: Color buffer data
    ///   - mipLevel: Texture mipmapping level
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Data width.if it's empty, width is the width corresponding to mipLevel minus x ,
    ///   width corresponding to mipLevel is Math.max(1, this.width >> mipLevel)
    ///   - height: Data height.if it's empty, height is the height corresponding to mipLevel minus y ,
    ///   height corresponding to mipLevel is Math.max(1, this.height >> mipLevel)
    func setPixelBuffer<T>(_ face: TextureCubeFace, _ colorBuffer: [T],
                           _ mipLevel: Int = 0, _ x: Int? = nil, _ y: Int? = nil,
                           _ width: Int? = nil, _ height: Int? = nil) {
        (_platformTexture as! IPlatformTextureCubeMap).setPixelBuffer(face, colorBuffer, mipLevel, x, y, width, height)
    }

    /// Setting pixels data through cube face, TexImageSource, designated area and texture mipmapping level.
    /// - Parameters:
    ///   - face: Cube face
    ///   - imageSource: The source of texture
    func setImageSource(_ face: TextureCubeFace, _ imageSource: MTLTexture) {
        (_platformTexture as! IPlatformTextureCubeMap).setImageSource(face, imageSource)
    }

    /// Get the pixel color buffer according to the specified cube face and area.
    /// - Parameters:
    ///   - face: You can choose which cube face to read
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height: Area height
    ///   - out: Color buffer
    func getPixelBuffer<T>(_ face: TextureCubeFace,
                           _ x: Int, _ y: Int,
                           _ width: Int, _ height: Int, _ mipLevel: Int,
                           _ out: inout [T]) {
        (_platformTexture as! IPlatformTextureCubeMap).getPixelBuffer(face, x, y, width, height, mipLevel, &out)
    }
}
