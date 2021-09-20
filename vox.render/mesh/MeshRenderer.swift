//
//  MeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import MetalKit

class MeshRenderer: Renderer {
    private static var _uvMacro = Shader.getMacroByInfo(MacroInfo(HAS_UV))
    private static var _normalMacro = Shader.getMacroByInfo(MacroInfo(HAS_NORMAL))
    private static var _tangentMacro = Shader.getMacroByInfo(MacroInfo(HAS_TANGENT))
    private static var _vertexColorMacro = Shader.getMacroByInfo(MacroInfo(HAS_VERTEXCOLOR))

    // @ignoreClone
    private var _mesh: Mesh?
    // @ignoreClone
    private var _meshUpdateFlag: UpdateFlag?

    /// Mesh assigned to the renderer.
    var mesh: Mesh? {
        get {
            _mesh
        }
        set {
            let lastMesh = _mesh
            if (lastMesh !== newValue) {
                if (lastMesh != nil) {
                    lastMesh!._addRefCount(-1)
                    _meshUpdateFlag!.destroy()
                }
                if (newValue != nil) {
                    newValue!._addRefCount(1)
                    _meshUpdateFlag = newValue!.registerUpdateFlag()
                }
                _mesh = newValue
            }
        }
    }

    /// Set the first material.
    /// - Parameter material: The first material
    override func setMaterial(_ material: Material) {
        super.setMaterial(material)
        if mesh != nil {
            _pipelineStates.insert(makePipelineState(mesh!, material.shader._getShaderProgram(engine, ShaderMacroCollection())), at: 0)
        }
    }

    /// Set material by index.
    /// - Parameters:
    ///   - index: Material index
    ///   - material: The material
    override func setMaterial(_ index: Int, _ material: Material) {
        super.setMaterial(index, material)
        if mesh != nil {
            _pipelineStates.insert(makePipelineState(mesh!, material.shader._getShaderProgram(engine, ShaderMacroCollection())), at: index)
        }
    }

    /// Set all materials.
    /// - Parameter materials: All materials
    override func setMaterials(_ materials: [Material]) {
        super.setMaterials(materials)
        if mesh != nil {
            _pipelineStates.reserveCapacity(materials.count)
            materials.forEach { material in
                _pipelineStates.append(makePipelineState(mesh!, material.shader._getShaderProgram(engine, ShaderMacroCollection())))
            }
        }
    }

    override func _render(_ camera: Camera) {
        let mesh = _mesh
        if (mesh != nil) {
            if (_meshUpdateFlag!.flag) {
                let vertexDescriptor = mesh?._vertexDescriptor

                shaderData.disableMacro(MeshRenderer._uvMacro)
                shaderData.disableMacro(MeshRenderer._normalMacro)
                shaderData.disableMacro(MeshRenderer._tangentMacro)
                shaderData.disableMacro(MeshRenderer._vertexColorMacro)

                let descriptor = vertexDescriptor!._descriptor
                if descriptor.attributeNamed(MDLVertexAttributeTextureCoordinate) != nil {
                    shaderData.enableMacro(MeshRenderer._uvMacro)
                }
                if descriptor.attributeNamed(MDLVertexAttributeNormal) != nil {
                    shaderData.enableMacro(MeshRenderer._normalMacro)
                }
                if descriptor.attributeNamed(MDLVertexAttributeTangent) != nil {
                    shaderData.enableMacro(MeshRenderer._tangentMacro)
                }
                if descriptor.attributeNamed(MDLVertexAttributeColor) != nil {
                    shaderData.enableMacro(MeshRenderer._vertexColorMacro)
                }
                _meshUpdateFlag!.flag = false
            }

            let subMeshes = mesh!.subMeshes
            let renderPipeline = camera._renderPipeline
            let renderElementPool = _engine._renderElementPool
            for i in 0..<subMeshes.count {
                let material: Material?
                if i < _materials.count {
                    material = _materials[i]
                } else {
                    material = nil
                }
                if (material != nil) {
                    let element = renderElementPool.getFromPool()
                    element.setValue(self, mesh!, subMeshes[i], material!, _pipelineStates[i])
                    renderPipeline!.pushPrimitive(element)
                }
            }
        }
    }

    internal override func _onDestroy() {
        super._onDestroy()
        let mesh = _mesh
        if (mesh != nil && !mesh!.destroyed) {
            mesh!._addRefCount(-1)
            _mesh = nil
        }
    }

    internal func _cloneTo(_ target: MeshRenderer) {
        target.mesh = _mesh
    }

    override func _updateBounds(_ worldBounds: BoundingBox) {
        let mesh = _mesh
        if (mesh != nil) {
            let localBounds = mesh!.bounds
            let worldMatrix = _entity.transform.worldMatrix
            BoundingBox.transform(source: localBounds, matrix: worldMatrix, out: worldBounds)
        } else {
            _ = worldBounds.min.setValue(x: 0, y: 0, z: 0)
            _ = worldBounds.max.setValue(x: 0, y: 0, z: 0)
        }
    }

    private func makePipelineState(_ mesh: Mesh,
                                   _ shaderProgram: ShaderProgram) -> MTLRenderPipelineState {
        let pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = shaderProgram.pipelineDescriptor

        let vertexDescriptor = mesh._vertexDescriptor._descriptor
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = engine._hardwareRenderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineState = try engine._hardwareRenderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
}
