//
//  RenderTarget.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

enum DepthType {
    case RenderDepthTexture(MTLTexture)
    case RenderBufferDepthFormat(MTLPixelFormat)
}

/// The render target used for off-screen rendering.
class RenderTarget: EngineObject {
    internal var _platformRenderTarget: MTLRenderPassDescriptor!
    internal var _colorTextures: [MTLTexture]
    internal var _depth: DepthType?
    internal var _antiAliasing: Int

    private var _width: Int
    private var _height: Int
    private var _depthTexture: MTLTexture?

    /// Render target width.
    var width: Int {
        get {
            _width
        }
    }

    /// Render target height.
    var height: Int {
        get {
            _height
        }
    }

    /// Render color texture count.
    var colorTextureCount: Int {
        get {
            _colorTextures.count
        }
    }

    /// Depth texture.
    var depthTexture: MTLTexture? {
        get {
            _depthTexture
        }
    }

    /// Anti-aliasing level.
    /// - Remark: If the anti-aliasing level set is greater than the maximum level supported by the hardware, the maximum level of the hardware will be used.
    var antiAliasing: Int {
        get {
            _antiAliasing
        }
    }

    /// Create a render target through color texture and depth format.
    /// - Parameters:
    ///   - engine: Define the engine to use for this off-screen rendering
    ///   - width: Render target width
    ///   - height: Render target height
    ///   - colorTexture: Render color texture
    ///   - depthFormat: Depth format. default RenderBufferDepthFormat.Depth, engine will automatically select the supported precision
    ///   - antiAliasing: Anti-aliasing level, default is 1
    init(_ engine: Engine,
         _ width: Int, _ height: Int,
         _ colorTexture: MTLTexture,
         _ depthFormat: MTLPixelFormat? = nil,
         _ antiAliasing: Int = 1) {
        _width = width
        _height = height
        _antiAliasing = antiAliasing
        if depthFormat == nil {
            _depth = nil
        } else {
            _depth = .RenderBufferDepthFormat(depthFormat!)
        }

        _colorTextures = [colorTexture]

        super.init(engine)

        _platformRenderTarget = MTLRenderPassDescriptor()
    }

    /// Create a render target through color texture and depth format.
    /// - Remark: If the color texture is not transmitted, only the depth texture is generated.
    /// - Parameters:
    ///   - engine: Define the engine to use for this off-screen rendering
    ///   - width: Render target width
    ///   - height: Render target height
    ///   - colorTexture: Render color texture
    ///   - depthTexture: Render depth texture
    ///   - antiAliasing: Anti-aliasing level, default is 1
    init(_ engine: Engine,
         _ width: Int, _ height: Int,
         _ colorTexture: MTLTexture?,
         _ depthTexture: MTLTexture,
         _ antiAliasing: Int = 1) {
        _width = width
        _height = height
        _antiAliasing = antiAliasing
        _depth = .RenderDepthTexture(depthTexture)

        if colorTexture == nil {
            _colorTextures = []
        } else {
            _colorTextures = [colorTexture!]
        }
        _depthTexture = depthTexture

        super.init(engine)

        _platformRenderTarget = MTLRenderPassDescriptor()
    }

    /// Create a render target with color texture array and depth format.
    /// - Parameters:
    ///   - engine: Define the engine to use for this off-screen rendering
    ///   - width: Render target width
    ///   - height: Render target height
    ///   - colorTextures: Render color texture array
    ///   - depthFormat: Depth format. default RenderBufferDepthFormat.Depth,engine will automatically select the supported precision
    ///   - antiAliasing: Anti-aliasing level, default is 1
    init(_ engine: Engine,
         _ width: Int, _ height: Int,
         _ colorTextures: [MTLTexture],
         _ depthFormat: MTLPixelFormat? = nil,
         _ antiAliasing: Int = 1) {
        _width = width
        _height = height
        _antiAliasing = antiAliasing
        if depthFormat == nil {
            _depth = nil
        } else {
            _depth = .RenderBufferDepthFormat(depthFormat!)
        }

        _colorTextures = colorTextures

        super.init(engine)

        _platformRenderTarget = MTLRenderPassDescriptor()
    }

    /// Create a render target with color texture array and depth texture.
    /// - Parameters:
    ///   - engine: Define the engine to use for this off-screen rendering
    ///   - width: Render target width
    ///   - height: Render target height
    ///   - colorTextures: Render color texture array
    ///   - depthTexture: Depth texture
    ///   - antiAliasing: Anti-aliasing level, default is 1
    init(_ engine: Engine,
         _ width: Int, height: Int,
         _ colorTextures: [MTLTexture],
         _ depthTexture: MTLTexture,
         _ antiAliasing: Int = 1) {
        _width = width
        _height = height
        _antiAliasing = antiAliasing
        _depth = .RenderDepthTexture(depthTexture)

        _colorTextures = colorTextures
        _depthTexture = depthTexture

        super.init(engine)

        _platformRenderTarget = MTLRenderPassDescriptor()
    }

    /// Get the render color texture by index.
    /// - Parameter index: index
    func getColorTexture(_ index: Int = 0) -> MTLTexture? {
        return _colorTextures[index]
    }

    internal func _setRenderTargetFace(_ faceIndex: TextureCubeFace) {
        fatalError()
    }

    internal func _blitRenderTarget() {
        fatalError()
    }
}
