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
    private var _renderers: [Renderer] = []
    private var _onUpdateRenderers: [Renderer] = []

    // Delay dispose active/inActive Pool
    private var _componentsContainerPool: [[Component]] = [[]]
}

extension ComponentsManager {
    func addRenderer(_ renderer: Renderer) {
        renderer._rendererIndex = _renderers.count
        _renderers.append(renderer)
    }

    func removeRenderer(_ renderer: Renderer) {
        let replaced = _renderers.remove(at: renderer._rendererIndex)
        replaced._rendererIndex = renderer._rendererIndex
        renderer._rendererIndex = -1
    }

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

    func addOnUpdateRenderers(_ renderer: Renderer) {
        renderer._onUpdateIndex = _onUpdateRenderers.count
        _onUpdateRenderers.append(renderer)
    }

    func removeOnUpdateRenderers(_ renderer: Renderer) {
        let replaced = _onUpdateRenderers.remove(at: renderer._onUpdateIndex)
        replaced._onUpdateIndex = renderer._onUpdateIndex
        renderer._onUpdateIndex = -1
    }

    func addDestroyComponent(_ component: Script) {
        _destroyComponents.append(component)
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

    func callRendererOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateRenderers
        for i in 0..<_onUpdateRenderers.count {
            elements[i].update(deltaTime)
        }
    }

    func callRender(_ context: RenderContext) {
        let camera = context._camera
        let elements = _renderers
        for i in 0..<_renderers.count {
            let element = elements[i]

            // filter by camera culling mask.
            if (camera!.cullingMask.rawValue & element._entity.layer.rawValue) == 0 {
                continue
            }

            // filter by camera frustum.
            if (camera!.enableFrustumCulling) {
                element.isCulled = !camera!._frustum.intersectsBox(box: element.bounds)
                if (element.isCulled) {
                    continue
                }
            }

            let transform = camera!.entity.transform
            let position = transform!.worldPosition
            let center = element.bounds.getCenter(out: ComponentsManager._tempVector0)
            if (camera!.isOrthographic) {
                let forward = transform!.getWorldForward(forward: ComponentsManager._tempVector1)
                Vector3.subtract(left: center, right: position, out: center)
                element._distanceForSort = Vector3.dot(left: center, right: forward)
            } else {
                element._distanceForSort = Vector3.distanceSquared(left: center, right: position)
            }

            element._updateShaderData(context)

            element._render(camera!)

            // union camera global macro and renderer macro.
            ShaderMacroCollection.unionCollection(
                    camera!._globalShaderMacro,
                    element.shaderData._macroCollection,
                    element._globalShaderMacro
            )
        }
    }

    func callComponentDestroy() {
        var destroyComponents = _destroyComponents
        let length = destroyComponents.count
        if (length > 0) {
            for i in 0..<length {
                destroyComponents[i].onDestroy()
            }
            destroyComponents = []
        }
    }

    func callCameraOnBeginRender(_ camera: Camera) {
        let camComps = camera.entity._components
        for i in 0..<camComps.count {
            let camComp = camComps[i]
            (camComp as? Script)?.onBeginRender(camera)
        }
    }

    func callCameraOnEndRender(_ camera: Camera) {
        let camComps = camera.entity._components
        for i in 0..<camComps.count {
            let camComp = camComps[i]
            (camComp as? Script)?.onEndRender(camera)
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
