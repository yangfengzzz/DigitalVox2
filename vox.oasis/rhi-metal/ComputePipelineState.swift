//
//  ComputePipelineState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/14.
//

import Metal

class ComputePipelineState {
    private var _reflection: MTLComputePipelineReflection?
    private var _handle: MTLComputePipelineState?
    
    init(_ device: MTLDevice, _ descriptor:MTLComputePipelineDescriptor) {
        do {
            _handle = try device.makeComputePipelineState(descriptor: descriptor,
                                                          options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    var handle: MTLComputePipelineState {
        get {
            return _handle!
        }
    }

    var reflection: MTLComputePipelineReflection {
        get {
            return _reflection!
        }
    }
}

