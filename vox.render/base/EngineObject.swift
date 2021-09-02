//
//  EngineObject.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

class EngineObject {
    private static var _instanceIdCounter: Int = 0

    /// Engine unique id.
    let instanceId: Int

    /// Engine to which the object belongs.
    var _engine: Engine

    /// Get the engine which the object belongs.
    var engine: Engine {
        get {
            _engine
        }
    }

    init(engine: Engine) {
        EngineObject._instanceIdCounter += 1
        instanceId = EngineObject._instanceIdCounter

        _engine = engine
    }
}
