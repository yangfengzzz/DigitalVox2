//
//  RenderDepthTexture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// The texture is used for the output of depth information in off-screen rendering.
class RenderDepthTexture: Texture {
    private var _autoMipmap: Bool = false;
    private var _format: RenderBufferDepthFormat;
    private var _isCube: Bool = false;

    /// Texture format.
    var format: RenderBufferDepthFormat {
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

    /// Create RenderDepthTexture.
    /// - Parameters:
    ///   - engine: Define the engine to use to render this depth texture
    ///   - width: Texture width
    ///   - height: Texture height
    ///   - format: Texture format. default RenderBufferDepthFormat.Depth, engine will automatically select the supported precision
    ///   - mipmap: Whether to use multi-level texture
    ///   - isCube: Whether it's cube texture
    init(_ engine: Engine,
         _ width: Int, _ height: Int,
         _ format: RenderBufferDepthFormat = RenderBufferDepthFormat.Depth,
         _ mipmap: Bool = false, _ isCube: Bool = false
    ) {
        _format = format;

        super.init(engine);

        _isCube = isCube;
        _mipmap = mipmap;
        _width = width;
        _height = height;
        _mipmapCount = _getMipmapCount();

        _platformTexture = engine._hardwareRenderer.createPlatformRenderDepthTexture(self);

        filterMode = .linear
        wrapModeU = .clampToZero
        wrapModeV = .clampToZero
    }
}
