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

        engine._hardwareRenderer.preDraw()

        var uniforms = Uniforms()
        uniforms.projectionMatrix = camera.projectionMatrix.elements
        uniforms.viewMatrix = camera.viewMatrix.elements
        var fragmentUniforms = FragmentUniforms()
        fragmentUniforms.tiling = 1
        fragmentUniforms.cameraPosition = camera.entity.transform.worldPosition.elements
        
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

            // let program = material!.shader._getShaderProgram(engine)
            // if (!program.isValid) {
            //    continue
            // }

            engine._hardwareRenderer.renderEncoder.setRenderPipelineState(element.pipelineState)

            engine._hardwareRenderer.renderEncoder.setFragmentBytes(&fragmentUniforms,
                                           length: MemoryLayout<FragmentUniforms>.stride,
                                           index: Int(BufferIndexFragmentUniforms.rawValue))
            
            uniforms.modelMatrix = element.component.entity.transform.worldMatrix.elements
            engine._hardwareRenderer.renderEncoder.setVertexBytes(&uniforms,
                    length: MemoryLayout<Uniforms>.stride,
                    index: Int(BufferIndexUniforms.rawValue))

            for (index, vertexBuffer) in element.mesh._vertexBuffer.enumerated() {
                engine._hardwareRenderer.renderEncoder.setVertexBuffer(vertexBuffer?.buffer,
                        offset: 0, index: index)
            }


            engine._hardwareRenderer.drawPrimitive(element.mesh!, element.subMesh, ShaderProgram(engine, "", "", []))
        }
        engine._hardwareRenderer.postDraw()
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
