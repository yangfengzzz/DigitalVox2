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
    /// The background of the scene.
    var background: Background = Background()
    /// Scene-related shader data.
    var shaderData: ShaderData = ShaderData(ShaderDataGroup.Scene)

    internal var _activeCameras: [Camera] = []
    internal var _isActiveInEngine: Bool = false

    private var _destroyed: Bool = false
    private var _rootEntities: [Entity] = []

    /// Count of root entities.
    var rootEntitiesCount: Int {
        get {
            _rootEntities.count
        }
    }

    /// Root entity collection.
    var rootEntities: [Entity] {
        get {
            _rootEntities
        }
    }

    /// Whether it's destroyed.
    var destroyed: Bool {
        get {
            _destroyed
        }
    }


    /// Create scene.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Name
    init(_ engine: Engine, _ name: String?) {
        self.name = name != nil ? name! : ""
        shaderData._addRefCount(1)
        
        super.init(engine)
    }
}

//MARK:- Public Members
extension Scene {
    /// Create root entity.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    func createRootEntity(_ name: String? = nil) -> Entity {
        let entity = Entity(_engine, name)
        addRootEntity(entity)
        return entity
    }

    /// Append an entity.
    /// - Parameter entity: The root entity to add
    func addRootEntity(_ entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if (!isRoot) {
            entity._isRoot = true
            _ = entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if (oldScene !== self) {
            if ((oldScene != nil) && isRoot) {
                oldScene!._removeEntity(entity)
            }
            _rootEntities.append(entity)
            Entity._traverseSetOwnerScene(entity, self)
        } else if (!isRoot) {
            _rootEntities.append(entity)
        }

        // process entity active/inActive
        if (_isActiveInEngine) {
            if !entity._isActiveInHierarchy && entity._isActive {
                entity._processActive()
            }
        } else {
            if entity._isActiveInHierarchy {
                entity._processInActive()
            }
        }
    }

    /// Remove an entity.
    /// - Parameter entity: The root entity to remove
    func removeRootEntity(_ entity: Entity) {
        if (entity._isRoot && entity._scene === self) {
            _removeEntity(entity)
            if _isActiveInEngine {
                entity._processInActive()
            }
            Entity._traverseSetOwnerScene(entity, nil)
        }
    }

    /// Get root entity from index.
    /// - Parameter index: Index
    /// - Returns: Entity
    func getRootEntity(_ index: Int = 0) -> Entity? {
        return _rootEntities[index]
    }

    /// Find entity globally by name.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    func findEntityByName(_ name: String) -> Entity? {
        let children = _rootEntities
        for i in 0..<children.count {
            let child = children[i]
            if (child.name == name) {
                return child
            }
        }

        for i in 0..<children.count {
            let child = children[i]
            let entity = child.findByName(name)
            if (entity != nil) {
                return entity
            }
        }
        return nil
    }

    /// Find entity globally by name,use ‘/’ symbol as a path separator.
    /// - Parameter path: Entity's path
    /// - Returns: Entity
    func findEntityByPath(_ path: String) -> Entity? {
        let splits = path.split(separator: "/")
        for i in 0..<rootEntitiesCount {
            var findEntity = getRootEntity(i)
            if (findEntity!.name != splits[0]) {
                continue
            }
            for j in 1..<splits.count {
                findEntity = Entity._findChildByName(findEntity!, String(splits[j]))
                if findEntity == nil {
                    break
                }
            }
            return findEntity
        }
        return nil
    }
}

//MARK:- Internal Members
extension Scene {
    internal func _attachRenderCamera(_ camera: Camera) {
        let index = _activeCameras.firstIndex { cam in
            cam === camera
        }
        if (index == nil) {
            _activeCameras.append(camera)
        } else {
            logger.warning("Camera already attached.")
        }
    }

    internal func _detachRenderCamera(_ camera: Camera) {
        _activeCameras.removeAll { cam in
            cam === camera
        }
    }

    internal func _processActive(_ active: Bool) {
        _isActiveInEngine = active
        let rootEntities = _rootEntities
        for i in 0..<rootEntities.count {
            let entity = rootEntities[i]
            if (entity._isActive) {
                active ? entity._processActive() : entity._processInActive()
            }
        }
    }
}

//MARK:- Private Members
extension Scene {
    private func _removeEntity(_ entity: Entity) {
        var oldRootEntities = _rootEntities
        oldRootEntities.removeAll { e in
            e === entity
        }
    }
}
