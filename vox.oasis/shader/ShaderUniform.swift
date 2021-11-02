//
//  ShaderUniform.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

/// Shader uniform。
internal class ShaderUniform {
    var name: String!
    var propertyId: Int!
    var location: Int!
    var applyFunc: ((ShaderUniform, ShaderPropertyValueType) -> Void)!
    var textureDefault: MTLTexture!
    var bufferDataSize: Int!

    private var _rhi: MetalRenderer

    init(_ _rhi: MetalRenderer) {
        self._rhi = _rhi
    }
}

extension ShaderUniform {
    func uploadVertexBytes(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Bytes(let value):
            value.loadVetexBytes(_rhi, shaderUniform)
        default:
            return
        }
    }

    func uploadFragmentBytes(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Bytes(let value):
            value.loadFragmentBytes(_rhi, shaderUniform)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadTexture(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Texture(let value):
            _rhi.bindTexture(value, shaderUniform.location)

        default:
            return
        }
    }
}
