//
//  raw_animation_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Translation interpolation method.
func LerpTranslation(_a: VecFloat3, _b: VecFloat3, _alpha: Float) -> VecFloat3 {
    fatalError()
}

// Rotation interpolation method.
func LerpRotation(_a: VecQuaternion, _b: VecQuaternion, _alpha: Float) -> VecQuaternion {
    fatalError()
}

// Scale interpolation method.
func LerpScale(_a: VecFloat3, _b: VecFloat3, _alpha: Float) -> VecFloat3 {
    fatalError()
}

// Samples a RawAnimation track. This function shall be used for offline
// purpose. Use ozz::animation::Animation and ozz::animation::SamplingJob for
// runtime purpose.
// Returns false if track is invalid.
func SampleTrack(_track: RawAnimation.JointTrack, _time: Float,
                 _transform: inout Transform) -> Bool {
    fatalError()
}

// Samples a RawAnimation. This function shall be used for offline
// purpose. Use ozz::animation::Animation and ozz::animation::SamplingJob for
// runtime purpose.
// _animation must be valid.
// Returns false output range is too small or animation is invalid.
func SampleAnimation(_animation: RawAnimation, _time: Float, _transforms: ArraySlice<Transform>) -> Bool {
    fatalError()
}

// Implement fixed rate keyframe time iteration. This utility purpose is to
// ensure that sampling goes strictly from 0 to duration, and that period
// between consecutive time samples have a fixed period.
// This sounds trivial, but floating point error could occur if keyframe time
// was accumulated for a long duration.
class FixedRateSamplingTime {
    init(_ _duration: Float, _ _frequency: Float) {
        fatalError()
    }

    func time(_key: Int) -> Float {
        assert(_key < num_keys_)
        return min(Float(_key) * period_, duration_)
    }

    func num_keys() -> Int {
        num_keys_
    }

    private var duration_: Float
    private var period_: Float
    private var num_keys_: Int
}
