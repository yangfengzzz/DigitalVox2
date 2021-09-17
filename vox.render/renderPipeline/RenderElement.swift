//
//  RenderElement.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

/// Render element.
class RenderElement {
    /// Render component.
    var component: Renderer!
    /// Mesh.
    var mesh: Mesh!
    /// Sub mesh.
    var subMesh: SubMesh!
    /// Material.
    var material: Material!

    func setValue(component: Renderer, mesh: Mesh, subMesh: SubMesh, material: Material) {
        self.component = component;
        self.mesh = mesh;
        self.subMesh = subMesh;
        self.material = material;
    }
}
