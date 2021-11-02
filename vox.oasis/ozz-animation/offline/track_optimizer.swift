//
//  track_optimizer.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// TrackOptimizer is responsible for optimizing an offline raw track instance.
// Optimization is a keyframe reduction process. Redundant and interpolable
// keyframes (within a tolerance value) are removed from the track. Default
// optimization tolerances are set in order to favor quality over runtime
// performances and memory footprint.
class TrackOptimizer {
    // Optimizes _input using *this parameters.
    // Returns true on success and fills _output track with the optimized
    // version of _input track.
    // *_output must be a valid Raw*Track instance.
    // Returns false on failure and resets _output to an empty track.
    // See Raw*Track::Validate() for more details about failure reasons.
    func eval(_ _input: RawFloatTrack, _ _output: inout RawFloatTrack) -> Bool {
        Optimize(tolerance, _input, &_output)
    }

    func eval(_ _input: RawFloat2Track, _ _output: inout RawFloat2Track) -> Bool {
        Optimize(tolerance, _input, &_output)
    }

    func eval(_ _input: RawFloat3Track, _ _output: inout RawFloat3Track) -> Bool {
        Optimize(tolerance, _input, &_output)
    }

    func eval(_ _input: RawFloat4Track, _ _output: inout RawFloat4Track) -> Bool {
        Optimize(tolerance, _input, &_output)
    }

    func eval(_ _input: RawQuaternionTrack, _ _output: inout RawQuaternionTrack) -> Bool {
        Optimize(tolerance, _input, &_output)
    }

    // Optimization tolerance.
    var tolerance: Float = 1.0e-3
}

struct Adapter<ValueType: TrackPolicy>: DecimateType where ValueType._ValueType == ValueType {
    func Decimable(_ _key: RawTrackKeyframe<ValueType>) -> Bool {
        // RawTrackInterpolation::kStep keyframes aren't optimized, as steps can't
        // be interpolated.
        _key.interpolation != RawTrackInterpolation.Value.kStep
    }

    func Lerp(_ _left: RawTrackKeyframe<ValueType>,
              _ _right: RawTrackKeyframe<ValueType>,
              _ _ref: RawTrackKeyframe<ValueType>) -> RawTrackKeyframe<ValueType> {
        assert(Decimable(_ref))
        let alpha = (_ref.ratio - _left.ratio) / (_right.ratio - _left.ratio)
        assert(alpha >= 0.0 && alpha <= 1.0)
        return RawTrackKeyframe<ValueType>(interpolation: _ref.interpolation, ratio: _ref.ratio,
                value: ValueType.Lerp(_left.value, _right.value, alpha))
    }

    func Distance(_ _a: RawTrackKeyframe<ValueType>,
                  _ _b: RawTrackKeyframe<ValueType>) -> Float {
        ValueType.Distance(_a.value, _b.value)
    }
}

func Optimize<ValueType: TrackPolicy>(_ _tolerance: Float, _ _input: RawTrack<ValueType>,
                                      _ _output: inout RawTrack<ValueType>) -> Bool where ValueType._ValueType == ValueType {
    // Reset output animation to default.
    _output = RawTrack()

    // Validate animation.
    if (!_input.Validate()) {
        return false
    }

    // Copy name
    _output.name = _input.name

    // Optimizes.
    let adapter: Adapter<ValueType> = Adapter()
    Decimate(_input.keyframes, adapter, _tolerance, &_output.keyframes)

    // Output animation is always valid though.
    return _output.Validate()
}
