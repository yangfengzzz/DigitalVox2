//
//  MeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import Foundation

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
            let subMeshes = mesh!.subMeshes
            let renderPipeline = camera._renderPipeline
            let renderElementPool = _engine._renderElementPool
            for i in 0..<subMeshes.count {
                let material = _materials[i]
                if (material != nil) {
                    let element = renderElementPool.getFromPool()
                    element.setValue(self, mesh!, subMeshes[i], material!)
                    renderPipeline!.pushPrimitive(element)
                }
            }
        }

        engine._hardwareRenderer.preDraw()

        var uniforms = Uniforms()
        uniforms.projectionMatrix = camera.projectionMatrix.elements
        uniforms.viewMatrix = camera.viewMatrix.elements
        uniforms.modelMatrix = entity.transform.worldMatrix.elements
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        engine._hardwareRenderer.renderEncoder.setVertexBytes(&uniforms,
                length: MemoryLayout<Uniforms>.stride,
                index: Int(BufferIndexUniforms.rawValue))

        engine._hardwareRenderer.drawPrimitive(mesh!, mesh!.subMesh!, ShaderProgram(engine, "", ""))

        engine._hardwareRenderer.postDraw()
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
