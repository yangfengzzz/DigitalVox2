//
//  LiteTransform.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Used to implement transformation related functions.
class LiteTransform {
    private static var _tempQuat0: Quaternion = Quaternion()
    private static var _tempMat42: Matrix = Matrix()

    private var _position: Vector3 = Vector3()
    private var _rotation: Vector3 = Vector3()
    private var _rotationQuaternion: Quaternion = Quaternion()
    private var _scale: Vector3 = Vector3(1, 1, 1)
    private var _worldRotationQuaternion: Quaternion = Quaternion()
    private var _localMatrix: Matrix = Matrix()
    private var _worldMatrix: Matrix = Matrix()
    private var _updateFlagManager: LiteUpdateFlagManager = LiteUpdateFlagManager()
    private var _isParentDirty: Bool = true
    private var _parentTransformCache: LiteTransform? = nil
    private var _dirtyFlag: Int = LiteTransformFlag.WmWpWeWqWs.rawValue

    private var _owner: AnyObject!

    func setOwner(owner: AnyObject) {
        _owner = owner
    }

    /// Local position.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var position: Vector3 {
        get {
            _position
        }
        set {
            if (_position !== newValue) {
                newValue.cloneTo(target: _position)
            }
            _setDirtyFlagTrue(type: TransformFlag.LocalMatrix.rawValue)
            _updateWorldPositionFlag()
        }
    }

    /// Local rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var rotationQuaternion: Quaternion {
        get {
            if (_isContainDirtyFlag(type: TransformFlag.LocalQuat.rawValue)) {
                Quaternion.rotationEuler(
                        x: MathUtil.degreeToRadian(_rotation.x),
                        y: MathUtil.degreeToRadian(_rotation.y),
                        z: MathUtil.degreeToRadian(_rotation.z),
                        out: _rotationQuaternion
                )
                _setDirtyFlagFalse(type: TransformFlag.LocalQuat.rawValue)
            }
            return _rotationQuaternion
        }
        set {
            if (_rotationQuaternion !== newValue) {
                newValue.cloneTo(target: _rotationQuaternion)
            }
            _setDirtyFlagTrue(type: TransformFlag.LocalMatrix.rawValue | TransformFlag.LocalEuler.rawValue)
            _setDirtyFlagFalse(type: TransformFlag.LocalQuat.rawValue)
            _updateWorldRotationFlag()
        }
    }


    /// World rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldRotationQuaternion: Quaternion {
        get {
            if (_isContainDirtyFlag(type: TransformFlag.WorldQuat.rawValue)) {
                let parent = _getParentTransform()
                if (parent != nil) {
                    Quaternion.multiply(left: parent!.worldRotationQuaternion, right: rotationQuaternion, out: _worldRotationQuaternion)
                } else {
                    rotationQuaternion.cloneTo(target: _worldRotationQuaternion)
                }
                _setDirtyFlagFalse(type: TransformFlag.WorldQuat.rawValue)
            }
            return _worldRotationQuaternion
        }
        set {
            if (_worldRotationQuaternion !== newValue) {
                newValue.cloneTo(target: _worldRotationQuaternion)
            }
            let parent = _getParentTransform()
            if (parent != nil) {
                Quaternion.invert(a: parent!.worldRotationQuaternion, out: LiteTransform._tempQuat0)
                Quaternion.multiply(left: newValue, right: LiteTransform._tempQuat0, out: _rotationQuaternion)
            } else {
                newValue.cloneTo(target: _rotationQuaternion)
            }
            rotationQuaternion = _rotationQuaternion
            _setDirtyFlagFalse(type: TransformFlag.WorldQuat.rawValue)
        }
    }

    /// Local scaling.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var scale: Vector3 {
        get {
            _scale
        }
        set {
            if (_scale !== newValue) {
                newValue.cloneTo(target: _scale)
            }
            _setDirtyFlagTrue(type: TransformFlag.LocalMatrix.rawValue)
            _updateWorldScaleFlag()
        }
    }

    /// Local matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var localMatrix: Matrix {
        get {
            if (_isContainDirtyFlag(type: LiteTransformFlag.LocalMatrix.rawValue)) {
                Matrix.affineTransformation(scale: _scale, rotation: rotationQuaternion, translation: _position, out: _localMatrix)
                _setDirtyFlagFalse(type: LiteTransformFlag.LocalMatrix.rawValue)
            }
            return _localMatrix
        }
        set {
            if (_localMatrix !== newValue) {
                newValue.cloneTo(target: _localMatrix)
            }
            _ = _localMatrix.decompose(translation: _position, rotation: _rotationQuaternion, scale: _scale)
            _setDirtyFlagTrue(type: LiteTransformFlag.LocalEuler.rawValue)
            _setDirtyFlagFalse(type: LiteTransformFlag.LocalMatrix.rawValue)
            _updateAllWorldFlag()
        }
    }

    /// World matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldMatrix: Matrix {
        get {
            if (_isContainDirtyFlag(type: LiteTransformFlag.WorldMatrix.rawValue)) {
                let parent = _getParentTransform()
                if (parent != nil) {
                    Matrix.multiply(left: parent!.worldMatrix, right: localMatrix, out: _worldMatrix)
                } else {
                    localMatrix.cloneTo(target: _worldMatrix)
                }
                _setDirtyFlagFalse(type: LiteTransformFlag.WorldMatrix.rawValue)
            }
            return _worldMatrix
        }
        set {
            if (_worldMatrix !== newValue) {
                newValue.cloneTo(target: _worldMatrix)
            }
            let parent = _getParentTransform()
            if (parent != nil) {
                Matrix.invert(a: parent!.worldMatrix, out: LiteTransform._tempMat42)
                Matrix.multiply(left: newValue, right: LiteTransform._tempMat42, out: _localMatrix)
            } else {
                newValue.cloneTo(target: _localMatrix)
            }
            localMatrix = _localMatrix
            _setDirtyFlagFalse(type: LiteTransformFlag.WorldMatrix.rawValue)
        }
    }

    /// Set local position by X, Y, Z value.
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    ///   - z: Z coordinate
    func setPosition(x: Float, y: Float, z: Float) {
        _ = _position.setValue(x: x, y: y, z: z)
        position = _position
    }

    /// Set local rotation by the X, Y, Z, and W components of the quaternion.
    /// - Parameters:
    ///   - x: X component of quaternion
    ///   - y: Y component of quaternion
    ///   - z: Z component of quaternion
    ///   - w: W component of quaternion
    func setRotationQuaternion(x: Float, y: Float, z: Float, w: Float) {
        _ = _rotationQuaternion.setValue(x: x, y: y, z: z, w: w)
        rotationQuaternion = _rotationQuaternion
    }

    /// Set local scaling by scaling values along X, Y, Z axis.
    /// - Parameters:
    ///   - x: Scaling along X axis
    ///   - y: Scaling along Y axis
    ///   - z: Scaling along Z axis
    func setScale(x: Float, y: Float, z: Float) {
        _ = _scale.setValue(x: x, y: y, z: z)
        scale = _scale
    }

    /// Register world transform change flag.
    /// - Returns: Change flag
    func registerWorldChangeFlag() -> LiteUpdateFlag {
        _updateFlagManager.register()
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldPositionFlag() {
        if (!_isContainDirtyFlags(targetDirtyFlags: LiteTransformFlag.WmWp.rawValue)) {
            _worldAssociatedChange(type: LiteTransformFlag.WmWp.rawValue)
            guard let collider = _owner! as? LiteCollider else {
                return
            }

            let shapes = collider._shapes
            for i in 0..<shapes.count {
                shapes[i]._transform._updateWorldPositionFlag()
            }
        }
    }

    /**
     * Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
     * Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
     * Get worldRotationQuaternion: Will trigger the world rotation (in quaternion) update of itself and all parent entities.
     * Get worldRotation: Will trigger the world rotation(in euler and quaternion) update of itself and world rotation(in quaternion) update of all parent entities.
     * In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
     */
    private func _updateWorldRotationFlag() {
        if (!_isContainDirtyFlags(targetDirtyFlags: LiteTransformFlag.WmWeWq.rawValue)) {
            _worldAssociatedChange(type: LiteTransformFlag.WmWeWq.rawValue)
            guard let collider = _owner! as? LiteCollider else {
                return
            }

            let shapes = collider._shapes
            for i in 0..<shapes.count {
                shapes[i]._transform._updateWorldRotationFlag()
            }

        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldScale: Will trigger the scaling update of itself and all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix) to be false.
    private func _updateWorldScaleFlag() {
        if (!_isContainDirtyFlags(targetDirtyFlags: LiteTransformFlag.WmWs.rawValue)) {
            _worldAssociatedChange(type: LiteTransformFlag.WmWs.rawValue)
            guard let collider = _owner! as? LiteCollider else {
                return
            }

            let shapes = collider._shapes
            for i in 0..<shapes.count {
                shapes[i]._transform._updateWorldScaleFlag()
            }

        }
    }

    /// Update all world transform property dirty flag, the principle is the same as above.
    private func _updateAllWorldFlag() {
        if (!_isContainDirtyFlags(targetDirtyFlags: LiteTransformFlag.WmWpWeWqWs.rawValue)) {
            _worldAssociatedChange(type: LiteTransformFlag.WmWpWeWqWs.rawValue)
            guard let collider = _owner! as? LiteCollider else {
                return
            }

            let shapes = collider._shapes
            for i in 0..<shapes.count {
                shapes[i]._transform._updateAllWorldFlag()
            }
        }
    }

    private func _getParentTransform() -> LiteTransform? {
        if (!_isParentDirty) {
            return _parentTransformCache
        }
        var parentCache: LiteTransform? = nil

        let colliderShape = _owner! as? LiteColliderShape
        if (colliderShape != nil) {
            let parent = colliderShape!._collider
            parentCache = parent!._transform
        }

        _parentTransformCache = parentCache
        _isParentDirty = false
        return parentCache
    }

    private func _isContainDirtyFlags(targetDirtyFlags: Int) -> Bool {
        (_dirtyFlag & targetDirtyFlags) == targetDirtyFlags
    }

    private func _isContainDirtyFlag(type: Int) -> Bool {
        (_dirtyFlag & type) != 0
    }

    private func _setDirtyFlagTrue(type: Int) {
        _dirtyFlag |= type
    }

    private func _setDirtyFlagFalse(type: Int) {
        _dirtyFlag &= ~type
    }

    private func _worldAssociatedChange(type: Int) {
        _dirtyFlag |= type
        _updateFlagManager.distribute()
    }
}

/// Dirty flag of transform.
enum LiteTransformFlag: Int {
    case LocalEuler = 0x1
    case LocalQuat = 0x2
    case WorldPosition = 0x4
    case WorldEuler = 0x8
    case WorldQuat = 0x10
    case WorldScale = 0x20
    case LocalMatrix = 0x40
    case WorldMatrix = 0x80

    /// WorldMatrix | WorldPosition
    case WmWp = 0x84
    /// WorldMatrix | WorldEuler | WorldQuat
    case WmWeWq = 0x98
    /// WorldMatrix | WorldPosition | WorldEuler | WorldQuat
    case WmWpWeWq = 0x9c
    /// WorldMatrix | WorldScale
    case WmWs = 0xa0
    /// WorldMatrix | WorldPosition | WorldScale
    case WmWpWs = 0xa4
    /// WorldMatrix | WorldPosition | WorldEuler | WorldQuat | WorldScale
    case WmWpWeWqWs = 0xbc
}
