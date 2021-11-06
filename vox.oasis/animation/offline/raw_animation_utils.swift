//
//  raw_animation_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

//MARK: - Lerp Methods
// Translation interpolation method.
func lerpTranslation(_ _a: VecFloat3, _ _b: VecFloat3, _ _alpha: Float) -> VecFloat3 {
    lerp(_a, _b, _alpha)
}

// Rotation interpolation method.
func lerpRotation(_ _a: VecQuaternion, _ _b: VecQuaternion, _ _alpha: Float) -> VecQuaternion {
    // Finds the shortest path. This is done by the AnimationBuilder for runtime
    // animations.
    let dot = _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
    return nlerp(_a, dot < 0.0 ? -_b : _b, _alpha)  // _b an -_b are the same rotation.
}

// Scale interpolation method.
func lerpScale(_ _a: VecFloat3, _ _b: VecFloat3, _ _alpha: Float) -> VecFloat3 {
    lerp(_a, _b, _alpha)
}

//MARK: - Sample Methods
// Samples a component (translation, rotation or scale) of a track.
func sampleComponent<T, _Key: KeyType>(_ _track: [_Key],
                                       _ _lerp: (T, T, Float) -> T,
                                       _ _time: Float) -> T where T == _Key.T {
    if (_track.count == 0) {
        // Return identity if there's no key for this track.
        return _Key.identity()
    } else if (_time <= _track.first!.time) {
        // Returns the first keyframe if _time is before the first keyframe.
        return _track.first!.value
    } else if (_time >= _track.last!.time) {
        // Returns the last keyframe if _time is before the last keyframe.
        return _track.last!.value
    } else {
        // Needs to interpolate the 2 keyframes before and after _time.
        assert(_track.count >= 2)
        // First find the 2 keys.
        let it = _track.firstIndex { ele in
            return ele.time >= _time
        }
        assert(it != nil)

        // Then interpolate them at t = _time.
        let right = _track[it!]
        let left = _track[it! - 1]
        let alpha = (_time - left.time) / (right.time - left.time)
        return _lerp(left.value, right.value, alpha)
    }
}

func sampleTrack_NoValidate(_ _track: RawAnimation.JointTrack, _ _time: Float,
                            _ _transform: inout VecTransform) {
    _transform.translation = sampleComponent(_track.translations, lerpTranslation, _time)
    _transform.rotation = sampleComponent(_track.rotations, lerpRotation, _time)
    _transform.scale = sampleComponent(_track.scales, lerpScale, _time)
}

// Samples a RawAnimation track. This function shall be used for offline
// purpose. Use ozz::animation::Animation and ozz::animation::SamplingJob for
// runtime purpose.
// Returns false if track is invalid.
func sampleTrack(_ _track: RawAnimation.JointTrack, _ _time: Float,
                 _ _transform: inout VecTransform) -> Bool {
    if (!_track.validate(Float.greatestFiniteMagnitude)) {
        return false
    }

    sampleTrack_NoValidate(_track, _time, &_transform)
    return true
}

// Samples a RawAnimation. This function shall be used for offline
// purpose. Use ozz::animation::Animation and ozz::animation::SamplingJob for
// runtime purpose.
// _animation must be valid.
// Returns false output range is too small or animation is invalid.
func sampleAnimation(_ _animation: RawAnimation, _ _time: Float, _ _transforms: inout ArraySlice<VecTransform>) -> Bool {
    if (!_animation.validate()) {
        return false
    }
    if (_animation.tracks.count > _transforms.count) {
        return false
    }

    for i in 0..<_animation.tracks.count {
        sampleTrack_NoValidate(_animation.tracks[i], _time, &_transforms[i])
    }
    return true
}

// Implement fixed rate keyframe time iteration. This utility purpose is to
// ensure that sampling goes strictly from 0 to duration, and that period
// between consecutive time samples have a fixed period.
// This sounds trivial, but floating point error could occur if keyframe time
// was accumulated for a long duration.
class FixedRateSamplingTime {
    init(_ _duration: Float, _ _frequency: Float) {
        duration_ = _duration
        period_ = 1.0 / _frequency
        num_keys_ = Int(ceil(1.0 + _duration * _frequency))
    }

    func time(_ _key: Int) -> Float {
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
