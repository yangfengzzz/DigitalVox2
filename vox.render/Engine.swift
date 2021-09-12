//
//  Engine.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

typealias EngineInitCallback = (Engine) -> Void

final class Engine: NSObject {
    var _componentsManager: ComponentsManager = ComponentsManager();
    var _hardwareRenderer: MetalGPURenderer;

    var _canvas: Canvas;
    
    /// The canvas to use for rendering.
    var canvas:Canvas {
        get {
            _canvas
        }
    }
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!

    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    let depthStencilState: MTLDepthStencilState
    let lighting = Lighting()

    var renderEncoder: MTLRenderCommandEncoder!

    lazy var camera: OldCamera = {
        let camera = ArcballCamera()
        camera.distance = 3
        camera.target = [0, 0, 0]
        camera.rotation.x = Float(-10).degreesToRadians
        return camera
    }()

    // Array of Models allows for rendering multiple models
    var models: [Model] = []

    init(_ canvas: Canvas, _ hardwareRenderer: MetalGPURenderer, callback: EngineInitCallback) {
        _canvas = canvas;
        _hardwareRenderer = hardwareRenderer;

        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Engine.device = device
        Engine.commandQueue = commandQueue
        Engine.library = device.makeDefaultLibrary()
        Engine.colorPixelFormat = _canvas.colorPixelFormat

        _canvas.device = device
        _canvas.depthStencilPixelFormat = .depth32Float
        depthStencilState = Engine.buildDepthStencilState()!

        super.init()
        _canvas.translatesAutoresizingMaskIntoConstraints = false
        _canvas.framebufferOnly = false
        _canvas.isMultipleTouchEnabled = true
        _canvas.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
        _canvas.delegate = self
        _canvas.registerGesture();
        mtkView(_canvas, drawableSizeWillChange: _canvas.bounds.size)

        callback(self)

        fragmentUniforms.lightCount = lighting.count

        _canvas.inputController = InputController()
        _canvas.inputController?.player = camera
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func buildDepthStencilState() -> MTLDepthStencilState? {
        // 1
        let descriptor = MTLDepthStencilDescriptor()
        // 2
        descriptor.depthCompareFunction = .less
        // 3
        descriptor.isDepthWriteEnabled = true
        return
                Engine.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Engine: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width) / Float(view.bounds.height)
    }

    static func makePipelineState() -> MTLRenderPipelineState {
        let library = Engine.library
        let vertexFunction = library?.makeFunction(name: "vertex_simple")
        let fragmentFunction = library?.makeFunction(name: "fragment_simple")

        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = Engine.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineState = try Engine.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }

    func draw(in view: MTKView) {
        guard
                let descriptor = view.currentRenderPassDescriptor,
                let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
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

        renderEncoder.setRenderPipelineState(Engine.makePipelineState())
        _ = PrimitiveMesh.createCuboid(self, 1, 1, 1, false);

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

