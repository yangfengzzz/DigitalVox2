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

    private var _encoder: MTLRenderCommandEncoder

    init(_ engine: Engine) {
        _encoder = engine._hardwareRenderer.renderEncoder
    }
}

extension ShaderUniform {
    func upload1f(_ shaderUniform: ShaderUniform, _ value: inout Float) {
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
    }

    func upload1fv(_ shaderUniform: ShaderUniform, _ value: inout [Float]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<Float>.stride * value.count,
                index: shaderUniform.location)
    }
}

extension ShaderUniform {
    func upload2f(_ shaderUniform: ShaderUniform, _ value: Vector2) {
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
    }

    func upload2f(_ shaderUniform: ShaderUniform, _ value: Vector3) {
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
    }

    func upload2f(_ shaderUniform: ShaderUniform, _ value: Vector4) {
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
    }

    func upload2f(_ shaderUniform: ShaderUniform, _ value: Color) {
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
    }

    func upload2fv(_ shaderUniform: ShaderUniform, _ value: inout [SIMD2<Float>]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<SIMD2<Float>>.stride * value.count,
                index: shaderUniform.location)
    }
}

extension ShaderUniform {
    func upload3f(_ shaderUniform: ShaderUniform, _ value: Vector3) {
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
    }

    func upload3f(_ shaderUniform: ShaderUniform, _ value: Vector4) {
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
    }

    func upload3f(_ shaderUniform: ShaderUniform, _ value: Color) {
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
    }

    func upload3fv(_ shaderUniform: ShaderUniform, _ value: inout [SIMD3<Float>]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<SIMD3<Float>>.stride * value.count,
                index: shaderUniform.location)
    }
}

extension ShaderUniform {
    func upload4f(_ shaderUniform: ShaderUniform, _ value: Vector4) {
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
    }

    func upload4f(_ shaderUniform: ShaderUniform, _ value: Color) {
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
    }

    func upload4fv(_ shaderUniform: ShaderUniform, _ value: inout [SIMD4<Float>]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<SIMD4<Float>>.stride * value.count,
                index: shaderUniform.location)
    }
}

extension ShaderUniform {
    func upload1i(_ shaderUniform: ShaderUniform, _ value: inout Int) {
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
    }

    func upload1iv(_ shaderUniform: ShaderUniform, _ value: inout [Int]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<Int>.stride * value.count,
                index: shaderUniform.location)
    }
}

extension ShaderUniform {
    func uploadMat4(_ shaderUniform: ShaderUniform, _ value: Matrix) {
        _encoder.setVertexBytes(&value.elements,
                length: MemoryLayout<matrix_float4x4>.stride,
                index: shaderUniform.location)
    }

    func uploadMat4v(_ shaderUniform: ShaderUniform, _ value: inout [matrix_float4x4]) {
        _encoder.setVertexBytes(&value,
                length: MemoryLayout<matrix_float4x4>.stride * value.count,
                index: shaderUniform.location)
    }
}
