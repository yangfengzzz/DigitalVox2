//
//  RenderQueue.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal
import MetalKit

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
        let rhi = engine._hardwareRenderer
        let sceneData = scene.shaderData
        let cameraData = camera.shaderData

        //MARK:- Start Render
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

            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh._vertexDescriptor._descriptor)
            descriptor.vertexFunction = program.vertexShader
            descriptor.fragmentFunction = program.fragmentShader
            
            descriptor.colorAttachments[0].pixelFormat = engine._hardwareRenderer.colorPixelFormat
            descriptor.depthAttachmentPixelFormat = .depth32Float
            
            let depthStencilDescriptor = MTLDepthStencilDescriptor()
            material!.renderState._apply(engine, descriptor, depthStencilDescriptor)
            
            let pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor)
            rhi.setRenderPipelineState(pipelineState)
            
            let depthStencilState = engine._hardwareRenderer.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
            rhi.setDepthStencilState(depthStencilState!)
            
            //MARK:- Load Resouces
            let reflection = pipelineState.reflection
            let shaderReflection = ShaderReflection(engine, reflection)
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
