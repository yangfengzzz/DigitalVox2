//
//  Keyframe.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Keyframe.
/// @typeParam V - Type of Keyframe value
class Keyframe<V> {
    /// The time of the Keyframe.
    var time: Float = 0
    /// The value of the Keyframe.
    var value: V?
}

/// InterpolableKeyframe.
/// @typeParam T - Type of Tangent value
/// @typeParam V - Type of Keyframe value
class InterpolableKeyframe<T, V>: Keyframe<V> {
    /// Sets the incoming tangent for this key. The incoming tangent affects the slope of the curve from the previous key to this key.
    var inTangent: T?
    /// Sets the outgoing tangent for this key. The outgoing tangent affects the slope of the curve from this key to the next key.
    var outTangent: T?
}

typealias ObjectKeyframe = Keyframe<AnyObject>
typealias FloatKeyframe = InterpolableKeyframe<Float, Float>
typealias FloatArrayKeyframe = InterpolableKeyframe<[Float], [Float]>
typealias Vector2Keyframe = InterpolableKeyframe<Vector2, Vector2>
typealias Vector3Keyframe = InterpolableKeyframe<Vector3, Vector3>
typealias Vector4Keyframe = InterpolableKeyframe<Vector4, Vector4>
typealias QuaternionKeyframe = InterpolableKeyframe<Vector4, Quaternion>

enum UnionInterpolableKeyframe {
    case FloatKeyframe(FloatKeyframe)
    case FloatArrayKeyframe(FloatArrayKeyframe)
    case Vector2Keyframe(Vector2Keyframe)
    case Vector3Keyframe(Vector3Keyframe)
    case Vector4Keyframe(Vector4Keyframe)
    case QuaternionKeyframe(QuaternionKeyframe)
}

enum InterpolableValue {
    case Float(Float)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
    case Quaternion(Quaternion)
    case Float32Array([Float])
    case Object(AnyObject)
}
