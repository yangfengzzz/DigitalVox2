//
//  Material.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Material.
class Material: RefObject {
    /// Name.
    var name: String = ""
    /// Shader used by the material.
    var shader: Shader

    /// Create a material instance.
    /// - Parameters:
    ///   - engine: Engine to which the material belongs
    ///   - shader: Shader used by the material
    init(engine: Engine, shader: Shader) {
        self.shader = shader
        super.init(engine)
    }
}

extension Material: IClone {
    typealias Object = Material

    func clone() -> Material {
        fatalError()
    }

    func cloneTo(target: Material) {
        fatalError()
    }
}
