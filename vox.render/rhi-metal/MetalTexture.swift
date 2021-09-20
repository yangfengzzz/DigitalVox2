//
//  MetalTexture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/21.
//

import MetalKit

/// Texture in Metal platform.
class MetalTexture {
    internal var _texture: Texture;
    internal var _rhi: MetalRenderer;
    internal var _mtlTexture: MTLTexture!
    internal var _descriptor = MTLSamplerDescriptor()

    /// Create texture in Metal platform.
    init(_ rhi: MetalRenderer, _ texture: Texture) {
        _texture = texture;
        _rhi = rhi;
    }
}

extension MetalTexture: IPlatformTexture {
    var wrapModeU: MTLSamplerAddressMode {
        get {
            _descriptor.sAddressMode
        }
        set {
            _descriptor.sAddressMode = newValue
        }
    }

    var wrapModeV: MTLSamplerAddressMode {
        get {
            _descriptor.tAddressMode
        }
        set {
            _descriptor.tAddressMode = newValue
        }
    }

    var filterMode: MTLSamplerMipFilter {
        get {
            _descriptor.mipFilter
        }
        set {
            _descriptor.mipFilter = newValue
        }
    }

    var anisoLevel: Int {
        get {
            _descriptor.maxAnisotropy
        }
        set {
            _descriptor.maxAnisotropy = newValue
        }
    }

    func destroy() {
    }

    func generateMipmaps() {
    }
}
