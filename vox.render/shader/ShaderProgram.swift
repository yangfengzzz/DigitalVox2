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

    var sceneUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var cameraUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var rendererUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var materialUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var otherUniformBlock: ShaderUniformBlock = ShaderUniformBlock()

    internal var _uploadRenderCount: Int = -1
    internal var _uploadCamera: Camera!
    internal var _uploadRenderer: Renderer!
    internal var _uploadMaterial: Material!

    private var _isValid: Bool!
    private var _engine: Engine
    private var _library: MTLLibrary
    private var _vertexShader: MTLFunction!
    private var _fragmentShader: MTLFunction!
    private var _pipelineDescriptor: MTLRenderPipelineDescriptor!

    var pipelineDescriptor: MTLRenderPipelineDescriptor {
        get {
            _pipelineDescriptor
        }
    }

    /// Whether this shader program is valid.
    var isValid: Bool {
        get {
            _isValid
        }
    }

    init(_ engine: Engine, _ vertexSource: String, _ fragmentSource: String) {
        id = ShaderProgram._counter
        ShaderProgram._counter += 1

        _engine = engine
        _library = engine._hardwareRenderer.library
        _pipelineDescriptor = _createProgram(vertexSource, fragmentSource)

        if _pipelineDescriptor != nil {
            _isValid = true
        } else {
            _isValid = false
        }
    }

    /// init and link program with shader.
    /// - Parameters:
    ///   - vertexSource: vertex name
    ///   - fragmentSource: fragment name
    private func _createProgram(_ vertexSource: String, _ fragmentSource: String) -> MTLRenderPipelineDescriptor? {
        let vertexShader = _library.makeFunction(name: "vertex_simple")
        if vertexShader == nil {
            return nil
        }
        let fragmentShader = _library.makeFunction(name: "fragment_simple")
        if fragmentShader == nil {
            return nil
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexShader
        pipelineDescriptor.fragmentFunction = fragmentShader

        _vertexShader = vertexShader!
        _fragmentShader = fragmentShader!

        return pipelineDescriptor
    }
}
