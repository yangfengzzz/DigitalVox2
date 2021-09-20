//
//  Texture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import MetalKit

/// The base class of texture, contains some common functions of texture-related classes.
class Texture: RefObject {
    var name: String!

    internal var _platformTexture: IPlatformTexture!
    internal var _mipmap: Bool!

    var _width: Int!
    var _height: Int!
    var _mipmapCount: Int!

    private var _wrapModeU: MTLSamplerAddressMode!
    private var _wrapModeV: MTLSamplerAddressMode!
    private var _filterMode: MTLSamplerMipFilter!
    private var _anisoLevel: Int = 1

    /// The width of the texture.
    var width: Int {
        get {
            _width
        }
    }

    /// The height of the texture.
    var height: Int {
        get {
            _height
        }
    }

    /// Wrapping mode for texture coordinate S.
    var wrapModeU: MTLSamplerAddressMode {
        get {
            _wrapModeU
        }
        set {
            if (newValue == _wrapModeU) {
                return
            }
            _wrapModeU = newValue

            _platformTexture.wrapModeU = newValue
        }
    }

    /// Wrapping mode for texture coordinate T.
    var wrapModeV: MTLSamplerAddressMode {
        get {
            _wrapModeV
        }
        set {
            if (newValue == _wrapModeV) {
                return
            }
            _wrapModeV = newValue

            _platformTexture.wrapModeV = newValue
        }
    }

    /// Texture mipmapping count.
    var mipmapCount: Int {
        get {
            _mipmapCount
        }
    }

    /**
     * Filter mode for texture.
     */
    var filterMode: MTLSamplerMipFilter {
        get {
            _filterMode
        }
        set {
            if (newValue == _filterMode) {
                return
            }
            _filterMode = newValue

            _platformTexture.filterMode = newValue
        }
    }

    /// Anisotropic level for texture.
    var anisoLevel: Int {
        get {
            _anisoLevel
        }
        set {
            let max = _engine._hardwareRenderer.maxAnisotropy

            var newValue = newValue
            if (newValue > max) {
                logger.warning("anisoLevel:\(newValue), exceeds the limit and is automatically downgraded to:\(max)")
                newValue = max
            }

            if (newValue < 1) {
                logger.warning("anisoLevel:\(newValue), must be greater than 0, and is automatically downgraded to 1")
                newValue = 1
            }

            if (newValue == _anisoLevel) {
                return
            }

            _anisoLevel = newValue

            _platformTexture.anisoLevel = newValue
        }
    }

    /// Generate multi-level textures based on the 0th level data.
    func generateMipmaps() {
        if (!_mipmap) {
            return
        }

        _platformTexture.generateMipmaps()
    }

    func _onDestroy() {
        _platformTexture.destroy()
        _platformTexture = nil
    }

    /// Get the maximum mip level of the corresponding size:rounding down.
    /// - Remark  http://download.nvidia.com/developer/Papers/2005/NP2_Mipmapping/NP2_Mipmap_Creation.pdf
    func _getMaxMiplevel(size: Int) -> Int {
        Int(floor(log2(Double(size))))
    }

    func _getMipmapCount() -> Int {
        Int(_mipmap ? floor(log2(Double(max(_width, _height)))) + 1 : 1)
    }
}
