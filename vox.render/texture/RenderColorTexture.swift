//
//  RenderColorTexture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// The texture is used for the output of color information in off-screen rendering.
class RenderColorTexture: Texture {
    private var _autoMipmap: Bool = false
    private var _format: MTLPixelFormat
    private var _isCube: Bool = false

    /// Texture format.
    var format: MTLPixelFormat {
        get {
            _format
        }
    }

    /// Whether to render to a cube texture.
    var isCube: Bool {
        get {
            _isCube
        }
    }

    /// Whether to automatically generate multi-level textures.
    var autoGenerateMipmaps: Bool {
        get {
            _autoMipmap
        }
        set {
            _autoMipmap = newValue
        }
    }

    /// Create RenderColorTexture.
    /// - Parameters:
    ///   - engine: Define the engine to use to render this color texture
    ///   - width: Texture width
    ///   - height: Texture height
    ///   - format: Texture format. default MTLPixelFormat.rgba8Sint
    ///   - mipmap: Whether to use multi-level texture
    ///   - isCube: Whether it's cube texture
    init(_ engine: Engine,
         _ width: Int, _ height: Int,
         _ format: MTLPixelFormat = .rgba8Sint,
         _ mipmap: Bool = false, _ isCube: Bool = false
    ) {
        _format = format

        super.init(engine)

        _isCube = isCube
        _mipmap = mipmap
        _width = width
        _height = height
        _mipmapCount = _getMipmapCount()

        _platformTexture = engine._hardwareRenderer.createPlatformRenderColorTexture(self)

        filterMode = .linear
        wrapModeU = .clampToZero
        wrapModeV = .clampToZero
    }

    /// Get the pixel color buffer according to the specified cube face and area.
    /// - Parameters:
    ///   - face: You can choose which cube face to read if it's cube texture
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height:  Area height
    ///   - out: Color buffer
    public func getPixelBuffer(_ face: TextureCubeFace?,
                               _ x: Float, _ y: Float,
                               _ width: Int, _ height: Int,
                               _ out: inout [Float]
    ) {
        (_platformTexture as! IPlatformRenderColorTexture).getPixelBuffer(face, x, y, width, height, &out)
    }

}
