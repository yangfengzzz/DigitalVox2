//
//  track_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible of building runtime track instances from
// offline tracks.The input raw track is first validated. Runtime conversion of
// a validated raw track cannot fail. Note that no optimization is performed on
// the data at all.
class TrackBuilder {
    // Creates a Track based on _raw_track and *this builder parameters.
    // Returns a track instance on success, an empty unique_ptr on failure. See
    // Raw*Track::Validate() for more details about failure reasons.
    // The track is returned as an unique_ptr as ownership is given back to the
    // caller.
    func eval(_ _input: RawFloatTrack) -> FloatTrack {
        Build(_input)
    }

    func eval(_input: RawFloat2Track) -> Float2Track {
        Build(_input)
    }

    func eval(_input: RawFloat3Track) -> Float3Track {
        Build(_input)
    }

    func eval(_input: RawFloat4Track) -> Float4Track {
        Build(_input)
    }

    func eval(_input: RawQuaternionTrack) -> QuaternionTrack {
        Build(_input)
    }

    func Build<ValueType: TrackPolicy>(_ _input: RawTrack<ValueType>)
    -> Track<ValueType> where ValueType._ValueType == ValueType {
        
        // Tests _raw_animation validity.
        if (!_input.Validate()) {
            return Track()
        }

        // Everything is fine, allocates and fills the animation.
        // Nothing can fail now.
        let track: Track<ValueType> = Track()

        // Copy data to temporary prepared data structure
        var keyframes: [RawTrackKeyframe<ValueType>] = []
        // Guessing a worst size to avoid realloc.
        let worst_size =
                _input.keyframes.count * 2 + // * 2 in case all keys are kStep
                        2                             // + 2 for first and last keys
        keyframes.reserveCapacity(worst_size)

        // Ensure there's a key frame at the start and end of the track (required for
        // sampling).
        PatchBeginEndKeys(_input, &keyframes)

        // Fixup values, ex: successive opposite quaternions that would fail to take
        // the shortest path during the normalized-lerp.
        ValueType.Fixup(&keyframes)

        // Allocates output track.
        track.Allocate(keyframes.count)

        // Copy all keys to output.
        assert(keyframes.count == track.ratios_.count &&
                keyframes.count == track.values_.count &&
                keyframes.count <= track.steps_.count * 8)

        for i in 0..<keyframes.count {
            let src_key = keyframes[i]
            track.ratios_[i] = src_key.ratio
            track.values_[i] = src_key.value
            track.steps_[i / 8] |= UInt8(src_key.interpolation == RawTrackInterpolation.Value.kStep ? 1 : 0) << (i & 7)
        }

        // Copy track's name.
        track.name_ = _input.name
        return track  // Success.
    }
}

func PatchBeginEndKeys<ValueType: TrackPolicy>(_ _input: RawTrack<ValueType>,
                                               _ keyframes: inout [RawTrackKeyframe<ValueType>])
where ValueType._ValueType == ValueType {

    if _input.keyframes.isEmpty {
        let default_value = ValueType.identity()

        let begin = RawTrackKeyframe<ValueType>(
                interpolation: RawTrackInterpolation.Value.kLinear,
                ratio: 0.0,
                value: default_value
        )
        keyframes.append(begin)
        let end = RawTrackKeyframe<ValueType>(
                interpolation: RawTrackInterpolation.Value.kLinear,
                ratio: 1.0,
                value: default_value
        )
        keyframes.append(end)
    } else if _input.keyframes.count == 1 {
        let src_key = _input.keyframes.first!
        let begin = RawTrackKeyframe<ValueType>(
                interpolation: RawTrackInterpolation.Value.kLinear,
                ratio: 0.0,
                value: src_key.value
        )
        keyframes.append(begin)
        let end = RawTrackKeyframe<ValueType>(
                interpolation: RawTrackInterpolation.Value.kLinear,
                ratio: 1.0,
                value: src_key.value
        )
        keyframes.append(end)
    } else {
        // Copy all source data.
        // Push an initial and last keys if they don't exist.
        if (_input.keyframes.first!.ratio != 0.0) {
            let src_key = _input.keyframes.first!
            let begin = RawTrackKeyframe<ValueType>(
                    interpolation: RawTrackInterpolation.Value.kLinear, ratio: 0.0, value: src_key.value)
            keyframes.append(begin)
        }
        for i in 0..<_input.keyframes.count {
            keyframes.append(_input.keyframes[i])
        }
        if (_input.keyframes.last!.ratio != 1.0) {
            let src_key = _input.keyframes.last!
            let end = RawTrackKeyframe<ValueType>(interpolation: RawTrackInterpolation.Value.kLinear,
                    ratio: 1.0, value: src_key.value)
            keyframes.append(end)
        }
    }
}
