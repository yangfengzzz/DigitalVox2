//
//  ShaderUniform.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

enum CacheType {
    case Int(Int)
    case Float(Float)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
}

/// Shader uniform。
internal class ShaderUniform {
    var name: String!
    var propertyId: Int!
    var location: Int!
    var applyFunc: ((ShaderUniform, ShaderPropertyValueType) -> Void)!
    var cacheValue: CacheType!
    var textureDefault: MTLTexture!
    var bufferDataSize: Int!

    private var _rhi: MetalRenderer

    init(_ _rhi: MetalRenderer) {
        self._rhi = _rhi
    }
}

extension ShaderUniform {
    func uploadVertex1f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Float(var value):
            switch cacheValue {
            case .Float(let cache):
                if cache != value {
                    cacheValue = .Float(value)
                }
                _rhi.renderEncoder.setVertexBytes(&value,
                        length: MemoryLayout<Float>.stride,
                        index: shaderUniform.location)

            default:
                return
            }
        default:
            return
        }
    }

    func uploadFrag1f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Float(var value):
            switch cacheValue {
            case .Float(let cache):
                if cache != value {
                    cacheValue = .Float(value)
                }
                _rhi.renderEncoder.setFragmentBytes(&value,
                        length: MemoryLayout<Float>.stride,
                        index: shaderUniform.location)

            default:
                return
            }
        case .FloatArray(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<Float>.stride * value.count,
                    index: shaderUniform.location)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertex2f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector2(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.elements = value.elements
                    cacheValue = .Vector2(cache)
                }
            default:
                return
            }

        case .Vector3(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.x = value.x
                    cache.y = value.y
                    cacheValue = .Vector2(cache)
                }
            default:
                return
            }

        case .Vector4(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.x = value.x
                    cache.y = value.y
                    cacheValue = .Vector2(cache)
                }
            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.r || cache.y != value.g {
                    cache.x = value.r
                    cache.y = value.g
                    cacheValue = .Vector2(cache)
                }
            default:
                return
            }

        default:
            return
        }

        switch cacheValue {
        case .Vector2(let cache):
            _rhi.renderEncoder.setVertexBytes(&cache.elements,
                    length: MemoryLayout<SIMD2<Float>>.stride,
                    index: shaderUniform.location)
        default:
            return
        }
    }

    func uploadFrag2f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector2(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.elements = value.elements
                    cacheValue = .Vector2(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD2<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Vector3(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.x = value.x
                    cache.y = value.y
                    cacheValue = .Vector2(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD2<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Vector4(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.x || cache.y != value.y {
                    cache.x = value.x
                    cache.y = value.y
                    cacheValue = .Vector2(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD2<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector2(let cache):
                if cache.x != value.r || cache.y != value.g {
                    cache.x = value.r
                    cache.y = value.g
                    cacheValue = .Vector2(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD2<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Vector2Array(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<SIMD2<Float>>.stride * value.count,
                    index: shaderUniform.location)

        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertex3f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector3(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z {
                    cache.elements = value.elements
                    cacheValue = .Vector3(cache)
                }

            default:
                return
            }

        case .Vector4(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z {
                    cache.x = value.x
                    cache.y = value.y
                    cache.z = value.z
                    cacheValue = .Vector3(cache)
                }

            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.r || cache.y != value.g || cache.z != value.b {
                    cache.x = value.r
                    cache.y = value.g
                    cache.z = value.b
                    cacheValue = .Vector3(cache)
                }

            default:
                return
            }

        default:
            return
        }

        switch cacheValue {
        case .Vector3(let cache):
            _rhi.renderEncoder.setVertexBytes(&cache.elements,
                    length: MemoryLayout<SIMD3<Float>>.stride,
                    index: shaderUniform.location)
        default:
            return
        }
    }

    func uploadFrag3f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector3(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z {
                    cache.elements = value.elements
                    cacheValue = .Vector3(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD3<Float>>.stride,
                        index: shaderUniform.location)
            default:
                return
            }

        case .Vector4(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z {
                    cache.x = value.x
                    cache.y = value.y
                    cache.z = value.z
                    cacheValue = .Vector3(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD3<Float>>.stride,
                        index: shaderUniform.location)
            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector3(let cache):
                if cache.x != value.r || cache.y != value.g || cache.z != value.b {
                    cache.x = value.r
                    cache.y = value.g
                    cache.z = value.b
                    cacheValue = .Vector3(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD3<Float>>.stride,
                        index: shaderUniform.location)
            default:
                return
            }

        case .Vector3Array(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<SIMD3<Float>>.stride * value.count,
                    index: shaderUniform.location)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertex4f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector4(let value):
            switch cacheValue {
            case .Vector4(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z || cache.w != value.w {
                    cache.elements = value.elements
                    cacheValue = .Vector4(cache)
                }

            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector4(let cache):
                if cache.x != value.r || cache.y != value.g || cache.z != value.b || cache.w != value.a {
                    cache.elements = value.elements
                    cacheValue = .Vector4(cache)
                }

            default:
                return
            }
        default:
            return
        }

        switch cacheValue {
        case .Vector4(let cache):
            _rhi.renderEncoder.setVertexBytes(&cache.elements,
                    length: MemoryLayout<SIMD4<Float>>.stride,
                    index: shaderUniform.location)
        default:
            return
        }
    }


    func uploadFrag4f(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Vector4(let value):
            switch cacheValue {
            case .Vector4(let cache):
                if cache.x != value.x || cache.y != value.y || cache.z != value.z || cache.w != value.w {
                    cache.elements = value.elements
                    cacheValue = .Vector4(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD4<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Color(let value):
            switch cacheValue {
            case .Vector4(let cache):
                if cache.x != value.r || cache.y != value.g || cache.z != value.b || cache.w != value.a {
                    cache.elements = value.elements
                    cacheValue = .Vector4(cache)
                }
                _rhi.renderEncoder.setFragmentBytes(&cache.elements,
                        length: MemoryLayout<SIMD4<Float>>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .Vector4Array(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<SIMD4<Float>>.stride * value.count,
                    index: shaderUniform.location)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertex1i(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Int(var value):
            switch cacheValue {
            case .Int(let cache):
                if cache != value {
                    cacheValue = .Int(value)
                }
                _rhi.renderEncoder.setVertexBytes(&value,
                        length: MemoryLayout<Int>.stride,
                        index: shaderUniform.location)

            default:
                return
            }
        default:
            return
        }
    }

    func uploadFrag1i(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Int(var value):
            switch cacheValue {
            case .Int(let cache):
                if cache != value {
                    cacheValue = .Int(value)
                }
                _rhi.renderEncoder.setFragmentBytes(&value,
                        length: MemoryLayout<Int>.stride,
                        index: shaderUniform.location)

            default:
                return
            }

        case .IntArray(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<Int>.stride * value.count,
                    index: shaderUniform.location)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertexMat4(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Matrix(let value):
            _rhi.renderEncoder.setVertexBytes(&value.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: shaderUniform.location)
        default:
            return
        }
    }

    func uploadFragMat4(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Matrix(let value):
            _rhi.renderEncoder.setFragmentBytes(&value.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: shaderUniform.location)

        case .MatrixArray(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: MemoryLayout<matrix_float4x4>.stride * value.count,
                    index: shaderUniform.location)
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertexAny(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .AnyType(var value):
            _rhi.renderEncoder.setVertexBytes(&value,
                    length: bufferDataSize,
                    index: shaderUniform.location)
        default:
            return
        }
    }
    
    func uploadFragAny(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .AnyType(var value):
            _rhi.renderEncoder.setFragmentBytes(&value,
                    length: bufferDataSize,
                    index: shaderUniform.location)
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