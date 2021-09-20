//
//  Shader.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Shader containing vertex and fragment source.
class Shader {
    static internal var _compileMacros: ShaderMacroCollection = ShaderMacroCollection()

    private static var _shaderCounter: Int = 0
    private static var _shaderMap: [String: Shader] = [:]
    private static var _propertyNameMap: [String: ShaderProperty] = [:]
    private static var _macroMaskMap: [[MacroInfo]] = [[]]
    private static var _macroCounter: Int = 0
    private static var _macroMap: [MacroInfo: ShaderMacro] = [:]

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

    /// Get shader macro by info.
    /// - Parameter info: Info of the shader macro
    /// - Returns: Shader macro
    static func getMacroByInfo(_ info: MacroInfo) -> ShaderMacro {
        var macro = Shader._macroMap[info]
        if macro == nil {
            let counter = Shader._macroCounter
            let index = Int(floor(Float(counter) / 32))
            let bit = counter % 32
            macro = ShaderMacro(info.name, index, 1 << bit)
            Shader._macroMap[info] = macro
            if (index == Shader._macroMaskMap.count) {
                Shader._macroMaskMap.append([MacroInfo](repeating: MacroInfo(None), count: 32))
            }
            Shader._macroMaskMap[index][bit] = info
            Shader._macroCounter += 1
        }
        return macro!
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

    static private func _getInfosByMacros(_ macros: ShaderMacroCollection, _ out: inout [MacroInfo]) {
        let maskMap = Shader._macroMaskMap
        let mask = macros._mask
        out = []
        for i in 0..<macros._length {
            let subMaskMap = maskMap[i]
            let subMask = mask[i]
            // if is negative must contain 1 << 31.
            let n = subMask < 0 ? 32 : Int(floor(log2(Float(subMask)))) + 1
            for j in 0..<n {
                if (subMask & (1 << j)) != 0 {
                    out.append(subMaskMap[j])
                }
            }
        }
    }
}

extension Shader {
    /// Compile shader variant by macro info list.
    /// - Remark:
    /// Usually a shader contains some macros,any combination of macros is called shader variant.
    /// - Parameters:
    ///   - engine: Engine to which the shader variant belongs
    ///   - macros: Macro info list
    /// - Returns: Is the compiled shader variant valid
    func compileVariant(engine: Engine, macros: [MacroInfo]) -> Bool {
        let compileMacros = Shader._compileMacros
        compileMacros.clear()
        for i in 0..<macros.count {
            compileMacros.enable(Shader.getMacroByInfo(macros[i]))
        }
        return _getShaderProgram(engine, compileMacros).isValid
    }

    internal func _getShaderProgram(_ engine: Engine, _ macroCollection: ShaderMacroCollection) -> ShaderProgram {
        var macroInfoList: [MacroInfo] = []
        Shader._getInfosByMacros(macroCollection, &macroInfoList)

        return ShaderProgram(engine, _vertexSource, _fragmentSource, macroInfoList)
    }
}
