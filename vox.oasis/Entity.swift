//
//  Entity.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

/// Entity, be used as components container.
final class Entity: EngineObject {
    /// The name of entity.
    var name: String
    /// The layer the entity belongs to.
    var layer: Layer = .Layer0
    /// Transform component. 
    var transform: Transform!

    internal var _isActiveInHierarchy: Bool = false
    internal var _components: [Component] = []
    internal var _scripts: DisorderedArray<Script> = DisorderedArray()
    internal var _children: [Entity] = []
    internal var _scene: Scene!
    internal var _isRoot: Bool = false
    internal var _isActive: Bool = true

    private var _parent: Entity? = nil
    private var _activeChangedComponents: [Component]?

    /// Create a entity.
    /// - Parameters:
    ///   - engine: The engine the entity belongs to.
    ///   - name: Optional
    init(_ engine: Engine, _ name: String?) {
        self.name = name != nil ? name! : ""
        super.init(engine)

        transform = addComponent()
        _inverseWorldMatFlag = transform.registerWorldChangeFlag()
    }

    private var _invModelMatrix: Matrix = Matrix()
    private var _inverseWorldMatFlag: UpdateFlag!
}

//MARK:- Get/Set Methods
extension Entity {
    /// Whether to activate locally.
    var isActive: Bool {
        get {
            _isActive
        }
        set {
            if (newValue != _isActive) {
                _isActive = newValue
                if (newValue) {
                    let parent = _parent
                    if (parent?._isActiveInHierarchy ?? false || (_isRoot && _scene._isActiveInEngine)) {
                        _processActive()
                    }
                } else {
                    if (_isActiveInHierarchy) {
                        _processInActive()
                    }
                }
            }
        }
    }

    /// Whether it is active in the hierarchy.
    var isActiveInHierarchy: Bool {
        get {
            _isActiveInHierarchy
        }
    }

    /// The parent entity.
    var parent: Entity? {
        get {
            _parent
        }
        set {
            if (newValue !== _parent) {
                let oldParent = _removeFromParent()
                _parent = newValue
                let newParent = _parent
                if (newParent != nil) {
                    newParent!._children.append(self)
                    let parentScene = newParent!._scene
                    if (_scene !== parentScene) {
                        Entity._traverseSetOwnerScene(self, parentScene!)
                    }

                    if (newParent!._isActiveInHierarchy) {
                        if !_isActiveInHierarchy && _isActive {
                            _processActive()
                        }
                    } else {
                        if _isActiveInHierarchy {
                            _processInActive()
                        }
                    }
                } else {
                    if _isActiveInHierarchy {
                        _processInActive()
                    }
                    if (oldParent != nil) {
                        Entity._traverseSetOwnerScene(self, nil)
                    }
                }
                _setTransformDirty()
            }
        }
    }

    /// The children entities
    var children: [Entity] {
        get {
            _children
        }
    }

    /// Number of the children entities
    var childCount: Int {
        get {
            _children.count
        }
    }

    /// The scene the entity belongs to.
    var scene: Scene {
        get {
            _scene
        }
    }
}

//MARK:- Static Methods
extension Entity {
    internal static func _findChildByName(_ root: Entity, _ name: String) -> Entity? {
        let children = root._children
        for i in 0..<children.count {
            let child = children[i]
            if (child.name == name) {
                return child
            }
        }
        return nil
    }

    internal static func _traverseSetOwnerScene(_ entity: Entity, _ scene: Scene?) {
        entity._scene = scene
        let children = entity._children
        for i in 0..<entity.childCount {
            _traverseSetOwnerScene(children[i], scene)
        }
    }
}

//MARK:- Public Methods
extension Entity {
    /// Add component based on the component type.
    /// - Returns: The component which has been added.
    func addComponent<T: Component>() -> T {
        //todo ComponentsDependencies._addCheck(this, type)
        let component = T(self)
        _components.append(component)
        if (_isActiveInHierarchy) {
            component._setActive(true)
        }
        return component
    }

    /// Get component which match the type.
    /// - Returns: The first component which match type.
    func getComponent<T: Component>() -> T {
        for i in 0..<_components.count {
            let component = _components[i]
            if (component is T) {
                return component as! T
            }
        }
        fatalError()
    }

    /// Get components which match the type.
    /// - Parameter results: The components which match type.
    /// - Returns: The components which match type.
    func getComponents<T: Component>(_ results: inout [T]) -> [T] {
        results = []
        for i in 0..<_components.count {
            let component = _components[i]
            if (component is T) {
                results.append(component as! T)
            }
        }
        return results
    }

    /// Get the components which match the type of the entity and it's children.
    /// - Parameter results: The components collection.
    /// - Returns:  The components collection which match the type.
    func getComponentsIncludeChildren<T: Component>(_ results: inout [T]) -> [T] {
        results = []
        _getComponentsInChildren(&results)
        return results
    }

    /// Add child entity.
    /// - Parameter child: The child entity which want to be added.
    func addChild(_ child: Entity) {
        child.parent = self
    }

    /// Remove child entity.
    /// - Parameter child: The child entity which want to be removed.
    func removeChild(_ child: Entity) {
        child.parent = nil
    }

    /// Find child entity by index.
    /// - Parameter index: The index of the child entity.
    /// - Returns: The component which be found.
    func getChild(_ index: Int) -> Entity {
        return _children[index]
    }

    /// Find child entity by name.
    /// - Parameter name: The name of the entity which want to be found.
    /// - Returns: The component which be found.
    func findByName(_ name: String) -> Entity? {
        let children = _children
        let child = Entity._findChildByName(self, name)
        if (child != nil) {
            return child
        }
        for i in 0..<children.count {
            let child = children[i]
            let grandson = child.findByName(name)
            if (grandson != nil) {
                return grandson
            }
        }
        return nil
    }

    /// Find the entity by path.
    /// - Parameter path: The path fo the entity eg: /entity.
    /// - Returns: The component which be found.
    func findByPath(_ path: String) -> Entity? {
        let splits = path.split(separator: "/")
        var entity: Entity? = self
        for i in 0..<splits.count {
            let split = splits[i]
            entity = Entity._findChildByName(entity!, String(split))
            if (entity == nil) {
                return nil
            }
        }
        return entity
    }

    /// Create child entity.
    /// - Parameter name: The child entity's name.
    /// - Returns: The child entity.
    func createChild(_ name: String? = nil) -> Entity {
        let child = Entity(engine, name)
        child.layer = layer
        child.parent = self
        return child
    }

    /// Clear children entities.
    func clearChildren() {
        var children = _children
        for i in 0..<children.count {
            let child = children[i]
            child._parent = nil
            if child._isActiveInHierarchy {
                child._processInActive()
            }
            Entity._traverseSetOwnerScene(child, nil) // Must after child._processInActive().
        }
        children = []
    }

    /// Clone
    /// - Returns: Cloned entity.
    func clone() -> Entity {
        let cloneEntity = Entity(_engine, name)

        cloneEntity._isActive = _isActive
        cloneEntity.transform.localMatrix = transform.localMatrix

        let children = _children
        for i in 0..<_children.count {
            let child = children[i]
            cloneEntity.addChild(child.clone())
        }

        let components = _components
        for i in 0..<components.count {
            let sourceComp = components[i]
            if (!(sourceComp is Transform)) {
                // todo
                // let targetComp = cloneEntity.addComponent(<new (entity: Entity) => Component>sourceComp.constructor)
                // ComponentCloner.cloneComponent(sourceComp, targetComp)
            }
        }

        return cloneEntity
    }

    /// Destroy self.
    func destroy() {
        let abilityArray = _components
        for i in 0..<abilityArray.count {
            abilityArray[i].destroy()
        }
        _components = []

        let children = _children
        for i in 0..<children.count {
            children[i].destroy()
        }
        _children = []

        if (_parent != nil) {
            var parentChildren = _parent!._children
            parentChildren.removeAll { entity in
                entity === self
            }
        }
        _parent = nil
    }
}

//MARK:- Internal Methods
extension Entity {
    internal func _removeComponent(_ component: Component) {
        //todo  ComponentsDependencies._removeCheck(this, component.constructor as any)
        var components = _components
        components.removeAll { value in
            value === component
        }
    }

    internal func _addScript(_ script: Script) {
        script._entityCacheIndex = _scripts.length
        _scripts.add(script)
    }

    internal func _removeScript(_ script: Script) {
        let replaced = _scripts.deleteByIndex(script._entityCacheIndex)
        if replaced != nil {
            replaced!._entityCacheIndex = script._entityCacheIndex
        }
        script._entityCacheIndex = -1
    }

    internal func _removeFromParent() -> Entity? {
        let oldParent = _parent
        if (oldParent != nil) {
            var oldParentChildren = oldParent!._children
            oldParentChildren.removeAll { entity in
                entity === self
            }
            _parent = nil
        }
        return oldParent
    }

    internal func _processActive() {
        if (_activeChangedComponents != nil) {
            fatalError("Note: can't set the 'main inActive entity' active in hierarchy, if the operation is in main inActive entity or it's children script's onDisable Event.")
        }
        _activeChangedComponents = _engine._componentsManager.getActiveChangedTempList()
        _setActiveInHierarchy(&_activeChangedComponents!)
        _setActiveComponents(true)
    }

    internal func _processInActive() {
        if (_activeChangedComponents != nil) {
            fatalError("Note: can't set the 'main active entity' inActive in hierarchy, if the operation is in main active entity or it's children script's onEnable Event.")
        }
        _activeChangedComponents = _engine._componentsManager.getActiveChangedTempList()
        _setInActiveInHierarchy(&_activeChangedComponents!)
        _setActiveComponents(false)
    }
}

//MARK:- Private Methods
extension Entity {
    private func _getComponentsInChildren<T: Component>(_ results: inout [T]) {
        for i in 0..<_components.count {
            let component = _components[i]
            if (component is T) {
                results.append(component as! T)
            }
        }
        for i in 0..<_children.count {
            _children[i]._getComponentsInChildren(&results)
        }
    }

    private func _setActiveComponents(_ isActive: Bool) {
        var activeChangedComponents = _activeChangedComponents
        for i in 0..<activeChangedComponents!.count {
            activeChangedComponents![i]._setActive(isActive)
        }
        _engine._componentsManager.putActiveChangedTempList(&activeChangedComponents!)
        _activeChangedComponents = []
    }

    private func _setActiveInHierarchy(_ activeChangedComponents: inout [Component]) {
        _isActiveInHierarchy = true
        let components = _components
        for i in 0..<components.count {
            activeChangedComponents.append(components[i])
        }
        let children = _children
        for i in 0..<children.count {
            let child = children[i]
            if child.isActive {
                child._setActiveInHierarchy(&activeChangedComponents)
            }
        }
    }

    private func _setInActiveInHierarchy(_ activeChangedComponents: inout [Component]) {
        _isActiveInHierarchy = false
        let components = _components
        for i in 0..<components.count {
            activeChangedComponents.append(components[i])
        }
        let children = _children
        for i in 0..<children.count {
            let child = children[i]
            if child.isActive {
                child._setInActiveInHierarchy(&activeChangedComponents)
            }
        }
    }

    private func _setTransformDirty() {
        if (transform != nil) {
            transform!._parentChange()
        } else {
            for i in 0..<_children.count {
                _children[i]._setTransformDirty()
            }
        }
    }
}

//MARK:- Depreciation
extension Entity {
    func getInvModelMatrix() -> Matrix {
        if (_inverseWorldMatFlag.flag) {
            Matrix.invert(a: transform.worldMatrix, out: _invModelMatrix)
            _inverseWorldMatFlag.flag = false
        }
        return _invModelMatrix
    }
}
