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

    var graphics_pipelines: [Int: RenderPipelineState] = [:]

    var compute_pipelines: [Int: ComputePipelineState] = [:]
    
    var render_passes: [Int: RenderPass] = [:]
}

/// Cache all sorts of Metal objects specific to a Metal device.
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
    weak var render: MetalRenderer?
    var state = ResourceCacheState()

    init(_ render: MetalRenderer) {
        self.render = render
    }

    func request_shader_module(_ vertexSource: String, _ fragmentSource: String, _ macroInfo: ShaderMacroCollection) -> ShaderProgram {
        var hasher = Hasher()
        vertexSource.hash(into: &hasher)
        fragmentSource.hash(into: &hasher)
        macroInfo.hash(into: &hasher)
        let hash = hasher.finalize()
        if state.shader_modules[hash] == nil {
            state.shader_modules[hash] = ShaderProgram(render!.library, vertexSource, fragmentSource, macroInfo)
        }
        return state.shader_modules[hash]!
    }

    func request_graphics_pipeline(_ pipelineDescriptor: MTLRenderPipelineDescriptor) -> RenderPipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = state.graphics_pipelines[hash]
        if pipelineState == nil {
            pipelineState = RenderPipelineState(render!.device, pipelineDescriptor)
            state.graphics_pipelines[hash] = pipelineState
        }
        
        return pipelineState!
    }

    func request_compute_pipeline(_ pipelineDescriptor: MTLComputePipelineDescriptor) -> ComputePipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = state.compute_pipelines[hash]
        if pipelineState == nil {
            pipelineState = ComputePipelineState(render!.device, pipelineDescriptor)
            state.compute_pipelines[hash] = pipelineState
        }
        
        return pipelineState!
    }

    func clear_pipelines() {
        state.compute_pipelines = [:]
        state.graphics_pipelines = [:]
    }

    func clear() {
        clear_pipelines()
        state.shader_modules = [:]
    }

    func get_internal_state() -> ResourceCacheState {
        state
    }
}
