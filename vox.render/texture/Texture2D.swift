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
         _ width: Int, _ height: Int,
         _ format: MTLPixelFormat = .rgba8Sint,
         _ mipmap: Bool = true) {
        _format = format

        super.init(engine)
        _mipmap = mipmap
        _width = width
        _height = height
        _mipmapCount = _getMipmapCount()

        _platformTexture = engine._hardwareRenderer.createPlatformTexture2D(self)

        filterMode = .linear
        wrapModeU = .repeat
        wrapModeV = .repeat
    }

    /// Setting pixels data through color buffer data, designated area and texture mipmapping level,
    /// it's also applicable to compressed formats.
    /// - Parameters:
    ///   - colorBuffer: Color buffer data
    ///   - mipLevel: Texture mipmapping level
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Data width. if it's empty, width is the width corresponding to mipLevel minus x ,
    ///   width corresponding to mipLevel is Math.max(1, this.width >> mipLevel)
    ///   - height: Data height. if it's empty, height is the height corresponding to mipLevel minus y ,
    ///   height corresponding to mipLevel is Math.max(1, this.height >> mipLevel)
    func setPixelBuffer(_ colorBuffer: [Float], _ mipLevel: Int = 0,
                        _ x: Int?, _ y: Int?,
                        _ width: Int?, _ height: Int?) {
        (_platformTexture as! IPlatformTexture2D).setPixelBuffer(colorBuffer, mipLevel, x, y, width, height)
    }

    /// Setting pixels data through TexImageSource, designated area and texture mipmapping level.
    /// - Parameters:
    ///   - imageSource: The source of texture
    ///   - mipLevel: Texture mipmapping level
    ///   - flipY: Whether to flip the Y axis
    ///   - premultiplyAlpha: Whether to premultiply the transparent channel
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    func setImageSource(_ imageSource: MTLBuffer, _ x: Int?, _ y: Int?) {
        (_platformTexture as! IPlatformTexture2D).setImageSource(imageSource, x, y)
    }

    func setImageSource(_ imageSource: MTLTexture) {
        (_platformTexture as! IPlatformTexture2D).setImageSource(imageSource)
    }

    /// Get the pixel color buffer according to the specified area.
    /// - Parameters:
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height: Area height
    ///   - out: Color buffer
    func getPixelBuffer(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ mipLevel: Int, _ out: inout [Float]) {
        (_platformTexture as! IPlatformTexture2D).getPixelBuffer(x, y, width, height, mipLevel, &out)
    }
}
