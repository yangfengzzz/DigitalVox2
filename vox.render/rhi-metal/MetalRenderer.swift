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

    var canvas: Canvas!
    var device: MTLDevice!
    var resouceCache: ResourceCache!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!

    var commandBuffer: MTLCommandBuffer!
    var renderEncoder: MTLRenderCommandEncoder!
    var renderPassDescriptor: MTLRenderPassDescriptor!

    var view: MTKView!

    // todo delete
    var colorPixelFormat: MTLPixelFormat!
    var samplerState: MTLSamplerState!

    func reinit(_ canvas: Canvas) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        self.canvas = canvas
        self.device = device
        self.resouceCache = ResourceCache(self)
        self.commandQueue = commandQueue
        library = device.makeDefaultLibrary()

        colorPixelFormat = canvas.colorPixelFormat
        samplerState = buildSamplerState()

        canvas.device = device
        canvas.depthStencilPixelFormat = .depth32Float
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.framebufferOnly = false
        canvas.isMultipleTouchEnabled = true
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
    func begin() {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        self.commandBuffer = commandBuffer
    }

    func end() {
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func activeRenderTarget(_ renderTarget: RenderTarget?) {
        if renderTarget != nil {
            renderPassDescriptor = renderTarget!._platformRenderTarget
        } else {
            renderPassDescriptor = view.currentRenderPassDescriptor
        }
    }

    func clearRenderTarget(_ engine: Engine,
                           _ clearFlags: CameraClearFlags
                           = CameraClearFlags(rawValue: CameraClearFlags.Depth.rawValue | CameraClearFlags.DepthColor.rawValue)!,
                           _ clearColor: Color?) {
        //TODO fix
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.stencilAttachment.loadAction = .clear
        if (clearFlags == CameraClearFlags.DepthColor) {
            let color = renderPassDescriptor.colorAttachments[0]
            if (clearColor != nil) {
                color!.clearColor = MTLClearColor(red: Double(clearColor!.r), green: Double(clearColor!.g),
                        blue: Double(clearColor!.b), alpha: Double(clearColor!.a))
            }
            color!.storeAction = .store
        }

        renderPassDescriptor.depthAttachment.storeAction = .store

        renderPassDescriptor.stencilAttachment.storeAction = .store
    }

    func beginRenderPass(_ renderTarget: RenderTarget?, _ camera: Camera, _ mipLevel: Int = 0) {
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        self.renderEncoder = renderEncoder


        if renderTarget != nil {
            renderEncoder.setViewport(MTLViewport(originX: 0,
                    originY: 0,
                    width: Double(renderTarget!.width >> mipLevel),
                    height: Double(renderTarget!.height >> mipLevel),
                    znear: 0, zfar: 1))
        } else {
            let viewport = camera.viewport
            let width = Double(view.drawableSize.width)
            let height = Double(view.drawableSize.height)

            renderEncoder.setViewport(MTLViewport(originX: Double(viewport.x) * width,
                    originY: Double(viewport.y) * height,
                    width: Double(viewport.z) * width,
                    height: Double(viewport.w) * height,
                    znear: 0, zfar: 1))
        }

        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
    }

    func endRenderPass() {
        renderEncoder.endEncoding()
    }
}

extension MetalRenderer {
    func setRenderPipelineState(_ state: RenderPipelineState) {
        renderEncoder.setRenderPipelineState(state.handle)
    }

    func setDepthStencilState(_ depthStencilState: MTLDepthStencilState) {
        renderEncoder.setDepthStencilState(depthStencilState)
    }

    func setDepthBias(_ depthBias: Float, _ slopeScale: Float, _ clamp: Float) {
        renderEncoder.setDepthBias(depthBias, slopeScale: slopeScale, clamp: clamp)
    }

    func setStencilReferenceValue(_ referenceValue: UInt32) {
        renderEncoder.setStencilReferenceValue(referenceValue)
    }

    func setBlendColor(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) {
        renderEncoder.setBlendColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func setCullMode(_ cullMode: MTLCullMode) {
        renderEncoder.setCullMode(cullMode)
    }

    func bindTexture(_ texture: MTLTexture, _ location: Int) {
        renderEncoder.setFragmentTexture(texture, index: location)
    }
    
    func drawPrimitive(_ subPrimitive: SubMesh) {
        renderEncoder.drawIndexedPrimitives(type: subPrimitive.topology, indexCount: subPrimitive.indexCount,
                                            indexType: subPrimitive.indexType,
                                            indexBuffer: subPrimitive.indexBuffer!.buffer,
                                            indexBufferOffset: subPrimitive.indexBuffer!.offset)
    }
}
