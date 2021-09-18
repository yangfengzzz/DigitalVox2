//
//  DepthState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

/// Depth state.
class DepthState {
    /// Whether to enable the depth test. 
    var enabled: Bool = true
    /// Whether the depth value can be written.
    var writeEnabled: Bool = true
    /// Depth comparison function.
    var compareFunction: CompareFunction = .Less
}
