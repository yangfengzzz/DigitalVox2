//
//  Scene.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

class Scene: EngineObject {
    /// Scene name. 
    var name: String

    private var _destroyed: Bool = false
    private var _rootEntities: [Entity] = []
    private var _resolution: Vector2 = Vector2()

    /**
     * Create scene.
     * @param engine - Engine
     * @param name - Name
     */
    init(engine: Engine, name: String?) {
        self.name = name != nil ? name! : ""
        super.init(engine: engine)
    }
}

