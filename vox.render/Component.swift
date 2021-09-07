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

//MARK:- Get/Set Methods
extension Component {
    /// Indicates whether the component is enabled.
    var enabled: Bool {
        get {
            _enabled
        }
        set {
            if (newValue == _enabled) {
                return
            }
            _enabled = newValue
            if (newValue) {
                if _entity.isActiveInHierarchy {
                    _onEnable()
                }
            } else {
                if _entity.isActiveInHierarchy {
                    _onDisable()
                }
            }
        }
    }

    /// Indicates whether the component is destroyed.
    var destroyed: Bool {
        get {
            _destroyed
        }
    }

    /// The entity which the component belongs to.
    var entity: Entity {
        get {
            _entity
        }
    }

    /// The scene which the component's entity belongs to.
    var scene: Scene {
        get {
            _entity.scene
        }
    }
}

//MARK:- Public Methods
extension Component {
    /// Destroy this instance.
    func destroy() {
        if (_destroyed) {
            return
        }
        _entity._removeComponent(self)
        if (_entity.isActiveInHierarchy) {
            if _enabled {
                _onDisable()
            }
            _onInActive()
        }
        _destroyed = true
        _onDestroy()
    }
}

//MARK:- Internal Methods
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
