//
//  ShaderProgram.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

/// Shader program, corresponding to the GPU shader program.
internal class ShaderProgram {
    private static var _counter: Int = 0

    var id: Int

    private var _isValid: Bool!
    private var _library: MTLLibrary
    private var _vertexShader: MTLFunction?
    private var _fragmentShader: MTLFunction?

    var vertexShader: MTLFunction? {
        get {
            _vertexShader
        }
    }

    var fragmentShader: MTLFunction? {
        get {
            _fragmentShader
        }
    }

    /// Whether this shader program is valid.
    var isValid: Bool {
        get {
            _isValid
        }
    }

    init(_ library: MTLLibrary, _ vertexSource: String, _ fragmentSource: String, _ macroInfo: ShaderMacroCollection) {
        id = ShaderProgram._counter
        ShaderProgram._counter += 1

        _library = library
        _createProgram(vertexSource, fragmentSource, macroInfo)

        if _vertexShader != nil && _fragmentShader != nil {
            _isValid = true
        } else {
            _isValid = false
        }
    }

    private func makeFunctionConstants(_ macroInfo: ShaderMacroCollection) -> MTLFunctionConstantValues {
        let functionConstants = ShaderMacroCollection.defaultFunctionConstant
        macroInfo._value.forEach { info in
            if info.value.1 == .bool {
                var property: Bool
                if info.value.0 == 1 {
                    property = true
                } else {
                    property = false
                }
                functionConstants.setConstantValue(&property, type: .bool, index: Int(info.key.rawValue))
            } else {
                var property = info.value.0
                functionConstants.setConstantValue(&property, type: info.value.1, index: Int(info.key.rawValue))
            }
        }
        return functionConstants
    }

    /// init and link program with shader.
    /// - Parameters:
    ///   - vertexSource: vertex name
    ///   - fragmentSource: fragment name
    private func _createProgram(_ vertexSource: String, _ fragmentSource: String,
                                _ macroInfo: ShaderMacroCollection) {
        let functionConstants = makeFunctionConstants(macroInfo)

        do {
            _vertexShader = try _library.makeFunction(name: vertexSource,
                    constantValues: functionConstants)

            _fragmentShader = try _library.makeFunction(name: fragmentSource,
                    constantValues: functionConstants)
        } catch {
            return
        }
    }
}
