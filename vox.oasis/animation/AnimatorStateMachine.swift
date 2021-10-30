//
//  AnimatorStateMachine.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// A graph controlling the interaction of states. Each state references a motion.
class AnimatorStateMachine {
    /// The list of states.
    var states: [AnimatorState] = []

    internal var _statesMap: [String: AnimatorState] = [:]

    /// Add a state to the state machine.
    /// - Parameter name: The name of the new state
    /// - Returns: new state
    func addState(_ name: String) -> AnimatorState {
        var state = self.findStateByName(name)
        if state == nil {
            state = AnimatorState(name)
            self.states.append(state!)
            self._statesMap[name] = state
        } else {
            logger.warning("The state named \(name) has existed.")
        }
        return state!
    }

    /// Remove a state from the state machine.
    /// - Parameter state: The state
    func removeState(_ state: AnimatorState) {
        let name = state.name
        states.removeAll { s in
            s === state
        }
        self._statesMap.removeValue(forKey: name)
    }

    /// Get the state by name.
    /// - Parameter name: The layer's name
    func findStateByName(_ name: String) -> AnimatorState? {
        return self._statesMap[name]
    }

    /// Makes a unique state name in the state machine.
    /// - Parameter name: Desired name for the state.
    /// - Returns: Unique name.
    func makeUniqueStateName(_ name: inout String) -> String {
        let originName = name
        var index = 0
        while (_statesMap[name] != nil) {
            name = "\(originName) \(index)"
            index += 1
        }
        return name
    }
}