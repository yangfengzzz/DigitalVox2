//
//  ComponentsManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

/// The manager of the components.
class ComponentsManager {
    private static var _tempVector0 = Vector3()
    private static var _tempVector1 = Vector3()

    // Script
    private var _onStartScripts: [Script] = []
    private var _onUpdateScripts: [Script] = []
    private var _onLateUpdateScripts: [Script] = []
    private var _destroyComponents: [Script] = []

    // Animation
    private var _onUpdateAnimations: [Component] = []

    // Render
    // private var _renderers: [Renderer] = []
    // private var _onUpdateRenderers: [Renderer] = []

    // Delay dispose active/inActive Pool
    private var _componentsContainerPool: [[Component]] = [[]]
}

extension ComponentsManager {
    func addOnStartScript(_ script: Script) {
        script._onStartIndex = _onStartScripts.count
        _onStartScripts.append(script)
    }

    func removeOnStartScript(_ script: Script) {
        let replaced = _onStartScripts.remove(at: script._onStartIndex)
        replaced._onStartIndex = script._onStartIndex
        script._onStartIndex = -1
    }

    func addOnUpdateScript(_ script: Script) {
        script._onUpdateIndex = _onUpdateScripts.count
        _onUpdateScripts.append(script)
    }

    func removeOnUpdateScript(_ script: Script) {
        let replaced = _onUpdateScripts.remove(at: script._onUpdateIndex)
        replaced._onUpdateIndex = script._onUpdateIndex
        script._onUpdateIndex = -1
    }

    func addOnLateUpdateScript(_ script: Script) {
        script._onLateUpdateIndex = _onLateUpdateScripts.count
        _onLateUpdateScripts.append(script)
    }

    func removeOnLateUpdateScript(_ script: Script) {
        let replaced = _onLateUpdateScripts.remove(at: script._onLateUpdateIndex)
        replaced._onLateUpdateIndex = script._onLateUpdateIndex
        script._onLateUpdateIndex = -1
    }

    func callScriptOnStart() {
        var onStartScripts = _onStartScripts
        if (onStartScripts.count > 0) {
            let elements = onStartScripts
            // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
            for i in 0..<onStartScripts.count {
                let script = elements[i]
                script._started = true
                script._onStartIndex = -1
                script.onStart()
            }
            onStartScripts = []
        }
    }

    func callScriptOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateScripts
        for i in 0..<_onUpdateScripts.count {
            let element = elements[i]
            if (element._started) {
                element.onUpdate(deltaTime)
            }
        }
    }

    func callScriptOnLateUpdate(_ deltaTime: Float) {
        let elements = _onLateUpdateScripts
        for i in 0..<_onLateUpdateScripts.count {
            let element = elements[i]
            if (element._started) {
                element.onLateUpdate(deltaTime)
            }
        }
    }
}

extension ComponentsManager {
    func getActiveChangedTempList() -> [Component] {
        (_componentsContainerPool.count != 0) ? _componentsContainerPool.first! : []
    }

    func putActiveChangedTempList(_ componentContainer: inout [Component]) {
        componentContainer = []
        _componentsContainerPool.append(componentContainer)
    }
}
