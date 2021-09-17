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
}
