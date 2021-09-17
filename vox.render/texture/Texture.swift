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

    internal var _platformTexture: MTLTexture!
    internal var _mipmap: Bool!

    var _width: Int!
    var _height: Int!
    var _mipmapCount: Int!

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

    /// Texture mipmapping count.
    var mipmapCount: Int {
        get {
            _mipmapCount
        }
    }

    /// Generate multi-level textures based on the 0th level data.
    func generateMipmaps() {
        if (!_mipmap) {
            return
        }

        fatalError("TODO")
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
