//
//  Engine.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI
import Logging

typealias EngineInitCallback = (Engine) -> Void
let logger = Logger(label: "com.vox.Render.main")

final class Engine: NSObject {
    var _componentsManager: ComponentsManager = ComponentsManager()
    var _hardwareRenderer: MetalGPURenderer

    var _canvas: Canvas
    private var _sceneManager: SceneManager = SceneManager()
    private var _vSyncCount: Int = 1
    private var _targetFrameRate: Float = 60
    private var _isPaused: Bool = true
    private var _requestId: Int = 0
    private var _timeoutId: Int = 0
    private var _vSyncCounter: Int = 1
    private var _targetFrameInterval: Float = 1000 / 60

    /// The canvas to use for rendering.
    var canvas: Canvas {
        get {
            _canvas
        }
    }

    /// Get the scene manager.
    var sceneManager: SceneManager {
        get {
            _sceneManager
        }
    }

    /// Whether the engine is paused.
    var isPaused: Bool {
        get {
            _isPaused
        }
    }

    /// The number of vertical synchronization means the number of vertical blanking for one frame.
    /// - Remark: 0 means that the vertical synchronization is turned off.
    var vSyncCount: Int {
        get {
            _vSyncCount
        }
        set {
            _vSyncCount = max(0, newValue)
        }
    }

    /// Set the target frame rate you want to achieve.
    /// - Remark: It only takes effect when vSyncCount = 0 (ie, vertical synchronization is turned off).
    /// The larger the value, the higher the target frame rate, Number.POSITIVE_INFINITY represents the infinite target frame rate.
    var targetFrameRate: Float {
        get {
            _targetFrameRate
        }
        set {
            let value = max(0.000001, newValue)
            _targetFrameRate = value
            _targetFrameInterval = 1000 / value
        }
    }

    init(_ canvas: Canvas, _ hardwareRenderer: MetalGPURenderer, callback: EngineInitCallback) {
        _hardwareRenderer = hardwareRenderer
        _hardwareRenderer.reinit(canvas)
        _canvas = canvas
        super.init()
        _sceneManager.activeScene = Scene(self, "DefaultScene");


        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Engine.device = device
        Engine.commandQueue = commandQueue
        Engine.library = device.makeDefaultLibrary()
        Engine.colorPixelFormat = _canvas.colorPixelFormat
        depthStencilState = Engine.buildDepthStencilState()!

        _canvas.device = device
        _canvas.depthStencilPixelFormat = .depth32Float
        _canvas.translatesAutoresizingMaskIntoConstraints = false
        _canvas.framebufferOnly = false
        _canvas.isMultipleTouchEnabled = true
        _canvas.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
        _canvas.delegate = self
        _canvas.registerGesture()
        _canvas.inputController = InputController()
        _canvas.inputController?.player = camera
        
        mtkView(_canvas, drawableSizeWillChange: _canvas.bounds.size)
        callback(self)
        fragmentUniforms.lightCount = lighting.count
    }
    
    /// Create an entity.
    /// - Parameter name: The name of the entity
    /// - Returns: Entity
    func createEntity(name: String?)-> Entity {
        return Entity(self, name);
    }
    
    /// Update the engine loop manually. If you call engine.run(), you generally don't need to call this function.
    func update() {
        let deltaTime = 1.0 / Float(canvas.preferredFramesPerSecond)
        
        let scene = _sceneManager._activeScene;
        let componentsManager = _componentsManager;
        if (scene != nil) {
            componentsManager.callScriptOnStart();
            componentsManager.callScriptOnUpdate(deltaTime);
            componentsManager.callScriptOnLateUpdate(deltaTime);

            _render(scene!);
        }

        _componentsManager.callComponentDestroy();
    }
    
    func _render(_ scene: Scene) {
        var cameras = scene._activeCameras;
        let componentsManager = _componentsManager;
        let deltaTime = 1.0 / Float(canvas.preferredFramesPerSecond)
        componentsManager.callRendererOnUpdate(deltaTime);

        if (cameras.count > 0) {
            // Sort on priority
            cameras.sort { camera1, camera2 in
                (camera1.priority - camera2.priority) != 0
            }
            for i in 0..<cameras.count {
                let camera = cameras[i];
                let cameraEntity = camera.entity;
                if (camera.enabled && cameraEntity.isActiveInHierarchy) {
                    componentsManager.callCameraOnBeginRender(camera);
                    camera.render();
                    componentsManager.callCameraOnEndRender(camera);
                }
            }
        } else {
            logger.debug("NO active camera.");
        }
    }
    
    //MARK:- Depreciation
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!

    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    var depthStencilState: MTLDepthStencilState!
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
        _ = PrimitiveMesh.createCuboid(self, 1, 1, 1, false)

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

