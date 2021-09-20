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

        //MARK:- Start Render
        rhi.preDraw()
        for i in 0..<items.count {
            let item = items[i]
            let renderPassFlag = item.component.entity.layer

            if renderPassFlag.rawValue & mask.rawValue == 0 {
                continue
            }

            // RenderElement
            let compileMacros = Shader._compileMacros
            let element = item
            let renderer = element.component
            let material = (replaceMaterial != nil) ? replaceMaterial : element.material
            let rendererData = renderer!.shaderData
            let materialData = material!.shaderData

            // @todo: temporary solution
            material!._preRender(element)

            // union render global macro and material self macro.
            ShaderMacroCollection.unionCollection(
                    renderer!._globalShaderMacro,
                    materialData._macroCollection,
                    compileMacros
            )

            //MARK:- Set Pipeline State
            let program = material!.shader._getShaderProgram(engine, compileMacros)
            if (!program.isValid) {
                continue
            }
            
            if program.vertexShader !== element.pipelineState.vertexShader {
                element.pipelineState.vertexShader = program.vertexShader
            }
            if program.fragmentShader !== element.pipelineState.fragmentShader {
                element.pipelineState.fragmentShader = program.fragmentShader
            }
            rhi.setRenderPipelineState(element.pipelineState)

            //MARK:- Load Resouces
            let reflection = element.pipelineState.reflection            
            let shaderReflection = ShaderReflection(engine, reflection!)
            shaderReflection.groupingOtherUniformBlock()
            shaderReflection.uploadAll(shaderReflection.sceneUniformBlock, sceneData);
            shaderReflection.uploadAll(shaderReflection.cameraUniformBlock, cameraData);
            shaderReflection.uploadAll(shaderReflection.rendererUniformBlock, rendererData);
            shaderReflection.uploadAll(shaderReflection.materialUniformBlock, materialData);

            for (index, vertexBuffer) in element.mesh._vertexBuffer.enumerated() {
                rhi.renderEncoder.setVertexBuffer(vertexBuffer?.buffer,
                        offset: 0, index: index)
            }

            rhi.drawPrimitive(element.mesh!, element.subMesh, program)
        }
        rhi.postDraw()
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
