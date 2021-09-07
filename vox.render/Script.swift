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
    internal var _started: Bool = false;
    // @ignoreClone
    internal var _onStartIndex: Int = -1;
    //  @ignoreClone
    internal var _onUpdateIndex: Int = -1;
    // @ignoreClone
    internal var _onLateUpdateIndex: Int = -1;
    // @ignoreClone
    internal var _onPreRenderIndex: Int = -1;
    // @ignoreClone
    internal var _onPostRenderIndex: Int = -1;
    // @ignoreClone
    var _entityCacheIndex: Int = -1;
}

extension Script {
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
}
