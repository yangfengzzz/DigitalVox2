//
//  ResourceCache.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/14.
//

import Metal

/// Struct to hold the internal state of the Resource Cache
struct ResourceCacheState {
    var shader_modules: [Int: ShaderProgram] = [:]

    var render_passes: [Int: RenderPass] = [:]

    var graphics_pipelines: [Int: RenderPipelineState] = [:]

    var compute_pipelines: [Int: ComputePipelineState] = [:]
}

/// Cache all sorts of Vulkan objects specific to a Vulkan device.
/// Supports serialization and deserialization of cached resources.
/// There is only one cache for all these objects, with several unordered_map of hash indices
/// and objects. For every object requested, there is a templated version on request_resource.
/// Some objects may need building if they are not found in the cache.
///
/// The resource cache is also linked with ResourceRecord and ResourceReplay. Replay can warm-up
/// the cache on app startup by creating all necessary objects.
/// The cache holds pointers to objects and has a mapping from such pointers to hashes.
/// It can only be destroyed in bulk, single elements cannot be removed.
class ResourceCache {
    var device: MTLDevice
    var state = ResourceCacheState()

    init(_ device: MTLDevice) {
        self.device = device
    }

    
    func request_shader_module(_ stage: MTLFunctionType, _ source: ShaderProgram) -> ShaderProgram {
        fatalError()
    }

    func request_graphics_pipeline(_ pipelineDescriptor: MTLRenderPipelineDescriptor) -> RenderPipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = state.graphics_pipelines[hash]
        if pipelineState == nil {
            pipelineState = RenderPipelineState(device, pipelineDescriptor)
            state.graphics_pipelines[hash] = pipelineState
        }
        
        return pipelineState!
    }

    func request_compute_pipeline(_ pipelineDescriptor: MTLComputePipelineDescriptor) -> ComputePipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = state.compute_pipelines[hash]
        if pipelineState == nil {
            pipelineState = ComputePipelineState(device, pipelineDescriptor)
            state.compute_pipelines[hash] = pipelineState
        }
        
        return pipelineState!
    }

    func clear_pipelines() {
        fatalError()
    }

    func clear() {
        fatalError()
    }

    func get_internal_state() -> ResourceCacheState {
        fatalError()
    }
}
