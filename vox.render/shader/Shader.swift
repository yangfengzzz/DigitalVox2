//
//  Shader.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Shader containing vertex and fragment source.
class Shader {
    private static var _shaderCounter: Int = 0
    private static var _shaderMap: [String: Shader] = [:]
    private static var _propertyNameMap: [String: ShaderProperty] = [:]

    /// The name of shader.
    var name: String

    internal var _shaderId: Int = 0

    private var _vertexSource: String
    private var _fragmentSource: String

    private init(_ name: String, _  vertexSource: String, _ fragmentSource: String) {
        _shaderId = Shader._shaderCounter
        Shader._shaderCounter += 1
        self.name = name
        _vertexSource = vertexSource
        _fragmentSource = fragmentSource
    }
}

extension Shader {
    /// Create a shader.
    /// - Parameters:
    ///   - name: Name of the shader
    ///   - vertexSource: Vertex source code
    ///   - fragmentSource: Fragment source code
    /// - Returns: Shader
    static func create(_ name: String, _  vertexSource: String, _  fragmentSource: String) -> Shader {
        if (Shader._shaderMap[name] != nil) {
            fatalError("Shader named \(name) already exists.")
        }
        let shader = Shader(name, vertexSource, fragmentSource)
        Shader._shaderMap[name] = shader
        return shader
    }

    /// Find a shader by name.
    /// - Parameter name: Name of the shader
    /// - Returns: Shader
    static func find(_ name: String) -> Shader? {
        Shader._shaderMap[name]
    }

    /// Get shader property by name.
    /// - Parameter name: Name of the shader property
    /// - Returns: Shader property
    static func getPropertyByName(_ name: String) -> ShaderProperty {
        var propertyNameMap = Shader._propertyNameMap
        if (propertyNameMap[name] != nil) {
            return propertyNameMap[name]!
        } else {
            let property = ShaderProperty(name)
            propertyNameMap[name] = property
            return property
        }
    }

    static internal func _getShaderPropertyGroup(_ propertyName: String) -> ShaderDataGroup? {
        let shaderProperty = Shader._propertyNameMap[propertyName]
        return shaderProperty?._group
    }
}

extension Shader {
    internal func _getShaderProgram(_ engine: Engine) -> ShaderProgram {
        ShaderProgram(engine, _vertexSource, _fragmentSource)
    }
}
