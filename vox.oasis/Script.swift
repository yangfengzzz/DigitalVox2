//
//  Script.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

/// Script class, used for logic writing.
class Script: Component {
    // @ignoreClone
    internal var _started: Bool = false
    // @ignoreClone
    internal var _onStartIndex: Int = -1
    //  @ignoreClone
    internal var _onUpdateIndex: Int = -1
    // @ignoreClone
    internal var _onLateUpdateIndex: Int = -1
    // @ignoreClone
    internal var _onPreRenderIndex: Int = -1
    // @ignoreClone
    internal var _onPostRenderIndex: Int = -1
    // @ignoreClone
    var _entityCacheIndex: Int = -1

    /// Called when be enabled first time, only once.
    func onAwake() {
    }

    /// Called when be enabled.
    func onEnable() {
    }

    /// Called before the frame-level loop start for the first time, only once.
    func onStart() {
    }

    /// The main loop, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    func onUpdate(_ deltaTime: Float) {
    }

    /// Called after the onUpdate finished, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    func onLateUpdate(_ deltaTime: Float) {
    }

    /// Called before camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    func onBeginRender(_ camera: Camera) {
    }

    /// Called after camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    func onEndRender(_ camera: Camera) {
    }

    /// Called when the collision enter.
    /// - Parameter other: other ColliderShape
    func onTriggerEnter(_ other: ColliderShape) {
    }

    /// Called when the collision stay.
    /// - Parameter other: other ColliderShape
    /// - Remark: onTriggerStay is called every frame while the collision stay.
    func onTriggerStay(_ other: ColliderShape) {
    }

    /// Called when the collision exit.
    /// - Parameter other: other ColliderShape
    func onTriggerExit(_ other: ColliderShape) {
    }

    /// Called when be disabled.
    func onDisable() {
    }

    /// Called at the end of the destroyed frame.
    func onDestroy() {
    }

    internal override func _onAwake() {
        onAwake()
    }

    internal override func _onEnable() {
        let componentsManager = engine._componentsManager
        if (!_started) {
            componentsManager.addOnStartScript(self)
        }
        componentsManager.addOnUpdateScript(self)
        componentsManager.addOnLateUpdateScript(self)
        _entity._addScript(self)
        onEnable()
    }

    override func _onDisable() {
        let componentsManager = engine._componentsManager
        // Use "xxIndex" is more safe.
        // When call onDisable it maybe it still not in script queue,for example write "entity.isActive = false" in onWake().
        if (_onStartIndex != -1) {
            componentsManager.removeOnStartScript(self)
        }
        if (_onUpdateIndex != -1) {
            componentsManager.removeOnUpdateScript(self)
        }
        if (_onLateUpdateIndex != -1) {
            componentsManager.removeOnLateUpdateScript(self)
        }
        if (_entityCacheIndex != -1) {
            _entity._removeScript(self)
        }
        onDisable()
    }

    override func _onDestroy() {
        engine._componentsManager.addDestroyComponent(self)
    }
}
