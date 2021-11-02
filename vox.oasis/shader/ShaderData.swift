//
//  ShaderData.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Metal

//MARK: - ShaderBytesType
protocol ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform)
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform)
}

extension Int: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setVertexBytes(&value,
                length: MemoryLayout<Int>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setFragmentBytes(&value,
                length: MemoryLayout<Int>.stride,
                index: shaderUniform.location)
    }
}

extension Float: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setVertexBytes(&value,
                length: MemoryLayout<Float>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        var value = self
        rhi.renderEncoder.setFragmentBytes(&value,
                length: MemoryLayout<Float>.stride,
                index: shaderUniform.location)
    }
}

extension Vector2: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setVertexBytes(&self.elements,
                length: MemoryLayout<SIMD2<Float>>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setFragmentBytes(&self.elements,
                length: MemoryLayout<SIMD2<Float>>.stride,
                index: shaderUniform.location)
    }
}

extension Vector3: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setVertexBytes(&self.elements,
                length: MemoryLayout<SIMD3<Float>>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setFragmentBytes(&self.elements,
                length: MemoryLayout<SIMD3<Float>>.stride,
                index: shaderUniform.location)
    }
}

extension Vector4: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setVertexBytes(&self.elements,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setFragmentBytes(&self.elements,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: shaderUniform.location)
    }
}

extension Color: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setVertexBytes(&self.elements,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setFragmentBytes(&self.elements,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: shaderUniform.location)
    }
}

extension Matrix: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setVertexBytes(&self.elements,
                length: MemoryLayout<matrix_float4x4>.stride,
                index: shaderUniform.location)
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        rhi.renderEncoder.setFragmentBytes(&self.elements,
                length: MemoryLayout<matrix_float4x4>.stride,
                index: shaderUniform.location)
    }
}

extension Array: ShaderBytesType {
    func loadVetexBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        if Element.self == Int.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<Int>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == Float.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<Float>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD2<Float>.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<SIMD2<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD3<Float>.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<SIMD3<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD4<Float>.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<SIMD4<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == matrix_float4x4.self {
            rhi.renderEncoder.setVertexBytes(self,
                    length: MemoryLayout<matrix_float4x4>.stride * count,
                    index: shaderUniform.location)
        }
    }
    
    func loadFragmentBytes(_ rhi: MetalRenderer, _ shaderUniform: ShaderUniform) {
        if Element.self == Int.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<Int>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == Float.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<Float>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD2<Float>.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<SIMD2<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD3<Float>.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<SIMD3<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == SIMD4<Float>.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<SIMD4<Float>>.stride * count,
                    index: shaderUniform.location)
        } else if Element.self == matrix_float4x4.self {
            rhi.renderEncoder.setFragmentBytes(self,
                    length: MemoryLayout<matrix_float4x4>.stride * count,
                    index: shaderUniform.location)
        }
    }
}

//MARK: - ShaderPropertyValueType
enum ShaderPropertyValueType {
    case Bytes(ShaderBytesType)
    case Texture(MTLTexture)
    case TextureArray([MTLTexture])
    case Buffer(MTLBuffer)
}

///  Shader data collection,Correspondence includes shader properties data and macros data.
class ShaderData {
    internal var _group: ShaderDataGroup
    internal var _properties: [Int: ShaderPropertyValueType] = [:]
    internal var _macroCollection = ShaderMacroCollection()
    private var _refCount: Int = 0

    internal init(_ group: ShaderDataGroup) {
        _group = group
    }

    internal func _getData(_ property: String) -> ShaderPropertyValueType? {
        let property = Shader.getPropertyByName(property)
        return _getData(property)
    }

    internal func _getData(_ property: ShaderProperty) -> ShaderPropertyValueType? {
        _properties[property._uniqueId]
    }

    internal func _setData(_ property: String, _ value: ShaderPropertyValueType) {
        let property = Shader.getPropertyByName(property)
        _setData(property, value)
    }

    internal func _setData(_ property: ShaderProperty, _ value: ShaderPropertyValueType) {
        if (property._group != _group) {
            if (property._group == nil) {
                property._group = _group
            } else {
                fatalError("Shader property \(property.name) has been used as \(String(describing: property._group)) property.")
            }
        }

        _properties[property._uniqueId] = value
    }

    internal func _getRefCount() -> Int {
        _refCount
    }

    internal func _addRefCount(_ value: Int) {
        _refCount += value
        let properties = _properties
        properties.forEach { (k: Int, property: ShaderPropertyValueType) in
        }
    }
}

extension ShaderData {
    //MARK: - Bytes
    /// Get float by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float
    func geBytes(_ propertyName: String) -> ShaderBytesType? {
        let p = _getData(propertyName)
        switch p {
        case .Bytes(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float
    func getBytes(_ property: ShaderProperty) -> ShaderBytesType? {
        let p = _getData(property)
        switch p {
        case .Bytes(let value):
            return value
        default:
            return nil
        }
    }

    /// Set float by shader property name.
    /// - Remark: Corresponding float shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Float
    func setBytes(_ propertyName: String, _ value: ShaderBytesType) {
        _setData(propertyName, .Bytes(value))
    }

    /// Set float by shader property.
    /// - Remark: Corresponding float shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float
    func setBytes(_ property: ShaderProperty, _ value: ShaderBytesType) {
        _setData(property, .Bytes(value))
    }

    //MARK: - Texture
    /// Get texture by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Texture
    func getTexture(_ propertyName: String) -> MTLTexture? {
        let p = _getData(propertyName)
        switch p {
        case .Texture(let value):
            return value
        default:
            return nil
        }
    }

    /// Get texture by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Texture
    func getTexture(_ property: ShaderProperty) -> MTLTexture? {
        let p = _getData(property)
        switch p {
        case .Texture(let value):
            return value
        default:
            return nil
        }
    }

    /// Set texture by shader property name.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Texture
    func setTexture(_ propertyName: String, _ value: MTLTexture) {
        _setData(propertyName, .Texture(value))
    }

    /// Set texture by shader property.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Texture
    func setTexture(_ property: ShaderProperty, _ value: MTLTexture) {
        _setData(property, .Texture(value))
    }

    //MARK: - TextureArray
    /// Get texture array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Texture array
    func getTextureArray(_ propertyName: String) -> [MTLTexture]? {
        let p = _getData(propertyName)
        switch p {
        case .TextureArray(let value):
            return value
        default:
            return nil
        }
    }

    /// Get texture array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Texture array
    func getTextureArray(_ property: ShaderProperty) -> [MTLTexture]? {
        let p = _getData(property)
        switch p {
        case .TextureArray(let value):
            return value
        default:
            return nil
        }
    }

    /// Set texture array by shader property name.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Texture array
    func setTextureArray(_ propertyName: String, _ value: [MTLTexture]) {
        _setData(propertyName, .TextureArray(value))
    }

    /// Set texture array by shader property.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Texture array
    func setTextureArray(_ property: ShaderProperty, _ value: [MTLTexture]) {
        _setData(property, .TextureArray(value))
    }
}

extension ShaderData {
    /// Enable macro.
    /// - Parameter macroName: Macro name
    func enableMacro(_ macroName: MacroName) {
        _macroCollection._value[macroName] = (1, .bool)
    }

    /// Enable macro.
    /// - Parameters:
    ///   - name: Macro name
    ///   - value: Macro value
    func enableMacro(_ macroName: MacroName, _ value: (Int, MTLDataType)) {
        _macroCollection._value[macroName] = value
    }

    /// Disable macro
    /// - Parameter macroName: Macro name
    func disableMacro(_ macroName: MacroName) {
        _macroCollection._value.removeValue(forKey: macroName)
    }
}

extension ShaderData: IClone {
    typealias Object = ShaderData

    func clone() -> ShaderData {
        let shaderData = ShaderData(_group)
        cloneTo(target: shaderData)
        return shaderData
    }

    func cloneTo(target: ShaderData) {
        let properties = _properties
        var targetProperties = target._properties
        properties.forEach { (k: Int, property: ShaderPropertyValueType) in
            switch property {
            case .Bytes(let property):
                targetProperties[k] = .Bytes(property)
            case .TextureArray(let property):
                targetProperties[k] = .TextureArray(property)
            case .Texture(let property):
                targetProperties[k] = .Texture(property)
            case .Buffer(let property):
                targetProperties[k] = .Buffer(property)
            }
        }
    }
}
