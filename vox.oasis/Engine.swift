//
//  Engine.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI
import Logging

/// TODO: delete
let engineFeatureManager = EngineFeatureManager()
let logger = Logger(label: "com.vox.Render.main")

final class Engine: NSObject {
    /// Physics manager of Engine.
    var physicsManager: PhysicsManager?

    var _componentsManager: ComponentsManager = ComponentsManager()
    var _hardwareRenderer: MetalRenderer
    var _inputManager: InputManager

    var _renderElementPool: ClassPool<RenderElement> = ClassPool()
    var _renderContext: RenderContext = RenderContext()

    internal var _whiteTexture2D: MTLTexture!
    internal var _whiteTextureCube: MTLTexture!
    internal var _backgroundTextureMaterial: Material!
    internal var _backgroundTextureMesh: ModelMesh!

    var _canvas: Canvas
    private var _sceneManager: SceneManager = SceneManager()
    private var _vSyncCount: Int = 1
    private var _targetFrameRate: Float = 60
    private var _isPaused: Bool = true
    private var _requestId: Int = 0
    private var _timeoutId: Int = 0
    private var _vSyncCounter: Int = 1
    private var _targetFrameInterval: Float = 1000 / 60

    var features: [EngineFeature] = []

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

    init(_ canvas: Canvas, _ hardwareRenderer: MetalRenderer, physics: IPhysics.Type? = nil) {
        _hardwareRenderer = hardwareRenderer
        _hardwareRenderer.reinit(canvas)
        _canvas = canvas
        _inputManager = InputManager()

        if (physics != nil) {
            PhysicsManager._nativePhysics = physics!
            physicsManager = PhysicsManager()
        }

        super.init()
        ShaderPool.initialization()

        _canvas.inputManager = _inputManager
        _canvas.delegate = self
        _canvas.registerGesture()
        // TODO delete
        engineFeatureManager.addObject(self)
        _sceneManager.activeScene = Scene(self, "DefaultScene")
        mtkView(_canvas, drawableSizeWillChange: _canvas.bounds.size)

        let whitePixel: [UInt8] = [255, 255, 255, 255]
        let bytes = 4 * MemoryLayout<UInt8>.stride
        let whiteTextureDescriptor = MTLTextureDescriptor()
        whiteTextureDescriptor.width = 1
        whiteTextureDescriptor.height = 1
        whiteTextureDescriptor.pixelFormat = .rgba8Uint
        whiteTextureDescriptor.textureType = .type2D
        _whiteTexture2D = hardwareRenderer.device.makeTexture(descriptor: whiteTextureDescriptor)
        _whiteTexture2D!.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, withBytes: whitePixel, bytesPerRow: bytes)

        let whiteTextureCubeDescriptor = MTLTextureDescriptor()
        whiteTextureCubeDescriptor.width = 1
        whiteTextureCubeDescriptor.height = 1
        whiteTextureCubeDescriptor.pixelFormat = .rgba8Uint
        whiteTextureCubeDescriptor.textureType = .typeCube
        let _whiteTextureCube = hardwareRenderer.device.makeTexture(descriptor: whiteTextureCubeDescriptor)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 0, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 1, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 2, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 3, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 4, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)
        _whiteTextureCube?.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, slice: 5, withBytes: whitePixel,
                bytesPerRow: bytes, bytesPerImage: bytes)

        _backgroundTextureMaterial = Material(self, Shader.find("background-texture")!)
        _backgroundTextureMaterial.isGCIgnored = true
        _backgroundTextureMaterial.renderState.depthState.compareFunction = .lessEqual

        _backgroundTextureMesh = PrimitiveMesh.createPlane(self, 2, 2, 1, 1, false)
        _backgroundTextureMesh.isGCIgnored = true

        canvas.gui.create(with: canvas, _hardwareRenderer.device)
    }

    /// Create an entity.
    /// - Parameter name: The name of the entity
    /// - Returns: Entity
    func createEntity(name: String?) -> Entity {
        return Entity(self, name)
    }

    /// Update the engine loop manually. If you call engine.run(), you generally don't need to call this function.
    func update() {
        let deltaTime = 1.0 / Float(canvas.preferredFramesPerSecond)
        _renderElementPool.resetPool()

        features.forEach { feature in
            feature.preTick(self, _sceneManager._activeScene!)
        }

        let scene = _sceneManager._activeScene
        let componentsManager = _componentsManager
        if (scene != nil) {
            componentsManager.callScriptOnStart()
            if (physicsManager != nil) {
                componentsManager.callColliderOnUpdate()
                physicsManager!._update(deltaTime)
                componentsManager.callCharacterControllerOnLateUpdate()
                componentsManager.callColliderOnLateUpdate()
            }

            componentsManager.callScriptOnUpdate(deltaTime)
            componentsManager.callAnimationUpdate(deltaTime)
            componentsManager.callScriptOnLateUpdate(deltaTime)

            _hardwareRenderer.begin()
            _render(scene!)
            _hardwareRenderer.end()
        }

        _componentsManager.callComponentDestroy()

        features.forEach { feature in
            feature.postTick(self, _sceneManager._activeScene!)
        }
    }

    func _render(_ scene: Scene) {
        var cameras = scene._activeCameras
        let componentsManager = _componentsManager
        let deltaTime = 1.0 / Float(canvas.preferredFramesPerSecond)
        componentsManager.callRendererOnUpdate(deltaTime)

        scene._updateShaderData()

        if (cameras.count > 0) {
            // Sort on priority
            cameras.sort { camera1, camera2 in
                (camera1.priority - camera2.priority) != 0
            }
            for i in 0..<cameras.count {
                let camera = cameras[i]
                let cameraEntity = camera.entity
                if (camera.enabled && cameraEntity.isActiveInHierarchy) {
                    componentsManager.callCameraOnBeginRender(camera)
                    scene.features.forEach { feature in
                        feature.preRender(scene, camera)
                    }
                    camera.render()
                    scene.features.forEach { feature in
                        feature.postRender(scene, camera)
                    }
                    componentsManager.callCameraOnEndRender(camera)
                }
            }
        } else {
            logger.debug("NO active camera.")
        }
    }
}

extension Engine: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        _sceneManager._activeScene?._activeCameras.first?.aspectRatio = Float(size.width) / Float(size.height)
    }

    func draw(in view: MTKView) {
        _hardwareRenderer.setView(in: view)

        update()
    }
}

extension Engine {
    func findFeature<T: EngineFeature>() -> T? {
        engineFeatureManager.findFeature(self)
    }

    static func registerFeature(_ Feature: EngineFeature) {
        engineFeatureManager.registerFeature(Feature)
    }
}
