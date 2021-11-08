//
//  BasicRenderPipeline.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import MetalKit

/// Basic render pipeline.
class BasicRenderPipeline {
    internal var _opaqueQueue: RenderQueue
    internal var _transparentQueue: RenderQueue
    internal var _alphaTestQueue: RenderQueue

    private var _camera: Camera
    private var _defaultPass: RenderPass
    private var _renderPassArray: Array<RenderPass>
    private var _lastCanvasSize = Vector2()

    /// Create a basic render pipeline.
    /// - Parameter camera: Camera
    init(_ camera: Camera) {
        _camera = camera
        _opaqueQueue = RenderQueue(camera.engine)
        _alphaTestQueue = RenderQueue(camera.engine)
        _transparentQueue = RenderQueue(camera.engine)

        _renderPassArray = []
        _defaultPass = RenderPass("default", 0, nil, nil)
        addRenderPass(_defaultPass)
    }

    /// Destroy internal resources.
    func destroy() {
        _opaqueQueue.destroy()
        _alphaTestQueue.destroy()
        _transparentQueue.destroy()
        _renderPassArray = []
    }
}

extension BasicRenderPipeline {
    /// Perform scene rendering.
    /// - Parameters:
    ///   - context: Render context
    ///   - cubeFace: Render surface of cube texture
    func render(_ context: RenderContext, _ cubeFace: TextureCubeFace? = nil, _ mipLevel: Int = 0) {
        let camera = _camera
        let opaqueQueue = _opaqueQueue
        let alphaTestQueue = _alphaTestQueue
        let transparentQueue = _transparentQueue

        opaqueQueue.clear()
        alphaTestQueue.clear()
        transparentQueue.clear()

        camera.engine._componentsManager.callRender(context)
        opaqueQueue.sort(RenderQueue._compareFromNearToFar)
        alphaTestQueue.sort(RenderQueue._compareFromNearToFar)
        transparentQueue.sort(RenderQueue._compareFromFarToNear)

        for i in 0..<_renderPassArray.count {
            _drawRenderPass(_renderPassArray[i], camera, cubeFace)
        }
    }

    private func _drawRenderPass(_ pass: RenderPass, _ camera: Camera,
                                 _ cubeFace: TextureCubeFace? = nil, mipLevel: Int = 0) {
        pass.preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue)

        if (pass.enabled) {
            let engine = camera.engine
            let scene = camera.scene
            let background = scene.background
            let rhi = engine._hardwareRenderer

            // prepare to load render target
            let renderTarget = camera.renderTarget ?? pass.renderTarget
            rhi.activeRenderTarget(renderTarget)
            // set clear flag
            let clearFlags = pass.clearFlags ?? camera.clearFlags
            let color = pass.clearColor ?? background!.solidColor
            if (clearFlags != CameraClearFlags.None) {
                rhi.clearRenderTarget(camera.engine, clearFlags, color)
            }

            // command encoder
            rhi.beginRenderPass(renderTarget, camera, mipLevel)
            if (pass.renderOverride) {
                pass.render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue)
            } else {
                _opaqueQueue.render(camera, pass.replaceMaterial, pass.mask)
                _alphaTestQueue.render(camera, pass.replaceMaterial, pass.mask)
                if (background!.mode == .Sky) {
                    _drawSky(engine, camera, background!.sky)
                }
                _transparentQueue.render(camera, pass.replaceMaterial, pass.mask)
            }
            let canvas = engine.canvas
            canvas.gui.prepare(in: canvas)
            canvas.guiEvents.forEach { handler in
                handler()
            }
            canvas.gui.draw(in: canvas, rhi.commandBuffer, rhi.renderEncoder)

            rhi.endRenderPass()
        }

        pass.postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue)
    }

    /// Push a render element to the render queue.
    /// - Parameter element: Render element
    func pushPrimitive(_ element: RenderElement) {
        let renderQueueType = element.material.renderQueueType

        if (renderQueueType.rawValue > (RenderQueueType.Transparent.rawValue + RenderQueueType.AlphaTest.rawValue) >> 1) {
            _transparentQueue.pushPrimitive(element)
        } else if (renderQueueType.rawValue > (RenderQueueType.AlphaTest.rawValue + RenderQueueType.Opaque.rawValue) >> 1) {
            _alphaTestQueue.pushPrimitive(element)
        } else {
            _opaqueQueue.pushPrimitive(element)
        }
    }

    private func _drawSky(_ engine: Engine, _ camera: Camera, _ sky: Sky) {
        let material = sky.material
        let mesh = sky.mesh
        let _matrix = sky._matrix
        let rhi = engine._hardwareRenderer
        let scene = camera.scene
        let shaderData = scene.shaderData

        let compileMacros = ShaderMacroCollection()
        ShaderMacroCollection.unionCollection(
                camera._globalShaderMacro,
                shaderData._macroCollection,
                compileMacros
        )

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix
        viewMatrix.cloneTo(target: _matrix)
        _matrix.elements.columns.3 = [0, 0, 0, 1]
        Matrix.multiply(left: projectionMatrix, right: _matrix, out: _matrix)
        shaderData.setBytes("u_mvpNoscale", _matrix)

        let program = material.shader._getShaderProgram(engine, compileMacros)
        if (!program.isValid) {
            return
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh._vertexDescriptor)
        descriptor.vertexFunction = program.vertexShader
        descriptor.fragmentFunction = program.fragmentShader

        descriptor.colorAttachments[0].pixelFormat = engine._hardwareRenderer.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = .depth32Float

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        material.renderState._apply(engine, descriptor, depthStencilDescriptor)

        let pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor)
        rhi.setRenderPipelineState(pipelineState)

        let depthStencilState = engine._hardwareRenderer.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        rhi.setDepthStencilState(depthStencilState!)

        pipelineState.groupingOtherUniformBlock()
        pipelineState.uploadAll(pipelineState.sceneUniformBlock, shaderData)

        for (index, vertexBuffer) in mesh._vertexBuffer.enumerated() {
            rhi.renderEncoder.setVertexBuffer(vertexBuffer?.buffer,
                    offset: 0, index: index)
        }

        rhi.drawPrimitive(mesh.subMesh!)
    }
}


//MARK:- RenderPass Methods
extension BasicRenderPipeline {
    /// Default render pass.
    var defaultRenderPass: RenderPass {
        get {
            _defaultPass
        }
    }

    /// Add render pass.
    /// - Parameters:
    ///   - pass: RenderPass object.
    func addRenderPass(_ pass: RenderPass) {
        _renderPassArray.append(pass)
        _renderPassArray.sort { p1, p2 in
            p1.priority < p2.priority
        }
    }

    /// Add render pass.
    /// - Parameters:
    ///   - name: The name of this Pass.
    ///   - priority: Priority, less than 0 before the default pass, greater than 0 after the default pass
    ///   - renderTarget: The specified Render Target
    ///   - replaceMaterial: Replaced material
    ///   - mask: Perform bit and operations with Entity.Layer to filter the objects that this Pass needs to render
    func addRenderPass(_ name: String,
                       _ priority: Int = 0,
                       _ renderTarget: MTLRenderPassDescriptor? = nil,
                       _ replaceMaterial: Material? = nil,
                       _ mask: Layer = Layer.Everything) {
        let renderPass = RenderPass(name, priority, renderTarget, replaceMaterial, mask)
        _renderPassArray.append(renderPass)

        _renderPassArray.sort { p1, p2 in
            p1.priority < p2.priority
        }
    }

    /// Remove render pass by name or render pass object.
    /// - Parameter name: Render pass name
    func removeRenderPass(_ name: String) {
        let pass = getRenderPass(name)
        if (pass != nil) {
            _renderPassArray.removeAll { p in
                p === pass!
            }
        }
    }

    /// Remove render pass by name or render pass object.
    /// - Parameter pass: render pass object
    func removeRenderPass(_ pass: RenderPass) {
        _renderPassArray.removeAll { p in
            p === pass
        }
    }

    /// Get render pass by name.
    /// - Parameter name: Render pass name
    func getRenderPass(_ name: String) -> RenderPass? {
        _renderPassArray.first { pass in
            pass.name == name
        }
    }
}
