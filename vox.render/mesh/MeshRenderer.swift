//
//  MeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import MetalKit

class MeshRenderer: Renderer {
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

    override func _render(_ camera: Camera) {
        let mesh = _mesh
        if (mesh != nil) {
            if (_meshUpdateFlag!.flag) {
                let vertexDescriptor = mesh?._vertexDescriptor

                shaderData.disableMacro(HAS_UV)
                shaderData.disableMacro(HAS_NORMAL)
                shaderData.disableMacro(HAS_TANGENT)
                shaderData.disableMacro(HAS_VERTEXCOLOR)

                let descriptor = vertexDescriptor!._descriptor
                if descriptor.attributeNamed(MDLVertexAttributeTextureCoordinate) != nil {
                    shaderData.enableMacro(HAS_UV)
                }
                if descriptor.attributeNamed(MDLVertexAttributeNormal) != nil {
                    shaderData.enableMacro(HAS_NORMAL)
                }
                if descriptor.attributeNamed(MDLVertexAttributeTangent) != nil {
                    shaderData.enableMacro(HAS_TANGENT)
                }
                if descriptor.attributeNamed(MDLVertexAttributeColor) != nil {
                    shaderData.enableMacro(HAS_VERTEXCOLOR)
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
                    element.setValue(self, mesh!, subMeshes[i], material!)
                    renderPipeline!.pushPrimitive(element)
                }
            }
        } else {
            fatalError("mesh is nil.")
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
}
