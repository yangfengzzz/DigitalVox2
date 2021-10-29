//
//  LayerState.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Layer state.
enum LayerState {
    /// Standby state.
    case Standby //TODO: Standby 优化
    /// Playing state.
    case Playing
    /// CrossFading state.
    case CrossFading
    /// FixedCrossFading state.
    case FixedCrossFading
}
