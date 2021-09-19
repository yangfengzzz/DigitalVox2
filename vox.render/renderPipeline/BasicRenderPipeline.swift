//
//  BasicRenderPipeline.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import Foundation

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
    /// - Parameter context: Render context
    func render(_ context: RenderContext) {
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
            _drawRenderPass(_renderPassArray[i], camera)
        }
    }

    private func _drawRenderPass(_ pass: RenderPass, _ camera: Camera) {
        pass.preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue)

        if (pass.enabled) {
            if (pass.renderOverride) {
                pass.render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue)
            } else {
                _opaqueQueue.render(camera, pass.replaceMaterial, pass.mask)
                _alphaTestQueue.render(camera, pass.replaceMaterial, pass.mask)
                _transparentQueue.render(camera, pass.replaceMaterial, pass.mask)
            }
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
                       _ renderTarget: RenderTarget? = nil,
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
