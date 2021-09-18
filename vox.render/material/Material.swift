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
    var renderQueueType: RenderQueueType = .Opaque
    /// Shader data.
    var shaderData: ShaderData = ShaderData(ShaderDataGroup.Material)
    /// Render state.
    var renderState: RenderState = RenderState()

    /// Create a material instance.
    /// - Parameters:
    ///   - engine: Engine to which the material belongs
    ///   - shader: Shader used by the material
    init(_ engine: Engine, _ shader: Shader) {
        self.shader = shader
        super.init(engine)
    }

    override func _addRefCount(_ value: Int) {
        super._addRefCount(value)
        shaderData._addRefCount(value)
    }


    internal func _preRender(_ renderElement: RenderElement) {
    }


    func _onDestroy() {
    }
}

extension Material: IClone {
    typealias Object = Material

    func clone() -> Material {
        let dest = Material(_engine, shader)
        cloneTo(target: dest)
        return dest
    }

    func cloneTo(target: Material) {
        target.shader = shader
        target.renderQueueType = renderQueueType
        fatalError()
    }
}
