//
//  MetalRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal
import MetalKit

/// Metal renderer.
class MetalRenderer {
    let maxAnisotropy = 8
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!
    var colorPixelFormat: MTLPixelFormat!

    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!

    var renderEncoder: MTLRenderCommandEncoder!
    var commandBuffer: MTLCommandBuffer!

    var view: MTKView!

    func reinit(_ canvas: Canvas) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        self.device = device
        self.commandQueue = commandQueue
        library = device.makeDefaultLibrary()

        colorPixelFormat = canvas.colorPixelFormat
        depthStencilState = buildDepthStencilState()
        samplerState = buildSamplerState()

        canvas.device = device
        canvas.depthStencilPixelFormat = .depth32Float
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.framebufferOnly = false
        canvas.isMultipleTouchEnabled = true
        canvas.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
    }

    func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func buildSamplerState() -> MTLSamplerState? {
      let descriptor = MTLSamplerDescriptor()
      descriptor.sAddressMode = .repeat
      descriptor.tAddressMode = .repeat
      descriptor.mipFilter = .linear
      descriptor.maxAnisotropy = maxAnisotropy
      let samplerState = device.makeSamplerState(descriptor: descriptor)
      return samplerState
    }

    func setView(in view: MTKView) {
        self.view = view
    }
}

extension MetalRenderer {
    func createPlatformPrimitive(_ primitive: Mesh) -> IPlatformPrimitive {
        GPUPrimitive(self)
    }
    
    func createPlatformTexture2D(_ texture2D: Texture2D)-> IPlatformTexture2D {
        fatalError()
    }
    
    func createPlatformTextureCubeMap(_ textureCube: TextureCubeMap)-> IPlatformTextureCubeMap {
        fatalError()
    }
}

extension MetalRenderer: IHardwareRenderer {
    func drawPrimitive(_ primitive: Mesh, _ subPrimitive: SubMesh, _ shaderProgram: ShaderProgram) {
        primitive._draw(shaderProgram, subPrimitive)
    }

    func preDraw() {
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)

        self.renderEncoder = renderEncoder
        self.commandBuffer = commandBuffer
    }

    func postDraw() {
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
