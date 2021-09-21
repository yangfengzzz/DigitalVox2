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

    private var _descriptor = MTLSamplerDescriptor()
    private var _sampleState: MTLSamplerState!
    private var _updateFlag = false

    /// Create texture in Metal platform.
    init(_ rhi: MetalRenderer, _ texture: Texture) {
        _texture = texture;
        _rhi = rhi;
    }

    var sampleState: MTLSamplerState {
        get {
            if _updateFlag {
                _sampleState = _rhi.device.makeSamplerState(descriptor: _descriptor)
                _updateFlag = false
            }
            return _sampleState
        }
    }
}

extension MetalTexture: IPlatformTexture {
    var wrapModeU: MTLSamplerAddressMode {
        get {
            _descriptor.sAddressMode
        }
        set {
            _descriptor.sAddressMode = newValue
            _updateFlag = true
        }
    }

    var wrapModeV: MTLSamplerAddressMode {
        get {
            _descriptor.tAddressMode
        }
        set {
            _descriptor.tAddressMode = newValue
            _updateFlag = true
        }
    }

    var filterMode: MTLSamplerMipFilter {
        get {
            _descriptor.mipFilter
        }
        set {
            _descriptor.mipFilter = newValue
            _updateFlag = true
        }
    }

    var anisoLevel: Int {
        get {
            _descriptor.maxAnisotropy
        }
        set {
            _descriptor.maxAnisotropy = newValue
            _updateFlag = true
        }
    }

    func destroy() {
    }
}
