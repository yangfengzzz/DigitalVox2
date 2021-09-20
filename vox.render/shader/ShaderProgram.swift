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
    private var _engine: Engine
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

    init(_ engine: Engine, _ vertexSource: String, _ fragmentSource: String, _ macroInfo: [MacroInfo]) {
        id = ShaderProgram._counter
        ShaderProgram._counter += 1

        _engine = engine
        _library = engine._hardwareRenderer.library
        _createProgram(vertexSource, fragmentSource, macroInfo)

        if _vertexShader != nil && _fragmentShader != nil {
            _isValid = true
        } else {
            _isValid = false
        }
    }

    private func makeFunctionConstants(_ macroInfo: [MacroInfo]) -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        var property = true
        macroInfo.forEach { info in
            if info.pointer == nil {
                functionConstants.setConstantValue(&property, type: .bool, index: Int(info.name.rawValue))
            } else {
                functionConstants.setConstantValue(info.pointer!, type: info.type!, index: Int(info.name.rawValue))
            }
        }
        return functionConstants
    }

    /// init and link program with shader.
    /// - Parameters:
    ///   - vertexSource: vertex name
    ///   - fragmentSource: fragment name
    private func _createProgram(_ vertexSource: String, _ fragmentSource: String,
                                _ macroInfo: [MacroInfo]) {
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
