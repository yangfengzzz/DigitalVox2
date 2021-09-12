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

    var shaderProgram: AnyClass!

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

    func _render(camera: Camera) {
        let box = PrimitiveMesh.createCuboid(engine, 1)
        engine._hardwareRenderer.drawPrimitive(box, box.subMesh!, shaderProgram)
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

    func _updateBounds(worldBounds: BoundingBox) {
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
