//
//  track.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Runtime user-channel track internal implementation.
// The runtime track data structure exists for 1 to 4 float types (FloatTrack,
// ..., Float4Track) and quaternions (QuaternionTrack). See RawTrack for more
// details on track content. The runtime track data structure is optimized for
// the processing of ozz::animation::TrackSamplingJob and
// ozz::animation::TrackTriggeringJob. Keyframe ratios, values and interpolation
// mode are all store as separate buffers in order to access the cache
// coherently. Ratios are usually accessed/read alone from the jobs that all
// start by looking up the keyframes to interpolate indeed.
class Track<ValueType: TrackPolicy> {
    // Keyframe accessors.
    func ratios() -> ArraySlice<Float> {
        ratios_
    }

    func values() -> ArraySlice<ValueType> {
        values_
    }

    func steps() -> ArraySlice<UInt8> {
        steps_
    }

    // Get track name.
    func name() -> String {
        name_
    }

    // Internal destruction function.
    internal func Allocate(_keys_count: Int) {
        assert(ratios_.count == 0 && values_.count == 0)

        // Fix up pointers. Serves larger alignment values first.
        values_ = [ValueType](repeating: ValueType.identity() as! ValueType, count: _keys_count)[...]
        ratios_ = [Float](repeating: 0, count: _keys_count)[...]
        steps_ = [UInt8](repeating: 0, count: (_keys_count + 7) / 8)[...]
    }

    // Keyframe ratios (0 is the beginning of the track, 1 is the end).
    internal var ratios_: ArraySlice<Float> = ArraySlice()

    // Keyframe values.
    internal var values_: ArraySlice<ValueType> = ArraySlice()

    // Keyframe modes (1 bit per key): 1 for step, 0 for linear.
    internal var steps_: ArraySlice<UInt8> = ArraySlice()

    // Track name.
    internal var name_: String = ""
}

// Runtime track data structure instantiation.
typealias FloatTrack = Track<Float>
typealias Float2Track = Track<VecFloat2>
typealias Float3Track = Track<VecFloat3>
typealias Float4Track = Track<VecFloat4>
typealias QuaternionTrack = Track<VecQuaternion>
