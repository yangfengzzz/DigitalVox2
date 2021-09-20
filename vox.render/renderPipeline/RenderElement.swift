//
//  RenderElement.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Render element.
final class RenderElement {
    /// Render component.
    var component: Renderer!
    /// Mesh.
    var mesh: Mesh!
    /// Sub mesh.
    var subMesh: SubMesh!
    /// Material.
    var material: Material!
    /// Pipeline
    var pipelineState: RenderPipelineState!

    func setValue(_ component: Renderer, _ mesh: Mesh, _ subMesh: SubMesh,
                  _ material: Material, _ pipelineState: RenderPipelineState) {
        self.component = component
        self.mesh = mesh
        self.subMesh = subMesh
        self.material = material
        self.pipelineState = pipelineState
    }
}

extension RenderElement: EmptyInit {
}
