//
//  ShaderData.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Metal

enum ShaderPropertyValueType {
    case Int(Int)
    case Float(Float)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
    case Color(Color)
    case Matrix(Matrix)
    case Texture(MTLTexture)

    case IntArray([Int])
    case FloatArray([Float])
    case Vector2Array([SIMD2<Float>])
    case Vector3Array([SIMD3<Float>])
    case Vector4Array([SIMD4<Float>])
    case ColorArray([SIMD4<Float>])
    case MatrixArray([matrix_float4x4])
    case TextureArray([MTLTexture])
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
    //MARK: - Float
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

    //MARK: - FloatArray
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getFloatArray(_ propertyName: String) -> [Float]? {
        let p = _getData(propertyName)
        switch p {
        case .FloatArray(let value):
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
        case .FloatArray(let value):
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
        _setData(propertyName, .FloatArray(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setFloatArray(_ property: ShaderProperty, _ value: [Float]) {
        _setData(property, .FloatArray(value))
    }

    //MARK: - Int
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

    //MARK: - IntArray
    /// Get int array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Int Array
    func getIntArray(_ propertyName: String) -> [Int]? {
        let p = _getData(propertyName)
        switch p {
        case .IntArray(let value):
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
        case .IntArray(let value):
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
        _setData(propertyName, .IntArray(value))
    }

    /// Set int array by shader property.
    /// - Remark: Correspondence includes bool array、int array、bvec2 array、bvec3 array、bvec4 array、ivec2 array、ivec3 array and ivec4 array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Int Array
    func setIntArray(_ property: ShaderProperty, _ value: [Int]) {
        _setData(property, .IntArray(value))
    }

    //MARK: - Vector2
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

    //MARK: - Vector2Array
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getVector2Array(_ propertyName: String) -> [SIMD2<Float>]? {
        let p = _getData(propertyName)
        switch p {
        case .Vector2Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getVector2Array(_ property: ShaderProperty) -> [SIMD2<Float>]? {
        let p = _getData(property)
        switch p {
        case .Vector2Array(let value):
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
    func setVector2Array(_ propertyName: String, _ value: [SIMD2<Float>]) {
        _setData(propertyName, .Vector2Array(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setVector2Array(_ property: ShaderProperty, _ value: [SIMD2<Float>]) {
        _setData(property, .Vector2Array(value))
    }

    //MARK: - Vector3
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

    //MARK: - Vector3Array
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getVector3Array(_ propertyName: String) -> [SIMD3<Float>]? {
        let p = _getData(propertyName)
        switch p {
        case .Vector3Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getVector3Array(_ property: ShaderProperty) -> [SIMD3<Float>]? {
        let p = _getData(property)
        switch p {
        case .Vector3Array(let value):
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
    func setVector3Array(_ propertyName: String, _ value: [SIMD3<Float>]) {
        _setData(propertyName, .Vector3Array(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setVector3Array(_ property: ShaderProperty, _ value: [SIMD3<Float>]) {
        _setData(property, .Vector3Array(value))
    }

    //MARK: - Vector4
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

    //MARK: - Vector4Array
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getVector4Array(_ propertyName: String) -> [SIMD4<Float>]? {
        let p = _getData(propertyName)
        switch p {
        case .Vector4Array(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getVector4Array(_ property: ShaderProperty) -> [SIMD4<Float>]? {
        let p = _getData(property)
        switch p {
        case .Vector4Array(let value):
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
    func setVector4Array(_ propertyName: String, _ value: [SIMD4<Float>]) {
        _setData(propertyName, .Vector4Array(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setVector4Array(_ property: ShaderProperty, _ value: [SIMD4<Float>]) {
        _setData(property, .Vector4Array(value))
    }

    //MARK: - Matrix
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

    //MARK: - Matrix4Array
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getMatrixArray(_ propertyName: String) -> [matrix_float4x4]? {
        let p = _getData(propertyName)
        switch p {
        case .MatrixArray(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getMatrixArray(_ property: ShaderProperty) -> [matrix_float4x4]? {
        let p = _getData(property)
        switch p {
        case .MatrixArray(let value):
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
    func setMatrixArray(_ propertyName: String, _ value: [matrix_float4x4]) {
        _setData(propertyName, .MatrixArray(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setMatrixArray(_ property: ShaderProperty, _ value: [matrix_float4x4]) {
        _setData(property, .MatrixArray(value))
    }

    //MARK: - Color
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

    //MARK: - ColorArray
    /// Get float array by shader property name.
    /// - Parameter propertyName: Shader property name
    /// - Returns: Float array
    func getColorArray(_ propertyName: String) -> [SIMD4<Float>]? {
        let p = _getData(propertyName)
        switch p {
        case .ColorArray(let value):
            return value
        default:
            return nil
        }
    }

    /// Get float array by shader property.
    /// - Parameter property: Shader property
    /// - Returns: Float array
    func getColorArray(_ property: ShaderProperty) -> [SIMD4<Float>]? {
        let p = _getData(property)
        switch p {
        case .ColorArray(let value):
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
    func setColorArray(_ propertyName: String, _ value: [SIMD4<Float>]) {
        _setData(propertyName, .ColorArray(value))
    }

    /// Set float array by shader property.
    /// - Remark: Correspondence includes float array、vec2 array、vec3 array、vec4 array and matrix array shader property type.
    /// - Parameters:
    ///   - property: Shader property
    ///   - value: Float array
    func setColorArray(_ property: ShaderProperty, _ value: [SIMD4<Float>]) {
        _setData(property, .ColorArray(value))
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
            case .Float(let property):
                targetProperties[k] = .Float(property)
            case .FloatArray(let property):
                targetProperties[k] = .FloatArray(property)
            case .Int(let property):
                targetProperties[k] = .Int(property)
            case .IntArray(let property):
                targetProperties[k] = .IntArray(property)
            case .Vector2(let property):
                targetProperties[k] = .Vector2(property.clone())
            case .Vector2Array(let property):
                targetProperties[k] = .Vector2Array(property)
            case .Vector3(let property):
                targetProperties[k] = .Vector3(property.clone())
            case .Vector3Array(let property):
                targetProperties[k] = .Vector3Array(property)
            case .Vector4(let property):
                targetProperties[k] = .Vector4(property.clone())
            case .Vector4Array(let property):
                targetProperties[k] = .Vector4Array(property)
            case .Color(let property):
                targetProperties[k] = .Color(property.clone())
            case .ColorArray(let property):
                targetProperties[k] = .ColorArray(property)
            case .Matrix(let property):
                targetProperties[k] = .Matrix(property.clone())
            case .MatrixArray(let property):
                targetProperties[k] = .MatrixArray(property)
            case .TextureArray(let property):
                targetProperties[k] = .TextureArray(property)
            case .Texture(let property):
                targetProperties[k] = .Texture(property)
            }
        }
    }
}
