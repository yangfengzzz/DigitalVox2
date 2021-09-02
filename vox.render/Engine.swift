//
//  Engine.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

typealias EngineInitCallback = (Engine) -> Void

final class Engine: UIView {
    let controllerView = ControllerView(frame: .zero, device: MTLCreateSystemDefaultDevice())

    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!

    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    let depthStencilState: MTLDepthStencilState
    let lighting = Lighting()

    var renderEncoder: MTLRenderCommandEncoder!
    
    lazy var camera: Camera = {
        let camera = ArcballCamera()
        camera.distance = 3
        camera.target = [0, 0, 0]
        camera.rotation.x = Float(-10).degreesToRadians
        return camera
    }()

    // Array of Models allows for rendering multiple models
    var models: [Model] = []

    init(callback: EngineInitCallback) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Engine.device = device
        Engine.commandQueue = commandQueue
        Engine.library = device.makeDefaultLibrary()
        Engine.colorPixelFormat = controllerView.colorPixelFormat

        controllerView.device = device
        controllerView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Engine.buildDepthStencilState()!

        super.init(frame: .zero)
        self.addSubview(controllerView)
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        controllerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        controllerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        controllerView.framebufferOnly = false
        controllerView.isMultipleTouchEnabled = true
        controllerView.clearColor = MTLClearColor(red: 0.7, green: 0.9,
                blue: 1, alpha: 1)
        controllerView.delegate = self
        controllerView.registerGesture();
        mtkView(controllerView, drawableSizeWillChange: controllerView.bounds.size)

        callback(self)

        fragmentUniforms.lightCount = lighting.count

        controllerView.inputController = InputController()
        controllerView.inputController?.player = camera
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

    func createPrimitive() {
        _ = PrimitiveMesh.createCuboid(engine: self, width: 1, height: 1, depth: 1, noLongerAccessible: false);
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
        fragmentUniforms.cameraPosition = camera.position

        var lights = lighting.lights
        renderEncoder.setFragmentBytes(&lights,
                length: MemoryLayout<Light>.stride * lights.count,
                index: Int(BufferIndexLights.rawValue))


        // render all the models in the array
        for model in models {

            // add tiling here
            fragmentUniforms.tiling = model.tiling
            renderEncoder.setFragmentBytes(&fragmentUniforms,
                    length: MemoryLayout<FragmentUniforms>.stride,
                    index: Int(BufferIndexFragmentUniforms.rawValue))

            renderEncoder.setFragmentSamplerState(model.samplerState, index: 0)

            uniforms.modelMatrix = model.modelMatrix
            uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

            renderEncoder.setVertexBytes(&uniforms,
                    length: MemoryLayout<Uniforms>.stride,
                    index: Int(BufferIndexUniforms.rawValue))

            for mesh in model.meshes {

                // render multiple buffers
                // replace the following two lines
                // this only sends the MTLBuffer containing position, normal and UV
                for (index, vertexBuffer) in mesh.mtkMesh.vertexBuffers.enumerated() {
                    renderEncoder.setVertexBuffer(vertexBuffer.buffer,
                            offset: 0, index: index)
                }

                for submesh in mesh.submeshes {
                    renderEncoder.setRenderPipelineState(submesh.pipelineState)
                    // textures
                    renderEncoder.setFragmentTexture(submesh.textures.baseColor,
                            index: Int(BaseColorTexture.rawValue))
                    renderEncoder.setFragmentTexture(submesh.textures.normal,
                            index: Int(NormalTexture.rawValue))
                    renderEncoder.setFragmentTexture(submesh.textures.roughness,
                            index: 2)

                    // set the materials here
                    var material = submesh.material
                    renderEncoder.setFragmentBytes(&material,
                            length: MemoryLayout<Material>.stride,
                            index: Int(BufferIndexMaterials.rawValue))

                    let mtkSubmesh = submesh.mtkSubmesh
                    renderEncoder.drawIndexedPrimitives(type: .triangle,
                            indexCount: mtkSubmesh.indexCount,
                            indexType: mtkSubmesh.indexType,
                            indexBuffer: mtkSubmesh.indexBuffer.buffer,
                            indexBufferOffset: mtkSubmesh.indexBuffer.offset)
                }
            }
        }

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

