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
    private var _onStartScripts: DisorderedArray<Script> = DisorderedArray()
    private var _onUpdateScripts: DisorderedArray<Script> = DisorderedArray()
    private var _onLateUpdateScripts: DisorderedArray<Script> = DisorderedArray()
    private var _destroyComponents: [Script] = []

    // Animation
    private var _onUpdateAnimations: DisorderedArray<Animator> = DisorderedArray()

    // Render
    private var _renderers: DisorderedArray<Renderer> = DisorderedArray()
    private var _onUpdateRenderers: DisorderedArray<Renderer> = DisorderedArray()

    // Delay dispose active/inActive Pool
    private var _componentsContainerPool: [[Component]] = [[]]

    // Physics
    private var _colliders: DisorderedArray<Collider> = DisorderedArray()
    private var _characterControllers: DisorderedArray<CharacterController> = DisorderedArray()
}

extension ComponentsManager {
    func addRenderer(_ renderer: Renderer) {
        renderer._rendererIndex = _renderers.length
        _renderers.add(renderer)
    }

    func removeRenderer(_ renderer: Renderer) {
        let replaced = _renderers.deleteByIndex(renderer._rendererIndex)
        if replaced != nil {
            replaced!._rendererIndex = renderer._rendererIndex
        }
        renderer._rendererIndex = -1
    }

    func addCollider(_ collider: Collider) {
        collider._index = _colliders.length
        _colliders.add(collider)
    }

    func removeCollider(_ collider: Collider) {
        let replaced = _colliders.deleteByIndex(collider._index)
        if replaced != nil {
            replaced!._index = collider._index
        }
        collider._index = -1
    }

    func addCharacterController(_ controller: CharacterController) {
        controller._index = _characterControllers.length
        _characterControllers.add(controller)
    }

    func removeCharacterController(_ controller: CharacterController) {
        let replaced = _characterControllers.deleteByIndex(controller._index)
        if replaced != nil {
            replaced!._index = controller._index
        }
        controller._index = -1
    }

    func addOnStartScript(_ script: Script) {
        script._onStartIndex = _onStartScripts.length
        _onStartScripts.add(script)
    }

    func removeOnStartScript(_ script: Script) {
        let replaced = _onStartScripts.deleteByIndex(script._onStartIndex)
        if replaced != nil {
            replaced!._onStartIndex = script._onStartIndex
        }
        script._onStartIndex = -1
    }

    func addOnUpdateScript(_ script: Script) {
        script._onUpdateIndex = _onUpdateScripts.length
        _onUpdateScripts.add(script)
    }

    func removeOnUpdateScript(_ script: Script) {
        let replaced = _onUpdateScripts.deleteByIndex(script._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = script._onUpdateIndex
        }
        script._onUpdateIndex = -1
    }

    func addOnLateUpdateScript(_ script: Script) {
        script._onLateUpdateIndex = _onLateUpdateScripts.length
        _onLateUpdateScripts.add(script)
    }

    func removeOnLateUpdateScript(_ script: Script) {
        let replaced = _onLateUpdateScripts.deleteByIndex(script._onLateUpdateIndex)
        if replaced != nil {
            replaced!._onLateUpdateIndex = script._onLateUpdateIndex
        }
        script._onLateUpdateIndex = -1
    }

    func addOnUpdateAnimations(_ animation: Animator) {
        animation._onUpdateIndex = _onUpdateAnimations.length
        _onUpdateAnimations.add(animation)
    }

    func removeOnUpdateAnimations(_ animation: Animator) {
        let replaced = _onUpdateAnimations.deleteByIndex(animation._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = animation._onUpdateIndex
        }
        animation._onUpdateIndex = -1
    }

    func addOnUpdateRenderers(_ renderer: Renderer) {
        renderer._onUpdateIndex = _onUpdateRenderers.length
        _onUpdateRenderers.add(renderer)
    }

    func removeOnUpdateRenderers(_ renderer: Renderer) {
        let replaced = _onUpdateRenderers.deleteByIndex(renderer._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = renderer._onUpdateIndex
        }
        renderer._onUpdateIndex = -1
    }

    func addDestroyComponent(_ component: Script) {
        _destroyComponents.append(component)
    }

    //MARK: - Execute Components
    func callScriptOnStart() {
        let onStartScripts = _onStartScripts
        if (onStartScripts.length > 0) {
            let elements = onStartScripts._elements
            // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
            for i in 0..<onStartScripts.length {
                let script = elements[i]!
                script._started = true
                script._onStartIndex = -1
                script.onStart()
            }
            onStartScripts.length = 0
        }
    }

    func callScriptOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateScripts._elements
        for i in 0..<_onUpdateScripts.length {
            let element = elements[i]!
            if (element._started) {
                element.onUpdate(deltaTime)
            }
        }
    }

    func callScriptOnLateUpdate(_ deltaTime: Float) {
        let elements = _onLateUpdateScripts._elements
        for i in 0..<_onLateUpdateScripts.length {
            let element = elements[i]!
            if (element._started) {
                element.onLateUpdate(deltaTime)
            }
        }
    }

    func callAnimationUpdate(_ deltaTime: Float) {
        let elements = _onUpdateAnimations._elements
        for i in 0..<_onUpdateAnimations.length {
            elements[i]!.update(deltaTime)
        }
    }

    func callRendererOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateRenderers._elements
        for i in 0..<_onUpdateRenderers.length {
            elements[i]!.update(deltaTime)
        }
    }

    func callRender(_ context: RenderContext) {
        let camera = context._camera
        let elements = _renderers._elements
        for i in 0..<_renderers.length {
            let element = elements[i]!

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

    func callColliderOnUpdate() {
        let elements = _colliders._elements
        for i in 0..<_colliders.length {
            elements[i]!._onUpdate()
        }
    }

    func callColliderOnLateUpdate() {
        let elements = _colliders._elements
        for i in 0..<_colliders.length {
            elements[i]!._onLateUpdate()
        }
    }

    func callCharacterControllerOnLateUpdate() {
        let elements = _characterControllers._elements
        for i in 0..<_characterControllers.length {
            elements[i]!._onLateUpdate()
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
