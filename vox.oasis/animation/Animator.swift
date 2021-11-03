//
//  Animator.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// The controller of the animation system.
class Animator: Component {
    private static var _tempVector3: Vector3 = Vector3()
    private static var _tempQuaternion: Quaternion = Quaternion()
    private static var _animatorInfo: AnimatorStateInfo = AnimatorStateInfo()

    var _animatorController: AnimatorController!
    // @assignmentClone
    var _speed: Float = 1.0
    // @ignoreClone
    var _controllerUpdateFlag: UpdateFlag!

    internal var _onUpdateIndex: Int = -1

    // ignoreClone
    private var _animatorLayersData: [Int: AnimatorLayerData] = [:]
    // @ignoreClone
    private var _crossCurveDataCollection: [CrossCurveData] = []
    // @ignoreClone
    private var _animationCurveOwners: [Int: [AnimationProperty: AnimationCurveOwner]] = [:]
    // @ignoreClone
    private var _crossCurveDataPool: ClassPool<CrossCurveData> = ClassPool()
    // @ignoreClone
    private var _animationEventHandlerPool: ClassPool<AnimationEventHandler> = ClassPool()

    /// The playback speed of the Animator, 1.0 is normal playback speed.
    var speed: Float {
        get {
            _speed
        }
        set {
            _speed = newValue
        }
    }

    /// All layers from the AnimatorController which belongs this Animator.
    var animatorController: AnimatorController {
        get {
            _animatorController
        }
        set {
            if (newValue !== _animatorController) {
                if _controllerUpdateFlag != nil {
                    _controllerUpdateFlag!.destroy()
                }
                _controllerUpdateFlag = newValue._registerChangeFlag()
                _animatorController = newValue
            }
        }
    }

    /// Play a state by name.
    /// - Parameters:
    ///   - stateName: The state name
    ///   - layerIndex: The layer index(default -1). If layer is -1, play the first state with the given state name
    ///   - normalizedTimeOffset: The time offset between 0 and 1(default 0)
    func play(_ stateName: String, _ layerIndex: Int = -1, _ normalizedTimeOffset: Float = 0) {
        if (self._controllerUpdateFlag?.flag != nil) {
            self._clearPlayData()
        }

        let animatorInfo = self._getAnimatorStateInfo(stateName, layerIndex, Animator._animatorInfo)
        let state = animatorInfo.state

        if (state == nil) {
            return
        }
        if (state!.clip == nil) {
            logger.warning("The state named \(stateName) has no AnimationClip data.")
            return
        }
        let animatorLayerData = self._getAnimatorLayerData(animatorInfo.layerIndex)
        let srcPlayData = animatorLayerData.srcPlayData
        let curState = srcPlayData.state
        if (curState != nil && curState !== state) {
            self._revertDefaultValue(srcPlayData)
        }

        //CM: Not consider same stateName, but different animation
        let animatorStateData = self._getAnimatorStateData(stateName, state!, animatorLayerData)

        animatorLayerData.layerState = LayerState.Playing
        srcPlayData.reset(state!, animatorStateData, state!._getDuration() * normalizedTimeOffset)

        self._saveDefaultValues(animatorStateData)
    }

    /// Create a cross fade from the current state to another state.
    /// - Parameters:
    ///   - stateName: The state name
    ///   - normalizedTransitionDuration: The duration of the transition (normalized)
    ///   - layerIndex: The layer index(default -1). If layer is -1, play the first state with the given state name
    ///   - normalizedTimeOffset: The time offset between 0 and 1(default 0)
    func crossFade(_ stateName: String,
                   _ normalizedTransitionDuration: Float,
                   _ layerIndex: Int = -1,
                   _ normalizedTimeOffset: Float = 0) {
        if (_controllerUpdateFlag?.flag != nil) {
            _clearPlayData()
        }

        let state = _getAnimatorStateInfo(stateName, layerIndex, Animator._animatorInfo).state
        let manuallyTransition = _getAnimatorLayerData(layerIndex).manuallyTransition
        manuallyTransition.duration = normalizedTransitionDuration
        manuallyTransition.offset = normalizedTimeOffset
        manuallyTransition.destinationState = state
        _crossFadeByTransition(manuallyTransition, layerIndex)
    }

    /// Evaluates the animator component based on deltaTime.
    /// - Parameter deltaTime: The deltaTime when the animation update
    func update(_ deltaTime: Float) {
        var deltaTime = deltaTime
        if (speed == 0) {
            return
        }

        if (_animatorController == nil) {
            return
        }
        if (_controllerUpdateFlag?.flag != nil) {
            return
        }
        deltaTime *= speed
        for i in 0..<animatorController.layers.count {
            let animatorLayerData = _getAnimatorLayerData(i)
            if (animatorLayerData.layerState == LayerState.Standby) {
                continue
            }

            _updateLayer(i, i == 0, deltaTime / 1000)
        }
    }

    internal override func _onEnable() {
        engine._componentsManager.addOnUpdateAnimations(self)
    }

    internal override func _onDisable() {
        engine._componentsManager.removeOnUpdateAnimations(self)
    }

    private func _getAnimatorStateInfo(_ stateName: String, _ layerIndex: Int, _ out: AnimatorStateInfo) -> AnimatorStateInfo {
        var layerIndex = layerIndex
        var state: AnimatorState? = nil
        if (_animatorController != nil) {
            let layers = _animatorController.layers
            if (layerIndex == -1) {
                for i in 0..<layers.count {
                    state = layers[i].stateMachine.findStateByName(stateName)
                    if (state != nil) {
                        layerIndex = i
                        break
                    }
                }
            } else {
                state = layers[layerIndex].stateMachine.findStateByName(stateName)
            }
        }
        out.layerIndex = layerIndex
        out.state = state
        return out
    }

    private func _saveDefaultValues(_ stateData: AnimatorStateData) {
        let curveOwners = stateData.curveOwners
        for i in 0..<curveOwners.count {
            curveOwners[i].saveDefaultValue()
        }
    }

    private func _getAnimatorStateData(_ stateName: String,
                                       _ animatorState: AnimatorState,
                                       _ animatorLayerData: AnimatorLayerData) -> AnimatorStateData {
        var animatorStateData = animatorLayerData.animatorStateDataMap[stateName]
        if animatorStateData == nil {
            animatorStateData = AnimatorStateData()
            animatorLayerData.animatorStateDataMap[stateName] = animatorStateData
            _saveAnimatorStateData(animatorState, animatorStateData!)
            _saveAnimatorEventHandlers(animatorState, animatorStateData!)
        }
        return animatorStateData!
    }

    private func _saveAnimatorStateData(_ animatorState: AnimatorState, _ animatorStateData: AnimatorStateData) {
        let curves = animatorState.clip!._curveBindings
        for i in 0..<curves.count {
            let curve = curves[i]
            let targetEntity = curve.relativePath == "" ? entity : entity.findByPath(curve.relativePath)
            let property = curve.property
            let instanceId = targetEntity!.instanceId

            if _animationCurveOwners[instanceId] == nil {
                _animationCurveOwners[instanceId] = [:]
            }

            if _animationCurveOwners[instanceId]![property!] == nil {
                let owner = AnimationCurveOwner(targetEntity!, curve.type, property!)
                _animationCurveOwners[instanceId]![property!] = owner
                animatorStateData.curveOwners[i] = owner
            }
        }
    }

    private func _saveAnimatorEventHandlers(_ state: AnimatorState, _ animatorStateData: AnimatorStateData) {
        // TODO: related to script
    }

    private func _clearCrossData(_ animatorLayerData: AnimatorLayerData) {
        animatorLayerData.crossCurveMark += 1
        self._crossCurveDataCollection = []
        self._crossCurveDataPool.resetPool()
    }

    private func _addCrossCurveData(
            _ crossCurveData: inout [CrossCurveData],
            _ owner: AnimationCurveOwner,
            _ curCurveIndex: Int,
            _ nextCurveIndex: Int
    ) {
        let dataItem = self._crossCurveDataPool.getFromPool()
        dataItem.curveOwner = owner
        dataItem.srcCurveIndex = curCurveIndex
        dataItem.destCurveIndex = nextCurveIndex
        crossCurveData.append(dataItem)
    }


    private func _prepareCrossFading(_ animatorLayerData: AnimatorLayerData) {
        let crossCurveMark = animatorLayerData.crossCurveMark

        // Add src cross curve data.
        self._prepareSrcCrossData(&_crossCurveDataCollection, animatorLayerData.srcPlayData, crossCurveMark, false)
        // Add dest cross curve data.
        self._prepareDestCrossData(&_crossCurveDataCollection, animatorLayerData.destPlayData, crossCurveMark, false)
    }

    private func _prepareStandbyCrossFading(_ animatorLayerData: AnimatorLayerData) {
        let srcPlayData = animatorLayerData.srcPlayData
        let crossCurveMark = animatorLayerData.crossCurveMark

        // Standby have two sub state, one is never play, one is finished, never play srcPlayData is null.
        self._prepareSrcCrossData(&_crossCurveDataCollection, srcPlayData, crossCurveMark, true)

        // Add dest cross curve data.
        self._prepareDestCrossData(&_crossCurveDataCollection, animatorLayerData.destPlayData, crossCurveMark, true)
    }

    private func _prepareFixedPoseCrossFading(_ animatorLayerData: AnimatorLayerData) {
        // Save current cross curve data owner fixed pose.
        for i in 0..<_crossCurveDataCollection.count {
            let item = _crossCurveDataCollection[i]
            item.curveOwner.saveFixedPoseValue()
            // Reset destCurveIndex When fixed pose crossFading again.
            item.destCurveIndex = -1
        }
        // prepare dest AnimatorState cross data.
        self._prepareDestCrossData(&_crossCurveDataCollection, animatorLayerData.destPlayData, animatorLayerData.crossCurveMark, true)
    }

    private func _prepareSrcCrossData(
            _ crossCurveData: inout [CrossCurveData],
            _ srcPlayData: AnimatorStatePlayData,
            _ crossCurveMark: Int,
            _ saveFixed: Bool
    ) {
        let curveOwners = srcPlayData.stateData.curveOwners
        for i in 0..<curveOwners.count {
            let owner = curveOwners[i]
            owner.crossCurveMark = crossCurveMark
            owner.crossCurveIndex = crossCurveData.count
            if saveFixed {
                owner.saveFixedPoseValue()
            }
            self._addCrossCurveData(&crossCurveData, owner, i, -1)
        }
    }

    private func _prepareDestCrossData(
            _ crossCurveData: inout [CrossCurveData],
            _ destPlayData: AnimatorStatePlayData,
            _ crossCurveMark: Int,
            _ saveFixed: Bool
    ) {
        let curveOwners = destPlayData.stateData.curveOwners
        for i in 0..<curveOwners.count {
            let owner = curveOwners[i]
            // Not include in previous AnimatorState.
            if (owner.crossCurveMark == crossCurveMark) {
                crossCurveData[owner.crossCurveIndex].destCurveIndex = i
            } else {
                if saveFixed {
                    owner.saveFixedPoseValue()
                }
                owner.crossCurveMark = crossCurveMark
                owner.crossCurveIndex = crossCurveData.count
                self._addCrossCurveData(&crossCurveData, owner, -1, i)
            }
        }
    }

    private func _evaluateCurve(
            _ property: AnimationProperty,
            _ curve: AnimationCurve,
            _ time: Float,
            _ additive: Bool
    ) -> InterpolableValue {
        let value = curve.evaluate(time)

        if (additive) {
            let baseValue = curve.keys[0].getValue()
            switch (property) {
            case AnimationProperty.Position:
                let pos = Animator._tempVector3
                Vector3.subtract(left: value.getVector3(), right: baseValue.getVector3(), out: pos)
                return .Vector3(pos)
            case AnimationProperty.Rotation:
                let rot = Animator._tempQuaternion
                Quaternion.conjugate(a: baseValue.getQuaternion(), out: rot)
                Quaternion.multiply(left: rot, right: value.getQuaternion(), out: rot)
                return .Quaternion(rot)
            case AnimationProperty.Scale:
                let scale = Animator._tempVector3
                Vector3.divide(left: value.getVector3(), right: baseValue.getVector3(), out: scale)
                return .Vector3(scale)
            default:
                fatalError()
            }
        }
        return value
    }

    private func _getAnimatorLayerData(_ layerIndex: Int) -> AnimatorLayerData {
        var animatorLayerData = self._animatorLayersData[layerIndex]
        if animatorLayerData == nil {
            animatorLayerData = AnimatorLayerData()
            self._animatorLayersData[layerIndex] = animatorLayerData
        }
        return animatorLayerData!
    }

    private func _updateLayer(_ layerIndex: Int, _ firstLayer: Bool, _ deltaTime: Float) {
        let blendingMode = self._animatorController.layers[layerIndex].blendingMode
        let weight = self._animatorController.layers[layerIndex].weight
        let animLayerData = self._animatorLayersData[layerIndex]!
        let srcPlayData = animLayerData.srcPlayData
        let destPlayData = animLayerData.destPlayData
        let crossFadeTransitionInfo = animLayerData.crossFadeTransition!
        let layerAdditive = blendingMode == AnimatorLayerBlendingMode.Additive
        let layerWeight = firstLayer ? 1.0 : weight
        self._checkTransition(srcPlayData, crossFadeTransitionInfo, layerIndex)
        switch (animLayerData.layerState) {
        case LayerState.Playing:
            self._updatePlayingState(srcPlayData, animLayerData, layerIndex, layerWeight, deltaTime, layerAdditive)
            break
        case LayerState.FixedCrossFading:
            self._updateCrossFadeFromPose(destPlayData, animLayerData, layerIndex, layerWeight, deltaTime, layerAdditive)
            break
        case LayerState.CrossFading:
            self._updateCrossFade(
                    srcPlayData,
                    destPlayData,
                    animLayerData,
                    layerIndex,
                    layerWeight,
                    deltaTime,
                    layerAdditive
            )
            break
        default:
            fatalError()
        }
    }

    private func _updatePlayingState(
            _ playData: AnimatorStatePlayData,
            _ layerData: AnimatorLayerData,
            _ layerIndex: Int,
            _ weight: Float,
            _ delta: Float,
            _ additive: Bool
    ) {
        let curveOwners = playData.stateData.curveOwners
        let eventHandlers = playData.stateData.eventHandlers
        let state = playData.state!
        let lastPlayState = playData.playState
        let lastClipTime = playData.clipTime!
        let curves = state.clip!._curveBindings

        playData.update()

        let clipTime = playData.clipTime!
        let playState = playData.playState

        if eventHandlers.count != 0 {
            self._fireAnimationEvents(playData, eventHandlers, lastClipTime, clipTime)
        }

        if (lastPlayState == AnimatorStatePlayState.UnStarted) {
            self._callAnimatorScriptOnEnter(state, layerIndex)
        }
        if (playState == AnimatorStatePlayState.Finished) {
            self._callAnimatorScriptOnExit(state, layerIndex)
        } else {
            self._callAnimatorScriptOnUpdate(state, layerIndex)
        }

        for i in 0..<curves.count {
            let owner = curveOwners[i]
            let value = self._evaluateCurve(owner.property, curves[i].curve, clipTime, additive)
            if (additive) {
                self._applyClipValueAdditive(owner, value, weight)
            } else {
                self._applyClipValue(owner, value, weight)
            }
        }
        playData.frameTime += state.speed * delta

        if (playState == AnimatorStatePlayState.Finished) {
            layerData.layerState = LayerState.Standby
        }
    }

    private func _updateCrossFade(
            _ srcPlayData: AnimatorStatePlayData,
            _ destPlayData: AnimatorStatePlayData,
            _ layerData: AnimatorLayerData,
            _ layerIndex: Int,
            _ weight: Float,
            _ delta: Float,
            _ additive: Bool
    ) {
        let srcCurves = srcPlayData.state.clip!._curveBindings
        let srcState = srcPlayData.state!
        let srcStateData = srcPlayData.stateData
        let lastSrcPlayState = srcPlayData.playState
        let srcEventHandler = srcStateData!.eventHandlers

        let destState = destPlayData.state!
        let destStateData = destPlayData.stateData
        let lastDstPlayState = destPlayData.playState
        let destEventHandler = destStateData!.eventHandlers

        let destCurves = destState.clip!._curveBindings
        let lastSrcClipTime = srcPlayData.clipTime!
        let lastDestClipTime = destPlayData.clipTime!

        var crossWeight = destPlayData.frameTime / (destState._getDuration() * layerData.crossFadeTransition.duration)
        if crossWeight >= 1.0 {
            crossWeight = 1.0
        }
        srcPlayData.update()
        destPlayData.update()

        let srcClipTime = srcPlayData.clipTime!
        let destClipTime = destPlayData.clipTime!

        if srcEventHandler.count != 0 {
            self._fireAnimationEvents(srcPlayData, srcEventHandler, lastSrcClipTime, srcClipTime)
        }
        if destEventHandler.count != 0 {
            self._fireAnimationEvents(destPlayData, destEventHandler, lastDestClipTime, destClipTime)
        }

        if (lastSrcPlayState == AnimatorStatePlayState.UnStarted) {
            self._callAnimatorScriptOnEnter(srcState, layerIndex)
        }
        if (crossWeight == 1 || srcPlayData.playState == AnimatorStatePlayState.Finished) {
            self._callAnimatorScriptOnExit(srcState, layerIndex)
        } else {
            self._callAnimatorScriptOnUpdate(srcState, layerIndex)
        }

        if (lastDstPlayState == AnimatorStatePlayState.UnStarted) {
            self._callAnimatorScriptOnEnter(destState, layerIndex)
        }
        if (destPlayData.playState == AnimatorStatePlayState.Finished) {
            self._callAnimatorScriptOnExit(destState, layerIndex)
        } else {
            self._callAnimatorScriptOnUpdate(destState, layerIndex)
        }

        for i in 0..<_crossCurveDataCollection.count {
            let curveOwner = _crossCurveDataCollection[i].curveOwner!
            let srcCurveIndex = _crossCurveDataCollection[i].srcCurveIndex!
            let destCurveIndex = _crossCurveDataCollection[i].destCurveIndex!
            let property = curveOwner.property
            let defaultValue = curveOwner.defaultValue

            let srcValue =
                    srcCurveIndex >= 0
                            ? self._evaluateCurve(property, srcCurves[srcCurveIndex].curve, srcClipTime, additive)
                            : defaultValue
            let destValue =
                    destCurveIndex >= 0
                            ? self._evaluateCurve(property, destCurves[destCurveIndex].curve, destClipTime, additive)
                            : defaultValue

            self._applyCrossClipValue(curveOwner, srcValue, destValue, crossWeight, weight, additive)
        }
        self._updateCrossFadeData(layerData, crossWeight, delta, false)
    }

    private func _updateCrossFadeFromPose(
            _ destPlayData: AnimatorStatePlayData,
            _ layerData: AnimatorLayerData,
            _ layerIndex: Int,
            _ weight: Float,
            _ delta: Float,
            _ additive: Bool
    ) {
        let crossCurveDataCollection = self._crossCurveDataCollection
        let state = destPlayData.state!
        let stateData = destPlayData.stateData!
        let lastPlayState = destPlayData.playState
        let eventHandlers = stateData.eventHandlers
        let curves = state.clip!._curveBindings
        let lastDestClipTime = destPlayData.clipTime!

        var crossWeight = destPlayData.frameTime / (state._getDuration() * layerData.crossFadeTransition.duration)
        if crossWeight >= 1.0 {
            crossWeight = 1.0
        }
        destPlayData.update()

        let destClipTime = destPlayData.clipTime!

        if eventHandlers.count != 0 {
            _fireAnimationEvents(destPlayData, eventHandlers, lastDestClipTime, destClipTime)
        }

        if (lastPlayState == AnimatorStatePlayState.UnStarted) {
            self._callAnimatorScriptOnEnter(state, layerIndex)
        }
        if (destPlayData.playState == AnimatorStatePlayState.Finished) {
            self._callAnimatorScriptOnExit(state, layerIndex)
        } else {
            self._callAnimatorScriptOnUpdate(state, layerIndex)
        }

        for i in 0..<crossCurveDataCollection.count {
            let curveOwner = _crossCurveDataCollection[i].curveOwner!
            let destCurveIndex = _crossCurveDataCollection[i].destCurveIndex!
            let destValue =
                    destCurveIndex >= 0
                            ? self._evaluateCurve(curveOwner.property, curves[destCurveIndex].curve, destClipTime, additive)
                            : curveOwner.defaultValue

            self._applyCrossClipValue(curveOwner, curveOwner.fixedPoseValue, destValue, crossWeight, weight, additive)
        }

        self._updateCrossFadeData(layerData, crossWeight, delta, true)
    }

    private func _updateCrossFadeData(_ layerData: AnimatorLayerData, _ crossWeight: Float, _ delta: Float, _ fixed: Bool) {
        let destPlayData = layerData.destPlayData
        destPlayData.frameTime += destPlayData.state.speed * delta
        if (crossWeight == 1.0) {
            if (destPlayData.playState == AnimatorStatePlayState.Finished) {
                layerData.layerState = LayerState.Standby
            } else {
                layerData.layerState = LayerState.Playing
            }
            layerData.switchPlayData()
        } else {
            if !fixed {
                layerData.srcPlayData.frameTime += layerData.srcPlayData.state.speed * delta
            }
        }
    }

    private func _applyCrossClipValue(
            _ owner: AnimationCurveOwner,
            _ srcValue: InterpolableValue,
            _ destValue: InterpolableValue,
            _ crossWeight: Float,
            _ layerWeight: Float,
            _ additive: Bool
    ) {
        var value: InterpolableValue = .Float(0)
        if (owner.type == Transform.self) {
            let transform = owner.target.transform
            switch (owner.property) {
            case AnimationProperty.Position:
                Vector3.lerp(left: srcValue.getVector3(), right: destValue.getVector3(), t: crossWeight, out: Animator._tempVector3)
                value = .Vector3(Animator._tempVector3)
                break
            case AnimationProperty.Rotation:
                Quaternion.slerp(start: srcValue.getQuaternion(), end: destValue.getQuaternion(), t: crossWeight, out: Animator._tempQuaternion)
                value = .Quaternion(Animator._tempQuaternion)
                break
            case AnimationProperty.Scale:
                let scale = transform!.scale
                Vector3.lerp(left: srcValue.getVector3(), right: destValue.getVector3(), t: crossWeight, out: Animator._tempVector3)
                transform!.scale = scale
                value = .Vector3(Animator._tempVector3)
                break
            default:
                fatalError()
            }
        }

        if (additive) {
            self._applyClipValueAdditive(owner, value, layerWeight)
        } else {
            self._applyClipValue(owner, value, layerWeight)
        }
    }

    private func _applyClipValue(_ owner: AnimationCurveOwner, _ value: InterpolableValue, _ weight: Float) {
        if (owner.type == Transform.self) {
            let transform = owner.target.transform
            switch (owner.property) {
            case AnimationProperty.Position:
                if (weight == 1.0) {
                    transform!.position = value.getVector3()
                } else {
                    let position = transform!.position
                    Vector3.lerp(left: position, right: value.getVector3(), t: weight, out: position)
                    transform!.position = position
                }
                break
            case AnimationProperty.Rotation:
                if (weight == 1.0) {
                    transform!.rotationQuaternion = value.getQuaternion()
                } else {
                    let rotationQuaternion = transform!.rotationQuaternion
                    Quaternion.slerp(start: rotationQuaternion, end: value.getQuaternion(), t: weight, out: rotationQuaternion)
                    transform!.rotationQuaternion = rotationQuaternion
                }
                break
            case AnimationProperty.Scale:
                if (weight == 1.0) {
                    transform!.scale = value.getVector3()
                } else {
                    let scale = transform!.scale
                    Vector3.lerp(left: scale, right: value.getVector3(), t: weight, out: scale)
                    transform!.scale = scale
                }
                break
            default:
                fatalError()
            }
        } else if (owner.type == SkinnedMeshRenderer.self) {
            switch (owner.property) {
            case AnimationProperty.BlendShapeWeights:
                // (owner.component as! SkinnedMeshRenderer).blendShapeWeights = value.getFloatArray()
                break
            default:
                fatalError()
            }
        }
    }

    private func _applyClipValueAdditive(_ owner: AnimationCurveOwner, _ additiveValue: InterpolableValue, _ weight: Float) {
        if (owner.type == Transform.self) {
            let transform = owner.target.transform
            switch (owner.property) {
            case AnimationProperty.Position:
                let position = transform!.position
                let additiveValue = additiveValue.getVector3()
                position.x += additiveValue.x * weight
                position.y += additiveValue.y * weight
                position.z += additiveValue.z * weight
                transform!.position = position
                break
            case AnimationProperty.Rotation:
                let rotationQuaternion = transform!.rotationQuaternion
                let additiveValue = additiveValue.getQuaternion()
                AnimatorUtils.quaternionWeight(additiveValue, weight, additiveValue)
                _ = additiveValue.normalize()
                _ = rotationQuaternion.multiply(quat: additiveValue)
                transform!.rotationQuaternion = rotationQuaternion
                break
            case AnimationProperty.Scale:
                let scale = transform!.scale
                AnimatorUtils.scaleWeight(scale, weight, scale)
                Vector3.multiply(left: scale, right: additiveValue.getVector3(), out: scale)
                transform!.scale = scale
                break
            default:
                fatalError()
            }
        }
    }

    private func _revertDefaultValue(_ playData: AnimatorStatePlayData) {
        let clip = playData.state.clip
        if (clip != nil) {
            let curves = clip!._curveBindings
            let curveOwners = playData.stateData.curveOwners
            for i in 0..<curves.count {
                let owner = curveOwners[i]
                let transform = owner.target.transform
                switch (owner.property) {
                case AnimationProperty.Position:
                    transform!.position = owner.defaultValue.getVector3()
                    break
                case AnimationProperty.Rotation:
                    transform!.rotationQuaternion = owner.defaultValue.getQuaternion()
                    break
                case AnimationProperty.Scale:
                    transform!.scale = owner.defaultValue.getVector3()
                    break
                default:
                    fatalError()
                }
            }
        }
    }

    private func _checkTransition(
            _ stateData: AnimatorStatePlayData,
            _ crossFadeTransition: AnimatorStateTransition,
            _ layerIndex: Int
    ) {
        let state = stateData.state
        let clipTime = stateData.clipTime
        let duration = state!._getDuration()
        let transitions = state!.transitions
        for i in 0..<transitions.count {
            let transition = transitions[i]
            if (duration * transition.exitTime <= clipTime!) {
                if crossFadeTransition !== transition {
                    self._crossFadeByTransition(transition, layerIndex)
                }
            }
        }
    }

    private func _crossFadeByTransition(_ transition: AnimatorStateTransition, _ layerIndex: Int) {
        let name = transition.destinationState.name
        let animatorStateInfo = self._getAnimatorStateInfo(name, layerIndex, Animator._animatorInfo)
        let crossState = animatorStateInfo.state
        if (crossState == nil) {
            return
        }
        if (crossState!.clip == nil) {
            logger.warning("The state named \(name) has no AnimationClip data.")
            return
        }

        let animatorLayerData = self._getAnimatorLayerData(animatorStateInfo.layerIndex)
        let layerState = animatorLayerData.layerState
        let destPlayData = animatorLayerData.destPlayData

        let animatorStateData = self._getAnimatorStateData(name, crossState!, animatorLayerData)
        let duration = crossState!._getDuration()
        let offset = duration * transition.offset
        destPlayData.reset(crossState!, animatorStateData, offset)

        self._saveDefaultValues(animatorStateData)

        switch (layerState) {
                // Maybe not play, maybe end.
        case LayerState.Standby:
            animatorLayerData.layerState = LayerState.FixedCrossFading
            self._clearCrossData(animatorLayerData)
            self._prepareStandbyCrossFading(animatorLayerData)
            break
        case LayerState.Playing:
            animatorLayerData.layerState = LayerState.CrossFading
            self._clearCrossData(animatorLayerData)
            self._prepareCrossFading(animatorLayerData)
            break
        case LayerState.CrossFading:
            animatorLayerData.layerState = LayerState.FixedCrossFading
            self._prepareFixedPoseCrossFading(animatorLayerData)
            break
        case LayerState.FixedCrossFading:
            self._prepareFixedPoseCrossFading(animatorLayerData)
            break
        }

        animatorLayerData.crossFadeTransition = transition
    }

    private func _fireAnimationEvents(
            _ playState: AnimatorStatePlayData,
            _ eventHandlers: [AnimationEventHandler],
            _ lastClipTime: Float,
            _ clipTime: Float
    ) {
        // TODO: If play backward, not work.
        if (clipTime < lastClipTime) {
            self._fireSubAnimationEvents(playState, eventHandlers, lastClipTime, playState.state.clipEndTime)
            playState.currentEventIndex = 0
            self._fireSubAnimationEvents(playState, eventHandlers, playState.state.clipStartTime, clipTime)
        } else {
            self._fireSubAnimationEvents(playState, eventHandlers, lastClipTime, clipTime)
        }
    }

    private func _fireSubAnimationEvents(
            _ playState: AnimatorStatePlayData,
            _ eventHandlers: [AnimationEventHandler],
            _ lastClipTime: Float,
            _ curClipTime: Float
    ) {
        for i in playState.currentEventIndex..<eventHandlers.count {
            let eventHandler = eventHandlers[i]
            let time = eventHandler.event.time
            let parameter = eventHandler.event.parameter

            if (time > curClipTime) {
                break
            }

            let handlers = eventHandler.handlers
            if (time >= lastClipTime) {
                for j in 0..<handlers.count {
                    handlers[j](parameter!)
                }
                playState.currentEventIndex = i + 1
            }
        }
    }

    private func _callAnimatorScriptOnEnter(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateEnterScripts
        for i in 0..<scripts.count {
            scripts[i].onStateEnter(self, state, layerIndex)
        }
    }

    private func _callAnimatorScriptOnUpdate(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateUpdateScripts
        for i in 0..<scripts.count {
            scripts[i].onStateUpdate(self, state, layerIndex)
        }
    }

    private func _callAnimatorScriptOnExit(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateExitScripts
        for i in 0..<scripts.count {
            scripts[i].onStateExit(self, state, layerIndex)
        }
    }

    private func _clearPlayData() {
        self._animatorLayersData = [:]
        self._crossCurveDataCollection = []
        self._animationCurveOwners = [:]
        self._controllerUpdateFlag.flag = false
    }
}
