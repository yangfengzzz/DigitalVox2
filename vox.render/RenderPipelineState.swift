//
//  RenderPipelineState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

class RenderPipelineState {
    private let _engine: Engine
    private var _reflection: MTLRenderPipelineReflection?
    private var _pipelineStateCache: MTLRenderPipelineState?
    private let _pipelineDescriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _updateFlag = false

    init(_ engine: Engine) {
        _engine = engine
        _pipelineDescriptor.colorAttachments[0].pixelFormat = engine._hardwareRenderer.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    }

    var pipelineState: MTLRenderPipelineState? {
        get {
            if _updateFlag == true {
                _makePipelineState()
                _updateFlag = false
            }
            return _pipelineStateCache
        }
    }

    var reflection: MTLRenderPipelineReflection? {
        get {
            if _updateFlag == true {
                _makePipelineState()
                _updateFlag = false
            }
            return _reflection
        }
    }

    var vertexDescriptor: MTLVertexDescriptor? {
        get {
            _pipelineDescriptor.vertexDescriptor
        }
        set {
            if _pipelineDescriptor.vertexDescriptor !== newValue {
                _pipelineDescriptor.vertexDescriptor = newValue
                _updateFlag = true
            }
        }
    }

    var vertexShader: MTLFunction? {
        get {
            _pipelineDescriptor.vertexFunction
        }
        set {
            if _pipelineDescriptor.vertexFunction !== newValue {
                _pipelineDescriptor.vertexFunction = newValue
                _updateFlag = true
            }
        }
    }

    var fragmentShader: MTLFunction? {
        get {
            _pipelineDescriptor.fragmentFunction
        }
        set {
            if _pipelineDescriptor.fragmentFunction !== newValue {
                _pipelineDescriptor.fragmentFunction = newValue
                _updateFlag = true
            }
        }
    }

    private func _makePipelineState() {
        do {
            _pipelineStateCache =
                    try _engine._hardwareRenderer.device.makeRenderPipelineState(descriptor: _pipelineDescriptor,
                            options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
