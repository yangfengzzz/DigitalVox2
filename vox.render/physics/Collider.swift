//
//  Collider.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

import Foundation

/// Abstract class for collider shapes.
class Collider: Component {
    // @ignoreClone
    internal var _index: Int = -1
    internal var _nativeCollider: ICollider!

    var _updateFlag: UpdateFlag

    private var _shapes: [ColliderShape] = []

    /// The shapes of this collider.
    var shapes: [ColliderShape] {
        get {
            _shapes
        }
    }

    required init(_ entity: Entity) {
        _updateFlag = entity.transform.registerWorldChangeFlag()
        super.init(entity)
    }

    /// Add collider shape on this collider.
    /// - Parameter shape: Collider shape
    func addShape(_ shape: ColliderShape) {
        let oldCollider = shape._collider
        if (oldCollider !== self) {
            if (oldCollider != nil) {
                oldCollider!.removeShape(shape)
            }
            _shapes.append(shape)
            engine.physicsManager!._addColliderShape(shape)
            _nativeCollider.addShape(shape._nativeShape)
            shape._collider = self
        }
    }

    /// Remove a collider shape.
    /// - Parameter shape: The collider shape.
    func removeShape(_  shape: ColliderShape) {
        let index = _shapes.firstIndex { s in
            s === shape
        }

        if (index != nil) {
            _shapes.remove(at: index!)
            _nativeCollider.removeShape(shape._nativeShape)
            engine.physicsManager!._removeColliderShape(shape)
            shape._collider = nil
        }
    }

    /// Remove all shape attached.
    func clearShapes() {
        for i in 0..<_shapes.count {
            _nativeCollider.removeShape(shapes[i]._nativeShape)
            engine.physicsManager!._removeColliderShape(shapes[i])
        }
        _shapes = []
    }


    internal func _onUpdate() {
        if (_updateFlag.flag) {
            let transform = self.entity.transform
            _nativeCollider.setWorldTransform(transform!.worldPosition, transform!.worldRotationQuaternion)
            _updateFlag.flag = false

            let worldScale = transform!.lossyWorldScale
            for i in 0..<_shapes.count {
                shapes[i]._nativeShape.setWorldScale(worldScale)
            }
        }
    }

    internal func _onLateUpdate() {
    }


    internal override func _onEnable() {
        engine.physicsManager!._addCollider(self)
        engine._componentsManager.addCollider(self)
    }


    internal override func _onDisable() {
        engine.physicsManager!._removeCollider(self)
        engine._componentsManager.removeCollider(self)
    }


    internal override func _onDestroy() {
        clearShapes()
    }
}
