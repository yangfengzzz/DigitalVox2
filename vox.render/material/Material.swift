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
    /// Render queue type.
    var renderQueueType: RenderQueueType = .Opaque;

    /// Create a material instance.
    /// - Parameters:
    ///   - engine: Engine to which the material belongs
    ///   - shader: Shader used by the material
    init(_ engine: Engine, _ shader: Shader) {
        self.shader = shader
        super.init(engine)
    }
}

extension Material: IClone {
    typealias Object = Material

    func clone() -> Material {
        let dest = Material(_engine, shader);
        cloneTo(target: dest);
        return dest;
    }

    func cloneTo(target: Material) {
        target.shader = shader;
        target.renderQueueType = renderQueueType;
        fatalError()
    }
}
