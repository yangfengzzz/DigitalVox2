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

/// Dirty flag of transform.
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
