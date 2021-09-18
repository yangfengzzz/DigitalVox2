//
//  RenderQueue.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

typealias Item = RenderElement

/// Render queue.
class RenderQueue {
    var items: [Item] = []

    init(_ engine: Engine) {
    }

    internal static func _compareFromNearToFar(a: Item, b: Item) -> Bool {
        (a.material.renderQueueType.rawValue < b.material.renderQueueType.rawValue) ||
                (a.component._distanceForSort < b.component._distanceForSort) ||
                (b.component._renderSortId < a.component._renderSortId)
    }

    internal static func _compareFromFarToNear(a: Item, b: Item) -> Bool {
        (a.material.renderQueueType.rawValue < b.material.renderQueueType.rawValue) ||
                (b.component._distanceForSort < a.component._distanceForSort) ||
                (b.component._renderSortId < a.component._renderSortId)
    }
}

extension RenderQueue {
    /// Push a render element.
    func pushPrimitive(_ element: RenderElement) {
        items.append(element)
    }

    func render(_ camera: Camera, _ replaceMaterial: Material?, _ mask: Layer) {
        if (items.count == 0) {
            return
        }

        let engine = camera.engine
        let scene = camera.scene
        let renderCount = engine._renderCount
        let rhi = engine._hardwareRenderer
        let sceneData = scene.shaderData
        let cameraData = camera.shaderData

        for i in 0..<items.count {
            let item = items[i]
            let renderPassFlag = item.component.entity.layer

            if renderPassFlag.rawValue & mask.rawValue == 0 {
                continue
            }

            // RenderElement
            let element = item
            let renderer = element.component
            let material = (replaceMaterial != nil) ? replaceMaterial : element.material
            let rendererData = renderer!.shaderData
            let materialData = material!.shaderData

            // @todo: temporary solution
            material!._preRender(element)

            let program = material!.shader._getShaderProgram(engine)
            if (!program.isValid) {
                continue
            }

            // rhi.drawPrimitive(element.mesh, element.subMesh, program)
        }
    }

    /// Clear collection.
    func clear() {
        items = []
    }

    /// Destroy internal resources.
    func destroy() {
    }

    /// Sort the elements.
    func sort(_ compareFunc: (RenderElement, RenderElement) -> Bool) {
        items.sort(by: compareFunc)
    }
}
