//
//  ShaderData.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Metal

enum ShaderPropertyValueType {
    case Float(Float)
    case Int(Int)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
    case Color(Color)
    case Matrix(Matrix)
    case Texture(Texture)
    case TextureArray([Texture])
    case Int32Array([Int])
    case Float32Array([Float])
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
    /// Get float by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float
    func getFloat(_ propertyName: String) -> Float? {
        let p = _getData(propertyName)
        switch p {
        case .Float(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float
    func getFloat(_ property: ShaderProperty) -> Float? {
        let p = _getData(property)
        switch p {
        case .Float(let value):
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
    func setFloat(_ propertyName: String, _ value: Float) {
        _setData(propertyName, .Float(value))
    }

    /// Set float by shader property.
    /// - Remark: Corresponding float shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float
    func setFloat(_ property: ShaderProperty, _ value: Float) {
        _setData(property, .Float(value))
    }

    /// Get int by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Int
    func getInt(_ propertyName: String) -> Int? {
        let p = _getData(propertyName)
        switch p {
        case .Int(let value):
            return value
        default:
            return nil
        }
    }

    /// Get int by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Int
    func getInt(_ property: ShaderProperty) -> Int? {
        let p = _getData(property)
        switch p {
        case .Int(let value):
            return value
        default:
            return nil
        }
    }

    /// Set int by shader property name.
    /// - Remark: Correspondence includes int and bool shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Int
    func setInt(_ propertyName: String, _ value: Int) {
        _setData(propertyName, .Int(value))
    }

    /// Set int by shader property.
    /// - Remark: Correspondence includes int and bool shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Int
    func setInt(_ property: ShaderProperty, _ value: Int) {
        _setData(property, .Int(value))
    }

    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getFloatArray(_ propertyName: String) -> [Float]? {
        let p = _getData(propertyName)
        switch p {
        case .Float32Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getFloatArray(_ property: ShaderProperty) -> [Float]? {
        let p = _getData(property)
        switch p {
        case .Float32Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Set float array by shader property name.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - propertyName:  Shader property name
    ///   - value: Float array
    func setFloatArray(_ propertyName: String, _ value: [Float]) {
        _setData(propertyName, .Float32Array(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setFloatArray(_ property: ShaderProperty, _ value: [Float]) {
        _setData(property, .Float32Array(value))
    }

    /// Get int array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Int Array
    func getIntArray(_ propertyName: String) -> [Int]? {
        let p = _getData(propertyName)
        switch p {
        case .Int32Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get int array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Int Array
    func getIntArray(_ property: ShaderProperty) -> [Int]? {
        let p = _getData(property)
        switch p {
        case .Int32Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Set int array by shader property name.
    /// - Remark: Correspondence includes bool array、int array、bvec2 array、bvec3 array、bvec4 array、ivec2 array、ivec3 array and ivec4 array shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Int Array
    func setIntArray(_ propertyName: String, _ value: [Int]) {
        _setData(propertyName, .Int32Array(value))
    }

    /// Set int array by shader property.
    /// - Remark: Correspondence includes bool array、int array、bvec2 array、bvec3 array、bvec4 array、ivec2 array、ivec3 array and ivec4 array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Int Array
    func setIntArray(_ property: ShaderProperty, _ value: [Int]) {
        _setData(property, .Int32Array(value))
    }

    /// Get two-dimensional from shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Two-dimensional vector
    func getVector2(_ propertyName: String) -> Vector2? {
        let p = _getData(propertyName)
        switch p {
        case .Vector2(let value):
            return value
        default:
            return nil
        }
    }

    /// Get two-dimensional from shader property.
    /// - Parameter property: Shader property
    /// - Returns: Two-dimensional vector
    func getVector2(_ property: ShaderProperty) -> Vector2? {
        let p = _getData(property)
        switch p {
        case .Vector2(let value):
            return value
        default:
            return nil
        }
    }

    /// Set two-dimensional vector from shader property name.
    /// - Remark: Correspondence includes vec2、ivec2 and bvec2 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Two-dimensional vector
    func setVector2(_ property: String, _ value: Vector2) {
        _setData(property, .Vector2(value))
    }

    /// Set two-dimensional vector from shader property.
    /// - Remark: Correspondence includes vec2、ivec2 and bvec2 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Two-dimensional vector
    func setVector2(_ property: ShaderProperty, _ value: Vector2) {
        _setData(property, .Vector2(value))
    }

    /// Get vector3 by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Three-dimensional vector
    func getVector3(_ propertyName: String) -> Vector3? {
        let p = _getData(propertyName)
        switch p {
        case .Vector3(let value):
            return value
        default:
            return nil
        }
    }

    /// Get vector3 by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Three-dimensional vector
    func getVector3(_ property: ShaderProperty) -> Vector3? {
        let p = _getData(property)
        switch p {
        case .Vector3(let value):
            return value
        default:
            return nil
        }
    }

    /// Set three dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec3、ivec3 and bvec3 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Three-dimensional vector
    func setVector3(_ property: String, _ value: Vector3) {
        _setData(property, .Vector3(value))
    }

    /// Set three dimensional vector by shader property.
    /// - Remark: Correspondence includes vec3、ivec3 and bvec3 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Three-dimensional vector
    func setVector3(_ property: ShaderProperty, _ value: Vector3) {
        _setData(property, .Vector3(value))
    }

    /// Get vector4 by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Four-dimensional vector
    func getVector4(_ propertyName: String) -> Vector4? {
        let p = _getData(propertyName)
        switch p {
        case .Vector4(let value):
            return value
        default:
            return nil
        }
    }

    /// Get vector4 by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Four-dimensional vector
    func getVector4(_ property: ShaderProperty) -> Vector4? {
        let p = _getData(property)
        switch p {
        case .Vector4(let value):
            return value
        default:
            return nil
        }
    }

    /// Set four-dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec4、ivec4 and bvec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Four-dimensional vector
    func setVector4(_ property: String, _ value: Vector4) {
        _setData(property, .Vector4(value))
    }

    /// Set four-dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec4、ivec4 and bvec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Four-dimensional vector
    func setVector4(_ property: ShaderProperty, _ value: Vector4) {
        _setData(property, .Vector4(value))
    }

    /// Get matrix by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Matrix
    func getMatrix(_ propertyName: String) -> Matrix? {
        let p = _getData(propertyName)
        switch p {
        case .Matrix(let value):
            return value
        default:
            return nil
        }
    }

    /// Get matrix by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Matrix
    func getMatrix(_ property: ShaderProperty) -> Matrix? {
        let p = _getData(property)
        switch p {
        case .Matrix(let value):
            return value
        default:
            return nil
        }
    }

    /// Set matrix by shader property name.
    /// - Remark: Correspondence includes matrix shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Matrix
    func setMatrix(_ propertyName: String, _ value: Matrix) {
        _setData(propertyName, .Matrix(value))
    }

    /// Set matrix by shader property name.
    /// - Remark: Correspondence includes matrix shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property
    ///   - value: Matrix
    func setMatrix(_ property: ShaderProperty, _ value: Matrix) {
        _setData(property, .Matrix(value))
    }

    /// Get color by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Color
    func getColor(_ propertyName: String) -> Color? {
        let p = _getData(propertyName)
        switch p {
        case .Color(let value):
            return value
        default:
            return nil
        }
    }

    /// Get color by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Color
    func getColor(_ property: ShaderProperty) -> Color? {
        let p = _getData(property)
        switch p {
        case .Color(let value):
            return value
        default:
            return nil
        }
    }

    /// Set color by shader property name.
    /// - Remark: Correspondence includes vec4 shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Color
    func setColor(_ propertyName: String, _ value: Color) {
        _setData(propertyName, .Color(value))
    }

    /// Set color by shader property name.
    /// - Remark: Correspondence includes vec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Color
    func setColor(_ property: ShaderProperty, _ value: Color) {
        _setData(property, .Color(value))
    }

    /// Get texture by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Texture
    func getTexture(_ propertyName: String) -> Texture? {
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
    func getTexture(_ property: ShaderProperty) -> Texture? {
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
    func setTexture(_ propertyName: String, _ value: Texture) {
        if (_getRefCount() > 0) {
            let lastValue: Texture? = getTexture(propertyName)
            if lastValue != nil {
                lastValue!._addRefCount(-1)
            }
            value._addRefCount(1)
        }
        _setData(propertyName, .Texture(value))
    }

    /// Set texture by shader property.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Texture
    func setTexture(_ property: ShaderProperty, _ value: Texture) {
        if (_getRefCount() > 0) {
            let lastValue: Texture? = getTexture(property)
            if lastValue != nil {
                lastValue!._addRefCount(-1)
            }
            value._addRefCount(1)
        }
        _setData(property, .Texture(value))
    }

    /// Get texture array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Texture array
    func getTextureArray(_ propertyName: String) -> [Texture]? {
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
    func getTextureArray(_ property: ShaderProperty) -> [Texture]? {
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
    func setTextureArray(_ propertyName: String, _ value: [Texture]) {
        if (_getRefCount() > 0) {
            let lastValue = getTextureArray(propertyName)
            if (lastValue != nil) {
                for i in 0..<lastValue!.count {
                    lastValue![i]._addRefCount(-1)
                }
            }

            for i in 0..<value.count {
                value[i]._addRefCount(1)
            }

        }
        _setData(propertyName, .TextureArray(value))
    }

    /// Set texture array by shader property.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Texture array
    func setTextureArray(_ property: ShaderProperty, _ value: [Texture]) {
        if (_getRefCount() > 0) {
            let lastValue = getTextureArray(property)
            if (lastValue != nil) {
                for i in 0..<lastValue!.count {
                    lastValue![i]._addRefCount(-1)
                }
            }

            for i in 0..<value.count {
                value[i]._addRefCount(1)
            }

        }
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
        _macroCollection._value[macroName] = (0, .bool)
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
            case .Float(let property):
                targetProperties[k] = .Float(property)
            case .Int(let property):
                targetProperties[k] = .Int(property)
            case .Vector2(let property):
                targetProperties[k] = .Vector2(property.clone())
            case .Vector3(let property):
                targetProperties[k] = .Vector3(property.clone())
            case .Vector4(let property):
                targetProperties[k] = .Vector4(property.clone())
            case .Color(let property):
                targetProperties[k] = .Color(property.clone())
            case .Matrix(let property):
                targetProperties[k] = .Matrix(property.clone())
            case .Float32Array(let property):
                targetProperties[k] = .Float32Array(property)
            case .Int32Array(let property):
                targetProperties[k] = .Int32Array(property)
            case .TextureArray(let property):
                targetProperties[k] = .TextureArray(property)
            case .Texture(let property):
                targetProperties[k] = .Texture(property)
            }
        }
    }
}
