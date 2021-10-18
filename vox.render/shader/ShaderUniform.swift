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

    private var _rhi: MetalRenderer
    private var _encoder: MTLRenderCommandEncoder

    init(_ engine: Engine) {
        _rhi = engine._hardwareRenderer
        _encoder = engine._hardwareRenderer.renderEncoder
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

                    _encoder.setVertexBytes(&value,
                            length: MemoryLayout<Float>.stride,
                            index: shaderUniform.location)
                }
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

                    _encoder.setFragmentBytes(&value,
                            length: MemoryLayout<Float>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }

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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD2<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }

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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }

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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD3<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }

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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD4<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setVertexBytes(&cache.elements,
                            length: MemoryLayout<SIMD4<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD4<Float>>.stride,
                            index: shaderUniform.location)
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

                    _encoder.setFragmentBytes(&cache.elements,
                            length: MemoryLayout<SIMD4<Float>>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }
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

                    _encoder.setVertexBytes(&value,
                            length: MemoryLayout<Int>.stride,
                            index: shaderUniform.location)
                }
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

                    _encoder.setFragmentBytes(&value,
                            length: MemoryLayout<Int>.stride,
                            index: shaderUniform.location)
                }
            default:
                return
            }
        default:
            return
        }
    }
}

extension ShaderUniform {
    func uploadVertexMat4(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Matrix(let value):
            _encoder.setVertexBytes(&value.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: shaderUniform.location)
        default:
            return
        }
    }

    func uploadFragMat4(_ shaderUniform: ShaderUniform, _ value: ShaderPropertyValueType) {
        switch value {
        case .Matrix(let value):
            _encoder.setFragmentBytes(&value.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
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
