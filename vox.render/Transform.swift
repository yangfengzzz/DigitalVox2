//
//  Transform.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

/// Used to implement transformation related functions.
class Transform: Component {
    private static var _tempQuat0: Quaternion = Quaternion()
    private static var _tempVec3: Vector3 = Vector3()
    private static var _tempMat30: Matrix3x3 = Matrix3x3()
    private static var _tempMat31: Matrix3x3 = Matrix3x3()
    private static var _tempMat32: Matrix3x3 = Matrix3x3()
    private static var _tempMat40: Matrix = Matrix()
    private static var _tempMat41: Matrix = Matrix()
    private static var _tempMat42: Matrix = Matrix()
    private static var _tempMat43: Matrix = Matrix()

    // @deepClone
    private var _position: Vector3 = Vector3()
    // @deepClone
    private var _rotation: Vector3 = Vector3()
    // @deepClone
    private var _rotationQuaternion: Quaternion = Quaternion()
    // @deepClone
    private var _scale: Vector3 = Vector3(1, 1, 1)
    // @deepClone
    private var _worldPosition: Vector3 = Vector3()
    // @deepClone
    private var _worldRotation: Vector3 = Vector3()
    // @deepClone
    private var _worldRotationQuaternion: Quaternion = Quaternion()
    // @deepClone
    private var _lossyWorldScale: Vector3 = Vector3(1, 1, 1)
    // @deepClone
    private var _localMatrix: Matrix = Matrix()
    // @deepClone
    private var _worldMatrix: Matrix = Matrix()
    // @ignoreClone
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()
    // @ignoreClone
    private var _isParentDirty: Bool = true
    // @ignoreClone
    private var _parentTransformCache: Transform? = nil

    private var _dirtyFlag: Int = TransformFlag.WmWpWeWqWs.rawValue
}

//MARK:- Get/Set Property
extension Transform {
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
            _setDirtyFlagTrue(TransformFlag.LocalMatrix.rawValue)
            _updateWorldPositionFlag()
        }
    }

    /// World position.
    /// - Remark:  Need to re-assign after modification to ensure that the modification takes effect.
    var worldPosition: Vector3 {
        get {
            if (_isContainDirtyFlag(TransformFlag.WorldPosition.rawValue)) {
                if (_getParentTransform() != nil) {
                    _ = worldMatrix.getTranslation(out: _worldPosition)
                } else {
                    _position.cloneTo(target: _worldPosition)
                }
                _setDirtyFlagFalse(TransformFlag.WorldPosition.rawValue)
            }
            return _worldPosition
        }
        set {
            if (_worldPosition !== newValue) {
                newValue.cloneTo(target: _worldPosition)
            }
            let parent = _getParentTransform()
            if (parent != nil) {
                Matrix.invert(a: parent!.worldMatrix, out: Transform._tempMat41)
                Vector3.transformCoordinate(v: newValue, m: Transform._tempMat41, out: _position)
            } else {
                newValue.cloneTo(target: _position)
            }
            position = _position
            _setDirtyFlagFalse(TransformFlag.WorldPosition.rawValue)
        }
    }


    /// Local rotation, defining the rotation value in degrees.
    /// Rotations are performed around the Y axis, the X axis, and the Z axis, in that order.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect
    var rotation: Vector3 {
        get {
            if (_isContainDirtyFlag(TransformFlag.LocalEuler.rawValue)) {
                _ = _rotationQuaternion.toEuler(out: _rotation)
                _ = _rotation.scale(s: MathUtil.radToDegreeFactor) // radians to degrees

                _setDirtyFlagFalse(TransformFlag.LocalEuler.rawValue)
            }
            return _rotation
        }
        set {
            if (_rotation !== newValue) {
                newValue.cloneTo(target: rotation)
            }
            _setDirtyFlagTrue(TransformFlag.LocalMatrix.rawValue | TransformFlag.LocalQuat.rawValue)
            _setDirtyFlagFalse(TransformFlag.LocalEuler.rawValue)
            _updateWorldRotationFlag()
        }
    }

    /// World rotation, defining the rotation value in degrees.
    /// Rotations are performed around the Y axis, the X axis, and the Z axis, in that order.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldRotation: Vector3 {
        get {
            if (_isContainDirtyFlag(TransformFlag.WorldEuler.rawValue)) {
                _ = worldRotationQuaternion.toEuler(out: _worldRotation)
                _ = _worldRotation.scale(s: MathUtil.radToDegreeFactor) // Radian to angle
                _setDirtyFlagFalse(TransformFlag.WorldEuler.rawValue)
            }
            return _worldRotation
        }
        set {
            if (_worldRotation !== newValue) {
                newValue.cloneTo(target: _worldRotation)
            }
            Quaternion.rotationEuler(
                x: MathUtil.degreeToRadian(newValue.x),
                y: MathUtil.degreeToRadian(newValue.y),
                z: MathUtil.degreeToRadian(newValue.z),
                    out: _worldRotationQuaternion
            )
            worldRotationQuaternion = _worldRotationQuaternion
            _setDirtyFlagFalse(TransformFlag.WorldEuler.rawValue)
        }
    }

    /// Local rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var rotationQuaternion: Quaternion {
        get {
            if (_isContainDirtyFlag(TransformFlag.LocalQuat.rawValue)) {
                Quaternion.rotationEuler(
                    x: MathUtil.degreeToRadian(_rotation.x),
                    y: MathUtil.degreeToRadian(_rotation.y),
                    z: MathUtil.degreeToRadian(_rotation.z),
                        out: _rotationQuaternion
                )
                _setDirtyFlagFalse(TransformFlag.LocalQuat.rawValue)
            }
            return _rotationQuaternion
        }
        set {
            if (_rotationQuaternion !== newValue) {
                newValue.cloneTo(target: _rotationQuaternion)
            }
            self._setDirtyFlagTrue(TransformFlag.LocalMatrix.rawValue | TransformFlag.LocalEuler.rawValue)
            self._setDirtyFlagFalse(TransformFlag.LocalQuat.rawValue)
            self._updateWorldRotationFlag()
        }
    }

    /// World rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldRotationQuaternion: Quaternion {
        get {
            if (_isContainDirtyFlag(TransformFlag.WorldQuat.rawValue)) {
                let parent = _getParentTransform()
                if (parent != nil) {
                    Quaternion.multiply(left: parent!.worldRotationQuaternion, right: rotationQuaternion, out: _worldRotationQuaternion)
                } else {
                    rotationQuaternion.cloneTo(target: _worldRotationQuaternion)
                }
                _setDirtyFlagFalse(TransformFlag.WorldQuat.rawValue)
            }
            return _worldRotationQuaternion
        }
        set {
            if (_worldRotationQuaternion !== newValue) {
                newValue.cloneTo(target: _worldRotationQuaternion)
            }
            let parent = _getParentTransform()
            if (parent != nil) {
                Quaternion.invert(a: parent!.worldRotationQuaternion, out: Transform._tempQuat0)
                Quaternion.multiply(left: newValue, right: Transform._tempQuat0, out: _rotationQuaternion)
            } else {
                newValue.cloneTo(target: _rotationQuaternion)
            }
            rotationQuaternion = _rotationQuaternion
            _setDirtyFlagFalse(TransformFlag.WorldQuat.rawValue)
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
            _setDirtyFlagTrue(TransformFlag.LocalMatrix.rawValue)
            _updateWorldScaleFlag()
        }
    }

    /// Local lossy scaling.
    /// - Remark: The value obtained may not be correct under certain conditions(for example, the parent node has scaling,
    /// and the child node has a rotation), the scaling will be tilted. Vector3 cannot be used to correctly represent the scaling. Must use Matrix3x3.
    var lossyWorldScale: Vector3 {
        get {
            if (_isContainDirtyFlag(TransformFlag.WorldScale.rawValue)) {
                if (_getParentTransform() != nil) {
                    let scaleMat = _getScaleMatrix()
                    let e = scaleMat.elements
                    _ = _lossyWorldScale.setValue(x: e.columns.0[0], y: e.columns.1[0], z: e.columns.2[0])
                } else {
                    _scale.cloneTo(target: _lossyWorldScale)
                }
                _setDirtyFlagFalse(TransformFlag.WorldScale.rawValue)
            }
            return _lossyWorldScale
        }
    }

    /// Local matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var localMatrix: Matrix {
        get {
            if (_isContainDirtyFlag(TransformFlag.LocalMatrix.rawValue)) {
                Matrix.affineTransformation(scale: _scale, rotation: rotationQuaternion, translation: _position, out: _localMatrix)
                _setDirtyFlagFalse(TransformFlag.LocalMatrix.rawValue)
            }
            return _localMatrix
        }
        set {
            if (_localMatrix !== newValue) {
                newValue.cloneTo(target: _localMatrix)
            }
            _ = _localMatrix.decompose(translation: _position, rotation: _rotationQuaternion, scale: _scale)
            _setDirtyFlagTrue(TransformFlag.LocalEuler.rawValue)
            _setDirtyFlagFalse(TransformFlag.LocalMatrix.rawValue)
            _updateAllWorldFlag()
        }
    }

    /// World matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldMatrix: Matrix {
        get {
            if (_isContainDirtyFlag(TransformFlag.WorldMatrix.rawValue)) {
                let parent = _getParentTransform()
                if (parent != nil) {
                    Matrix.multiply(left: parent!.worldMatrix, right: localMatrix, out: _worldMatrix)
                } else {
                    localMatrix.cloneTo(target: _worldMatrix)
                }
                _setDirtyFlagFalse(TransformFlag.WorldMatrix.rawValue)
            }
            return _worldMatrix
        }
        set {
            if (_worldMatrix !== newValue) {
                newValue.cloneTo(target: _worldMatrix)
            }
            let parent = _getParentTransform()
            if (parent != nil) {
                Matrix.invert(a: parent!.worldMatrix, out: Transform._tempMat42)
                Matrix.multiply(left: newValue, right: Transform._tempMat42, out: _localMatrix)
            } else {
                newValue.cloneTo(target: _localMatrix)
            }
            localMatrix = _localMatrix
            _setDirtyFlagFalse(TransformFlag.WorldMatrix.rawValue)
        }
    }
}

//MARK:- Public Methods
extension Transform {
    /// Set local position by X, Y, Z value.
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    ///   - z: Z coordinate
    func setPosition(x: Float, y: Float, z: Float) {
        _ = _position.setValue(x: x, y: y, z: z)
        position = _position
    }

    /// Set local rotation by the X, Y, Z components of the euler angle, unit in degrees.
    /// Rotations are performed around the Y axis, the X axis, and the Z axis, in that order.
    /// - Parameters:
    ///   - x: The angle of rotation around the X axis
    ///   - y: The angle of rotation around the Y axis
    ///   - z: The angle of rotation around the Z axis
    func setRotation(x: Float, y: Float, z: Float) {
        _ = _rotation.setValue(x: x, y: y, z: z)
        rotation = _rotation
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
    ///   - y:  Scaling along Y axis
    ///   - z: Scaling along Z axis
    func setScale(x: Float, y: Float, z: Float) {
        _ = _scale.setValue(x: x, y: y, z: z)
        scale = _scale
    }

    /// Set world position by X, Y, Z value.
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    ///   - z: Z coordinate
    func setWorldPosition(x: Float, y: Float, z: Float) {
        _ = _worldPosition.setValue(x: x, y: y, z: z)
        worldPosition = _worldPosition
    }

    /// Set world rotation by the X, Y, Z components of the euler angle, unit in degrees, Yaw/Pitch/Roll sequence.
    /// - Parameters:
    ///   - x: The angle of rotation around the X axis
    ///   - y: The angle of rotation around the Y axis
    ///   - z: The angle of rotation around the Z axis
    func setWorldRotation(x: Float, y: Float, z: Float) {
        _ = _worldRotation.setValue(x: x, y: y, z: z)
        worldRotation = _worldRotation
    }

    /// Set local rotation by the X, Y, Z, and W components of the quaternion.
    /// - Parameters:
    ///   - x: X component of quaternion
    ///   - y: Y component of quaternion
    ///   - z: Z component of quaternion
    ///   - w: W component of quaternion
    func setWorldRotationQuaternion(x: Float, y: Float, z: Float, w: Float) {
        _ = _worldRotationQuaternion.setValue(x: x, y: y, z: z, w: w)
        worldRotationQuaternion = _worldRotationQuaternion
    }

    /// Get the forward direction in world space.
    /// - Parameter forward: Forward vector
    /// - Returns: Forward vector
    func getWorldForward(forward: Vector3) -> Vector3 {
        let e = worldMatrix.elements
        _ = forward.setValue(x: -e.columns.2[0], y: -e.columns.2[1], z: -e.columns.2[2])
        return forward.normalize()
    }

    /// Get the right direction in world space.
    /// - Parameter right: Right vector
    /// - Returns: Right vector
    func getWorldRight(right: Vector3) -> Vector3 {
        let e = worldMatrix.elements
        _ = right.setValue(x: e.columns.0[0], y: e.columns.0[1], z: e.columns.0[2])
        return right.normalize()
    }

    /// Get the up direction in world space.
    /// - Parameter up: Up vector
    /// - Returns: Up vector
    func getWorldUp(up: Vector3) -> Vector3 {
        let e = worldMatrix.elements
        _ = up.setValue(x: e.columns.1[0], y: e.columns.1[1], z: e.columns.1[2])
        return up.normalize()
    }

    /// Translate along the passed Vector3.
    /// - Parameters:
    ///   - translation: Direction and distance of translation
    ///   - relativeToLocal: Relative to local space
    func translate(_ translation: Vector3, _ relativeToLocal: Bool?) {
        _translate(translation, relativeToLocal ?? true)
    }

    /// Translate along the passed X, Y, Z value.
    /// - Parameters:
    ///   - x: Translate direction and distance along x axis
    ///   - y: Translate direction and distance along y axis
    ///   - z: Translate direction and distance along z axis
    ///   - relativeToLocal: Relative to local space
    func translate(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool?) {
        let translate = Transform._tempVec3
        _ = translate.setValue(x: x, y: y, z: z)
        _translate(translate, relativeToLocal ?? true)
    }

    /// Rotate around the passed Vector3.
    /// - Parameters:
    ///   - rotation: Euler angle in degrees
    ///   - relativeToLocal: Relative to local space
    func rotate(_ rotation: Vector3, _ relativeToLocal: Bool?) {
        _rotateXYZ(rotation.x, rotation.y, rotation.z, relativeToLocal ?? true)
    }

    /// Rotate around the passed Vector3.
    /// - Parameters:
    ///   - x: Rotation along x axis, in degrees
    ///   - y: Rotation along y axis, in degrees
    ///   - z: Rotation along z axis, in degrees
    ///   - relativeToLocal: Relative to local space
    func rotate(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool?) {
        _rotateXYZ(x, y, z, relativeToLocal ?? true)
    }

    /// Rotate around the specified axis according to the specified angle.
    /// - Parameters:
    ///   - axis: Rotate axis
    ///   - angle: Rotate angle in degrees
    ///   - relativeToLocal: Relative to local space
    func rotateByAxis(axis: Vector3, angle: Float, relativeToLocal: Bool = true) {
        let rad = angle * MathUtil.degreeToRadFactor
        Quaternion.rotationAxisAngle(axis: axis, rad: rad, out: Transform._tempQuat0)
        _rotateByQuat(Transform._tempQuat0, relativeToLocal)
    }

    /// Rotate and ensure that the world front vector points to the target world position.
    /// - Parameters:
    ///   - worldPosition: Target world position
    ///   - worldUp: Up direction in world space, default is Vector3(0, 1, 0)
    func lookAt(worldPosition: Vector3, worldUp: Vector3?) {
        let position = worldPosition
        let EPSILON = Float.leastNonzeroMagnitude
        if (
                   abs(position.x - worldPosition.x) < EPSILON &&
                           abs(position.y - worldPosition.y) < EPSILON &&
                           abs(position.z - worldPosition.z) < EPSILON
           ) {
            return
        }
        let rotMat = Transform._tempMat43
        let worldRotationQuaternion = _worldRotationQuaternion

        let worldUp = worldUp ?? Transform._tempVec3.setValue(x: 0, y: 1, z: 0)
        Matrix.lookAt(eye: position, target: worldPosition, up: worldUp, out: rotMat)
        _ = rotMat.getRotation(out: worldRotationQuaternion).invert()
        self.worldRotationQuaternion = worldRotationQuaternion
    }

    /// Register world transform change flag.
    /// - Returns: Change flag
    func registerWorldChangeFlag() -> UpdateFlag {
        return _updateFlagManager.register()
    }
}

//MARK:- Private Methods
extension Transform {
    internal func _parentChange() {
        _isParentDirty = true
        _updateAllWorldFlag()
    }


    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldPositionFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWp.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWp.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateWorldPositionFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldRotationQuaternion: Will trigger the world rotation (in quaternion) update of itself and all parent entities.
    /// Get worldRotation: Will trigger the world rotation(in euler and quaternion) update of itself and world rotation(in quaternion) update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldRotationFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWeWq.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWeWq.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateWorldPositionAndRotationFlag() // Rotation update of parent entity will trigger world position and rotation update of all child entity.
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldRotationQuaternion: Will trigger the world rotation (in quaternion) update of itself and all parent entities.
    /// Get worldRotation: Will trigger the world rotation(in euler and quaternion) update of itself and world rotation(in quaternion) update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldPositionAndRotationFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWpWeWq.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWpWeWq.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateWorldPositionAndRotationFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldScale: Will trigger the scaling update of itself and all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix) to be false.
    private func _updateWorldScaleFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWs.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateWorldPositionAndScaleFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldScale: Will trigger the scaling update of itself and all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix) to be false.
    private func _updateWorldPositionAndScaleFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWpWs.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWpWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateWorldPositionAndScaleFlag()
            }
        }
    }

    /// Update all world transform property dirty flag, the principle is the same as above.
    private func _updateAllWorldFlag() {
        if (!_isContainDirtyFlags(TransformFlag.WmWpWeWqWs.rawValue)) {
            _worldAssociatedChange(TransformFlag.WmWpWeWqWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0..<nodeChildren.count {
                nodeChildren[i].transform?._updateAllWorldFlag()
            }
        }
    }

    private func _getParentTransform() -> Transform? {
        if (!_isParentDirty) {
            return _parentTransformCache
        }
        var parentCache: Transform? = nil
        var parent = _entity.parent
        while (parent != nil) {
            let transform = parent!.transform
            if (transform != nil) {
                parentCache = transform
                break
            } else {
                parent = parent!.parent
            }
        }
        _parentTransformCache = parentCache
        _isParentDirty = false
        return parentCache
    }

    private func _getScaleMatrix() -> Matrix3x3 {
        let invRotation = Transform._tempQuat0
        let invRotationMat = Transform._tempMat30
        let worldRotScaMat = Transform._tempMat31
        let scaMat = Transform._tempMat32
        _ = worldRotScaMat.setValueByMatrix(a: worldMatrix)
        Quaternion.invert(a: worldRotationQuaternion, out: invRotation)
        Matrix3x3.rotationQuaternion(quaternion: invRotation, out: invRotationMat)
        Matrix3x3.multiply(left: invRotationMat, right: worldRotScaMat, out: scaMat)
        return scaMat
    }

    private func _isContainDirtyFlags(_ targetDirtyFlags: Int) -> Bool {
        return (_dirtyFlag & targetDirtyFlags) == targetDirtyFlags
    }

    private func _isContainDirtyFlag(_ type: Int) -> Bool {
        return (_dirtyFlag & type) != 0
    }

    private func _setDirtyFlagTrue(_ type: Int) {
        _dirtyFlag |= type
    }

    private func _setDirtyFlagFalse(_ type: Int) {
        _dirtyFlag &= ~type
    }

    private func _worldAssociatedChange(_ type: Int) {
        _dirtyFlag |= type
        _updateFlagManager.distribute()
    }

    private func _rotateByQuat(_ rotateQuat: Quaternion, _ relativeToLocal: Bool) {
        if (relativeToLocal) {
            Quaternion.multiply(left: rotationQuaternion, right: rotateQuat, out: _rotationQuaternion)
            rotationQuaternion = _rotationQuaternion
        } else {
            Quaternion.multiply(left: worldRotationQuaternion, right: rotateQuat, out: _worldRotationQuaternion)
            worldRotationQuaternion = _worldRotationQuaternion
        }
    }

    private func _translate(_ translation: Vector3, _ relativeToLocal: Bool = true) {
        if (relativeToLocal) {
            position = _position.add(right: translation)
        } else {
            worldPosition = _worldPosition.add(right: translation)
        }
    }

    private func _rotateXYZ(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool = true) {
        let radFactor = MathUtil.degreeToRadFactor
        let rotQuat = Transform._tempQuat0
        Quaternion.rotationEuler(x: x * radFactor, y: y * radFactor, z: z * radFactor, out: rotQuat)
        _rotateByQuat(rotQuat, relativeToLocal)
    }
}

//MARK:- Dirty flag of transform.
enum TransformFlag: Int {
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
