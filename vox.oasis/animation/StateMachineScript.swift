//
//  StateMachineScript.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// StateMachineScript is a component that can be added to a animator state.
/// It's the base class every script on a state derives from.
class StateMachineScript {
    internal var _destroyed: Bool = false
    internal var _state: AnimatorState!

    required init() {
    }

    /// onStateEnter is called when a transition starts and the state machine starts to evaluate this state.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateEnter(animator: Animator, animatorState: AnimatorState, layerIndex: Int) {
    }

    /// onStateUpdate is called on each Update frame between onStateEnter and onStateExit callbacks.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateUpdate(animator: Animator, animatorState: AnimatorState, layerIndex: Int) {
    }

    /// onStateExit is called when a transition ends and the state machine finishes evaluating this state.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateExit(animator: Animator, animatorState: AnimatorState, layerIndex: Int) {
    }

    /// Destroy this instance.
    func destroy() {
        if (_destroyed) {
            return
        }

        _state!._removeStateMachineScript(self)
        _destroyed = true
    }
}
