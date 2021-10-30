//
//  Animator.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// The controller of the animation system.
class Animator: Component {
    private static var _tempVector3: Vector3 = Vector3()
    private static var _tempQuaternion: Quaternion = Quaternion()
    private static var _animatorInfo: AnimatorStateInfo = AnimatorStateInfo()

    var _animatorController: AnimatorController!
    // @assignmentClone
    var _speed: Float = 1.0
    // @ignoreClone
    var _controllerUpdateFlag: UpdateFlag!

    // ignoreClone
    private var _animatorLayersData: [AnimatorLayerData] = []
    // @ignoreClone
    private var _crossCurveDataCollection: [CrossCurveData] = []
    // @ignoreClone
    private var _animationCurveOwners: [[AnimationCurveOwner]] = []
    // @ignoreClone
    private var _crossCurveDataPool: ClassPool<CrossCurveData> = ClassPool()
    // @ignoreClone
    private var _animationEventHandlerPool: ClassPool<AnimationEventHandler> = ClassPool()
}
