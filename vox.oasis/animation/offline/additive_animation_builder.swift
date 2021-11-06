//
//  additive_animation_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible for building a delta animation from an offline
// raw animation. This is used to create animations compatible with additive
// blending.
class AdditiveAnimationBuilder {
    // Builds delta animation from _input..
    // Returns true on success and fills _output_animation with the delta
    // version of _input animation.
    // *_output must be a valid RawAnimation instance. Uses first frame as
    // reference pose Returns false on failure and resets _output to an empty
    // animation. See RawAnimation::Validate() for more details about failure
    // reasons.
    func eval(_ _input: RawAnimation, _ _output: inout RawAnimation) -> Bool {
        // Reset output animation to default.
        _output = RawAnimation()

        // Validate animation.
        if (!_input.validate()) {
            return false
        }

        // Rebuilds output animation.
        _output.duration = _input.duration
        _output.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: _input.tracks.count)

        for i in 0..<_input.tracks.count {
            let track_in = _input.tracks[i]

            let translations = track_in.translations
            let ref_translation = translations.count > 0 ? translations[0].value : VecFloat3.zero()

            let rotations = track_in.rotations
            let ref_rotation = rotations.count > 0 ? rotations[0].value : VecQuaternion.identity()

            let scales = track_in.scales
            let ref_scale = scales.count > 0 ? scales[0].value : VecFloat3.one()

            makeDelta(translations, ref_translation, makeDeltaTranslation, &_output.tracks[i].translations)
            makeDelta(rotations, ref_rotation, makeDeltaRotation, &_output.tracks[i].rotations)
            makeDelta(scales, ref_scale, makeDeltaScale, &_output.tracks[i].scales)
        }

        // Output animation is always valid though.
        return _output.validate()
    }

    // Builds delta animation from _input..
    // Returns true on success and fills _output_animation with the delta
    // *_output must be a valid RawAnimation instance.
    // version of _input animation.
    // *_reference_pose used as the base pose to calculate deltas from
    // Returns false on failure and resets _output to an empty animation.
    func eval(_ _input: RawAnimation, _ _reference_pose: ArraySlice<VecTransform>, _ _output: inout RawAnimation) -> Bool {
        // Reset output animation to default.
        _output = RawAnimation()

        // Validate animation.
        if (!_input.validate()) {
            return false
        }

        // The reference pose must have at least the same number of
        // tracks as the raw animation.
        if (_input.num_tracks() > _reference_pose.count) {
            return false
        }

        // Rebuilds output animation.
        _output.duration = _input.duration
        _output.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: _input.tracks.count)

        for i in 0..<_input.tracks.count {
            makeDelta(_input.tracks[i].translations, _reference_pose[i].translation, makeDeltaTranslation, &_output.tracks[i].translations)
            makeDelta(_input.tracks[i].rotations, _reference_pose[i].rotation, makeDeltaRotation, &_output.tracks[i].rotations)
            makeDelta(_input.tracks[i].scales, _reference_pose[i].scale, makeDeltaScale, &_output.tracks[i].scales)
        }

        // Output animation is always valid though.
        return _output.validate()
    }
}

fileprivate func makeDeltaTranslation(_ _reference: VecFloat3, _ _value: VecFloat3) -> VecFloat3 {
    _value - _reference
}

fileprivate func makeDeltaRotation(_ _reference: VecQuaternion, _ _value: VecQuaternion) -> VecQuaternion {
    _value * conjugate(_reference)
}

fileprivate func makeDeltaScale(_ _reference: VecFloat3, _ _value: VecFloat3) -> VecFloat3 {
    _value / _reference
}

fileprivate func makeDelta<T, _RawTrack: KeyType>(_ _src: [_RawTrack], _ reference: T,
                                                  _ _make_delta: (T, T) -> T,
                                                  _ _dest: inout [_RawTrack]) where _RawTrack.T == T {
    _dest.reserveCapacity(_src.count)

    // Early out if no key.
    if (_src.isEmpty) {
        return
    }

    // Copy animation keys.
    for i in 0..<_src.count {
        let delta = _RawTrack(_src[i].time, _make_delta(reference, _src[i].value))
        _dest.append(delta)
    }
}
