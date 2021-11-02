//
//  RenderPipelineState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

class RenderPipelineState {
    private let _render: MetalRenderer
    private var _reflection: MTLRenderPipelineReflection?
    private var _handle: MTLRenderPipelineState?
    
    var sceneUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var cameraUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var rendererUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var materialUniformBlock: ShaderUniformBlock = ShaderUniformBlock()
    var otherUniformBlock: ShaderUniformBlock = ShaderUniformBlock()

    internal var _uploadRenderCount: Int = -1
    internal var _uploadCamera: Camera!
    internal var _uploadRenderer: Renderer!
    internal var _uploadMaterial: Material!
    
    init(_ _render: MetalRenderer, _ descriptor:MTLRenderPipelineDescriptor) {
        self._render = _render
        do {
            _handle = try _render.device.makeRenderPipelineState(descriptor: descriptor,
                            options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        _recordVertexLocation()
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

//MARK: - Grouping Uniform
extension RenderPipelineState {
    /// record the location of uniform/attribute.
    private func _recordVertexLocation() {
        guard let _reflection = _reflection else { return }
        
        var count = _reflection.vertexArguments?.count
        if count != nil {
            for i in 0..<count! {
                let aug = _reflection.vertexArguments![i]
                let type = aug.bufferDataType
                if type == .struct {
                    continue
                }

                let name = aug.name
                let location = aug.index
                let group = Shader._getShaderPropertyGroup(name)

                let shaderUniform = ShaderUniform(_render)
                shaderUniform.name = name
                shaderUniform.propertyId = Shader.getPropertyByName(name)._uniqueId
                shaderUniform.location = location

                switch type {
                case .float, .float2, .float3, .float4, .int, .float4x4:
                    shaderUniform.applyFunc = shaderUniform.uploadVertexBytes
                default:
                    fatalError("unkonwn type \(type.rawValue)")
                }
                _groupingUniform(shaderUniform, group, false)
            }
        }

        count = _reflection.fragmentArguments?.count
        if count != nil {
            for i in 0..<count! {
                let aug = _reflection.fragmentArguments![i]
                let type = aug.type

                let name = aug.name
                let location = aug.index
                let group = Shader._getShaderPropertyGroup(name)

                let shaderUniform = ShaderUniform(_render)
                shaderUniform.name = name
                shaderUniform.propertyId = Shader.getPropertyByName(name)._uniqueId
                shaderUniform.location = location

                if type == .buffer {
                    shaderUniform.bufferDataSize = aug.bufferDataSize
                    switch aug.bufferDataType {
                    case .float, .float2, .float3, .float4, .int, .float4x4, .struct:
                        shaderUniform.applyFunc = shaderUniform.uploadFragmentBytes
                    default:
                        print(aug)
                    }
                } else if type == .sampler {

                } else if type == .texture {
                    shaderUniform.applyFunc = shaderUniform.uploadTexture
                }

                _groupingUniform(shaderUniform, group, false)
            }
        }
    }

    private func _groupingUniform(_ uniform: ShaderUniform, _ group: ShaderDataGroup?, _ isTexture: Bool) {
        if group != nil {
            switch (group!) {
            case ShaderDataGroup.Scene:
                if (isTexture) {
                    sceneUniformBlock.textureUniforms.append(uniform)
                } else {
                    sceneUniformBlock.constUniforms.append(uniform)
                }
                break
            case ShaderDataGroup.Camera:
                if (isTexture) {
                    cameraUniformBlock.textureUniforms.append(uniform)
                } else {
                    cameraUniformBlock.constUniforms.append(uniform)
                }
                break
            case ShaderDataGroup.Renderer:
                if (isTexture) {
                    rendererUniformBlock.textureUniforms.append(uniform)
                } else {
                    rendererUniformBlock.constUniforms.append(uniform)
                }
                break
            case ShaderDataGroup.Material:
                if (isTexture) {
                    materialUniformBlock.textureUniforms.append(uniform)
                } else {
                    materialUniformBlock.constUniforms.append(uniform)
                }
                break
            }
        } else {
            if (isTexture) {
                otherUniformBlock.textureUniforms.append(uniform)
            } else {
                otherUniformBlock.constUniforms.append(uniform)
            }
        }
    }

    /// Grouping other data.
    func groupingOtherUniformBlock() {
        if otherUniformBlock.constUniforms.count > 0 {
            _groupingSubOtherUniforms(&otherUniformBlock.constUniforms, false)
        }

        if otherUniformBlock.textureUniforms.count > 0 {
            _groupingSubOtherUniforms(&otherUniformBlock.textureUniforms, true)
        }
    }

    private func _groupingSubOtherUniforms(_ uniforms: inout [ShaderUniform], _ isTexture: Bool) {
        for i in 0..<uniforms.count {
            let uniform = uniforms[i]
            let group = Shader._getShaderPropertyGroup(uniform.name)
            if (group != nil) {
                uniforms.removeAll { u in
                    u === uniform
                }
                _groupingUniform(uniform, group, isTexture)
            }
        }
    }
}

//MARK: - Upload Uniform
extension RenderPipelineState {
    /// Upload all shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    func uploadAll(_ uniformBlock: ShaderUniformBlock, _ shaderData: ShaderData) {
        uploadUniforms(uniformBlock, shaderData)
        uploadTextures(uniformBlock, shaderData)
    }

    /// Upload constant shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    func uploadUniforms(_ uniformBlock: ShaderUniformBlock, _ shaderData: ShaderData) {
        let properties = shaderData._properties
        let constUniforms = uniformBlock.constUniforms

        for i in 0..<constUniforms.count {
            let uniform = constUniforms[i]
            let data = properties[uniform.propertyId]
            if data != nil {
                uniform.applyFunc(uniform, data!)
            }
        }
    }

    /// Upload texture shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    func uploadTextures(_ uniformBlock: ShaderUniformBlock, _ shaderData: ShaderData) {
        let properties = shaderData._properties
        let textureUniforms = uniformBlock.textureUniforms
        // textureUniforms property maybe null if ShaderUniformBlock not contain any texture.
        if !textureUniforms.isEmpty {
            for i in 0..<textureUniforms.count {
                let uniform = textureUniforms[i]
                let texture = properties[uniform.propertyId]
                if (texture != nil) {
                    uniform.applyFunc(uniform, texture!)
                } else {
                    uniform.applyFunc(uniform, .Texture(uniform.textureDefault))
                }
            }
        }
    }
}
