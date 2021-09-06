//
//  Component.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

/// The base class of the components.
class Component: EngineObject {
    // @ignoreClone
    internal var _entity: Entity
    // @ignoreClone
    internal var _destroyed: Bool = false

    // @assignmentClone
    private var _enabled: Bool = true
    //  @ignoreClone
    private var _awoken: Bool = false

    init(entity: Entity) {
        self._entity = entity
        super.init(engine: entity.engine)
    }
}
