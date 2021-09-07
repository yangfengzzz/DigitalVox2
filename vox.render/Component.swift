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

    required init(_ entity: Entity) {
        _entity = entity
        super.init(entity.engine)
    }
}

extension Component {
    internal func _onAwake() {
    }

    internal func _onEnable() {
    }

    internal func _onDisable() {
    }

    internal func _onDestroy() {
    }

    internal func _onActive() {
    }

    internal func _onInActive() {
    }

    internal func _setActive(_ value: Bool) {
        if (value) {
            if (!_awoken) {
                _awoken = true
                _onAwake()
            }
            // You can do isActive = false in onAwake function.
            if (_entity._isActiveInHierarchy) {
                _onActive()
                if _enabled {
                    _onEnable()
                }
            }
        } else {
            if _enabled {
                _onDisable()
            }
            _onInActive()
        }
    }
}
