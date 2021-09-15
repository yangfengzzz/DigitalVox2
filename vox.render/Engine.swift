//
//  Engine.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI
import Logging

let logger = Logger(label: "com.vox.Render.main")

final class Engine: NSObject {
    var _componentsManager: ComponentsManager = ComponentsManager()
    var _hardwareRenderer: MetalGPURenderer
    var _inputManager:InputManager

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

    init(_ canvas: Canvas, _ hardwareRenderer: MetalGPURenderer) {
        _hardwareRenderer = hardwareRenderer
        _hardwareRenderer.reinit(canvas)
        _canvas = canvas
        _inputManager = InputManager()
        super.init()

        _canvas.inputManager = _inputManager
        _canvas.delegate = self
        _canvas.registerGesture()
        _sceneManager.activeScene = Scene(self, "DefaultScene")
        mtkView(_canvas, drawableSizeWillChange: _canvas.bounds.size)
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

        let scene = _sceneManager._activeScene
        let componentsManager = _componentsManager
        if (scene != nil) {
            componentsManager.callScriptOnStart()
            componentsManager.callScriptOnUpdate(deltaTime)
            componentsManager.callScriptOnLateUpdate(deltaTime)

            _render(scene!)
        }

        _componentsManager.callComponentDestroy()
    }

    func _render(_ scene: Scene) {
        var cameras = scene._activeCameras
        let componentsManager = _componentsManager
        let deltaTime = 1.0 / Float(canvas.preferredFramesPerSecond)
        componentsManager.callRendererOnUpdate(deltaTime)

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
                    camera.render()
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
        _sceneManager._activeScene?._activeCameras.first?.aspectRatio = Float(view.bounds.width) / Float(view.bounds.height)
    }

    func draw(in view: MTKView) {
        _hardwareRenderer.setView(in: view)
        
        update()
    }
}

