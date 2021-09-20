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
        engine._hardwareRenderer.preDraw()
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
            engine._hardwareRenderer.setRenderPipelineState(element.pipelineState)

            //MARK:- Load Resouces
            let reflection = element.pipelineState.reflection
            reflection?.vertexArguments?.forEach({ aug in
                print(aug.name, aug.bufferDataType.rawValue, aug.index)
            })
            reflection?.fragmentArguments?.forEach({ aug in
                print(aug.name, aug.bufferDataType.rawValue, aug.index)
            })
            print("====")
            
            let projectionMatrix = cameraData.getMatrix("u_projMat")
            engine._hardwareRenderer.renderEncoder.setVertexBytes(&projectionMatrix!.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: 12)
            
            let viewMatrix = cameraData.getMatrix("u_viewMat")
            engine._hardwareRenderer.renderEncoder.setVertexBytes(&viewMatrix!.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: 13)
            
            let modelMatrix = rendererData.getMatrix("u_modelMat")
            engine._hardwareRenderer.renderEncoder.setVertexBytes(&modelMatrix!.elements,
                    length: MemoryLayout<matrix_float4x4>.stride,
                    index: 14)

            for (index, vertexBuffer) in element.mesh._vertexBuffer.enumerated() {
                engine._hardwareRenderer.renderEncoder.setVertexBuffer(vertexBuffer?.buffer,
                        offset: 0, index: index)
            }

            engine._hardwareRenderer.drawPrimitive(element.mesh!, element.subMesh, program)
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
