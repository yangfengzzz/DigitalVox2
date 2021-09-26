//
//  EngineFeature.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/26.
//

import Foundation

/// Engine feature plug-in.
protocol EngineFeature : AnyObject {
    /// Callback before the engine main loop runs,used to load resource.
    func preLoad(_ engine: Engine)

    /// Callback before every engine tick.
    func preTick(engine: Engine, currentScene: Scene)

    /// Callback after every engine tick.
    func postTick(engine: Engine, currentScene: Scene)

    /// Callback after the engine is destroyed.
    func shutdown(engine: Engine)
}
