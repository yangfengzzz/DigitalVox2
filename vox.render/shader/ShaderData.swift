//
//  ShaderData.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

enum ShaderPropertyValueType {
    case Float(Float)
    case Int(Int)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
    case Color(Color)
    case Matrix(Matrix)
    case Int32Array([Int])
    case Float32Array([Float])
}

///  Shader data collection,Correspondence includes shader properties data and macros data.
class ShaderData {
    internal var _group: ShaderDataGroup
    internal var _properties: [Int: ShaderPropertyValueType] = [:]
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

    internal func _addRefCount(value: Int) {
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
    func getFloat(propertyName: String) -> Float {
        let p = _getData(propertyName)
        switch p {
        case .Float(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get float by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float
    func getFloat(property: ShaderProperty) -> Float {
        let p = _getData(property)
        switch p {
        case .Float(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set float by shader property name.
    /// - Remark: Corresponding float shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Float
    func setFloat(propertyName: String, value: Float) {
        _setData(propertyName, .Float(value))
    }

    /// Set float by shader property.
    /// - Remark: Corresponding float shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float
    func setFloat(property: ShaderProperty, value: Float) {
        _setData(property, .Float(value))
    }

    /// Get int by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Int
    func getInt(propertyName: String) -> Int {
        let p = _getData(propertyName)
        switch p {
        case .Int(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get int by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Int
    func getInt(property: ShaderProperty) -> Int {
        let p = _getData(property)
        switch p {
        case .Int(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set int by shader property name.
    /// - Remark: Correspondence includes int and bool shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Int
    func setInt(propertyName: String, value: Int) {
        _setData(propertyName, .Int(value))
    }

    /// Set int by shader property.
    /// - Remark: Correspondence includes int and bool shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Int
    func setInt(property: ShaderProperty, value: Int) {
        _setData(property, .Int(value))
    }

    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getFloatArray(propertyName: String) -> [Float] {
        let p = _getData(propertyName)
        switch p {
        case .Float32Array(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getFloatArray(property: ShaderProperty) -> [Float] {
        let p = _getData(property)
        switch p {
        case .Float32Array(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set float array by shader property name.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - propertyName:  Shader property name
    ///   - value: Float array
    func setFloatArray(propertyName: String, value: [Float]) {
        _setData(propertyName, .Float32Array(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setFloatArray(property: ShaderProperty, value: [Float]) {
        _setData(property, .Float32Array(value))
    }

    /// Get int array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Int Array
    func getIntArray(propertyName: String) -> [Int] {
        let p = _getData(propertyName)
        switch p {
        case .Int32Array(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get int array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Int Array
    func getIntArray(property: ShaderProperty) -> [Int] {
        let p = _getData(property)
        switch p {
        case .Int32Array(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set int array by shader property name.
    /// - Remark: Correspondence includes bool array、int array、bvec2 array、bvec3 array、bvec4 array、ivec2 array、ivec3 array and ivec4 array shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Int Array
    func setIntArray(propertyName: String, value: [Int]) {
        _setData(propertyName, .Int32Array(value))
    }

    /// Set int array by shader property.
    /// - Remark: Correspondence includes bool array、int array、bvec2 array、bvec3 array、bvec4 array、ivec2 array、ivec3 array and ivec4 array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Int Array
    func setIntArray(property: ShaderProperty, value: [Int]) {
        _setData(property, .Int32Array(value))
    }

    /// Get two-dimensional from shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Two-dimensional vector
    func getVector2(propertyName: String) -> Vector2 {
        let p = _getData(propertyName)
        switch p {
        case .Vector2(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get two-dimensional from shader property.
    /// - Parameter property: Shader property
    /// - Returns: Two-dimensional vector
    func getVector2(property: ShaderProperty) -> Vector2 {
        let p = _getData(property)
        switch p {
        case .Vector2(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set two-dimensional vector from shader property name.
    /// - Remark: Correspondence includes vec2、ivec2 and bvec2 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Two-dimensional vector
    func setVector2(property: String, value: Vector2) {
        _setData(property, .Vector2(value))
    }

    /// Set two-dimensional vector from shader property.
    /// - Remark: Correspondence includes vec2、ivec2 and bvec2 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Two-dimensional vector
    func setVector2(property: ShaderProperty, value: Vector2) {
        _setData(property, .Vector2(value))
    }

    /// Get vector3 by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Three-dimensional vector
    func getVector3(propertyName: String) -> Vector3 {
        let p = _getData(propertyName)
        switch p {
        case .Vector3(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get vector3 by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Three-dimensional vector
    func getVector3(property: ShaderProperty) -> Vector3 {
        let p = _getData(property)
        switch p {
        case .Vector3(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set three dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec3、ivec3 and bvec3 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Three-dimensional vector
    func setVector3(property: String, value: Vector3) {
        _setData(property, .Vector3(value))
    }

    /// Set three dimensional vector by shader property.
    /// - Remark: Correspondence includes vec3、ivec3 and bvec3 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Three-dimensional vector
    func setVector3(property: ShaderProperty, value: Vector3) {
        _setData(property, .Vector3(value))
    }

    /// Get vector4 by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Four-dimensional vector
    func getVector4(propertyName: String) -> Vector4 {
        let p = _getData(propertyName)
        switch p {
        case .Vector4(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get vector4 by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Four-dimensional vector
    func getVector4(property: ShaderProperty) -> Vector4 {
        let p = _getData(property)
        switch p {
        case .Vector4(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set four-dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec4、ivec4 and bvec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property name
    ///   - value: Four-dimensional vector
    func setVector4(property: String, value: Vector4) {
        _setData(property, .Vector4(value))
    }

    /// Set four-dimensional vector by shader property name.
    /// - Remark: Correspondence includes vec4、ivec4 and bvec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Four-dimensional vector
    func setVector4(property: ShaderProperty, value: Vector4) {
        _setData(property, .Vector4(value))
    }

    /// Get matrix by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Matrix
    func getMatrix(propertyName: String) -> Matrix {
        let p = _getData(propertyName)
        switch p {
        case .Matrix(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get matrix by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Matrix
    func getMatrix(property: ShaderProperty) -> Matrix {
        let p = _getData(property)
        switch p {
        case .Matrix(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set matrix by shader property name.
    /// - Remark: Correspondence includes matrix shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Matrix
    func setMatrix(propertyName: String, value: Matrix) {
        _setData(propertyName, .Matrix(value))
    }

    /// Set matrix by shader property name.
    /// - Remark: Correspondence includes matrix shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property
    ///   - value: Matrix
    func setMatrix(property: ShaderProperty, value: Matrix) {
        _setData(property, .Matrix(value))
    }

    /// Get color by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Color
    func getColor(propertyName: String) -> Color {
        let p = _getData(propertyName)
        switch p {
        case .Color(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Get color by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Color
    func getColor(property: ShaderProperty) -> Color {
        let p = _getData(property)
        switch p {
        case .Color(let value):
            return value
        default:
            fatalError()
        }
    }

    /// Set color by shader property name.
    /// - Remark: Correspondence includes vec4 shader property type.
    /// - Parameters:
    ///   - propertyName: Shader property name
    ///   - value: Color
    func setColor(propertyName: String, value: Color) {
        _setData(propertyName, .Color(value))
    }

    /// Set color by shader property name.
    /// - Remark: Correspondence includes vec4 shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Color
    func setColor(property: ShaderProperty, value: Color) {
        _setData(property, .Color(value))
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
            }
        }
    }
}
