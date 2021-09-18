//
//  RenderElement.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

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

    func setValue(_ component: Renderer, _ mesh: Mesh, _ subMesh: SubMesh, _ material: Material) {
        self.component = component;
        self.mesh = mesh;
        self.subMesh = subMesh;
        self.material = material;
    }
}

extension RenderElement: EmptyInit {
}
