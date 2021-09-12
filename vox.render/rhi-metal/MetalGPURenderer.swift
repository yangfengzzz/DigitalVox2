//
//  MetalRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal
import MetalKit

/// Metal renderer.
class MetalGPURenderer {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!
    var colorPixelFormat: MTLPixelFormat!

    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    var depthStencilState: MTLDepthStencilState!
    let lighting = Lighting()

    var renderEncoder: MTLRenderCommandEncoder!

    func reinit(_ canvas: Canvas) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        self.device = device
        self.commandQueue = commandQueue
        library = device.makeDefaultLibrary()
        colorPixelFormat = canvas.colorPixelFormat
        depthStencilState = buildDepthStencilState()!

        canvas.device = device
        canvas.depthStencilPixelFormat = .depth32Float
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.framebufferOnly = false
        canvas.isMultipleTouchEnabled = true
        canvas.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
        canvas.registerGesture()

        fragmentUniforms.lightCount = lighting.count
    }

    func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: descriptor)
    }

    func makePipelineState() -> MTLRenderPipelineState {
        let vertexFunction = library?.makeFunction(name: "vertex_simple")
        let fragmentFunction = library?.makeFunction(name: "fragment_simple")

        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
}

extension MetalGPURenderer: IHardwareRenderer {
    func createPlatformPrimitive(_ primitive: Mesh) -> IPlatformPrimitive {
        GPUPrimitive(self, primitive)
    }

    func drawPrimitive(_ primitive: Mesh, _ subPrimitive: SubMesh, _ shaderProgram: AnyClass) {
        primitive._draw(renderEncoder, shaderProgram, subPrimitive)
    }

    func draw(in view: MTKView, camera: OldCamera) {
        guard
                let descriptor = view.currentRenderPassDescriptor,
                let commandBuffer = commandQueue.makeCommandBuffer(),
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        self.renderEncoder = renderEncoder

        renderEncoder.setDepthStencilState(depthStencilState)

        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        let position: float3 = [0, 0, 0]
        let rotation: float3 = [0, 0, 0]
        let scale: float3 = [1, 1, 1]
        var modelMatrix: float4x4 {
            let translateMatrix = float4x4(translation: position)
            let rotateMatrix = float4x4(rotation: rotation)
            let scaleMatrix = float4x4(scaling: scale)
            return translateMatrix * rotateMatrix * scaleMatrix
        }
        uniforms.modelMatrix = modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        renderEncoder.setVertexBytes(&uniforms,
                length: MemoryLayout<Uniforms>.stride,
                index: Int(BufferIndexUniforms.rawValue))

        renderEncoder.setRenderPipelineState(makePipelineState())
        // _ = PrimitiveMesh.createCuboid(self, 1, 1, 1, false)

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
