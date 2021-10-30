//
//  AnimatorControllerLayer.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// The Animation Layer contains a state machine that controls animations of a model or part of it.
class AnimatorControllerLayer {
    /// The blending weight that the layers has. It is not taken into account for the first layer.
    var weight: Float = 1.0
    /// The blending mode used by the layer. It is not taken into account for the first layer.
    var blendingMode: AnimatorLayerBlendingMode = AnimatorLayerBlendingMode.Override
    /// The state machine for the layer.
    var stateMachine: AnimatorStateMachine!

    /// The layer's name
    var name: String

    init(_ name: String) {
        self.name = name
    }
}
