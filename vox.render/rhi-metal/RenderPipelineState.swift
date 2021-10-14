//
//  RenderPipelineState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

class RenderPipelineState {
    private var _reflection: MTLRenderPipelineReflection?
    private var _handle: MTLRenderPipelineState?
    
    init(_ device: MTLDevice, _ descriptor:MTLRenderPipelineDescriptor) {        
        do {
            _handle = try device.makeRenderPipelineState(descriptor: descriptor,
                            options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    var handle: MTLRenderPipelineState {
        get {
            return _handle!
        }
    }

    var reflection: MTLRenderPipelineReflection {
        get {
            return _reflection!
        }
    }
}
