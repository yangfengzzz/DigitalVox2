//
//  AnimationClipCurveBinding.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Associate AnimationCurve and the Entity
class AnimationClipCurveBinding {
    /// Path to the entity this curve applies to. The relativePath is formatted similar to a pathname,
    /// * e.g. "root/spine/leftArm". If relativePath is empty it refers to the entity the animation clip is attached to.
    var relativePath: String!
    /// The name or path to the property being animated.
    var property: AnimationProperty!
    /// The class type of the component that is animated.
    var type: Component.Type!
    /// The animation curve.
    var curve: AnimationCurve!
}
