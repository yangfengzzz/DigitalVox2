//
//  raw_track.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Interpolation mode.
struct RawTrackInterpolation {
    enum Value {
        case kStep    // All values following this key, up to the next key, are equal.
        case kLinear  // All value between this key and the next are linearly
        // interpolated.
    }
}

struct RawTrackKeyframe<ValueType> {
    var interpolation: RawTrackInterpolation.Value
    var ratio: Float
    var value: ValueType
}

// Offline user-channel animation track type implementation.
// This offline track data structure is meant to be used for user-channel
// tracks, aka animation of variables that aren't joint transformation. It is
// available for tracks of 1 to 4 floats (RawFloatTrack, RawFloat2Track, ...,
// RawFloat4Track) and quaternions (RawQuaternionTrack). Quaternions differ from
// float4 because of the specific interpolation and comparison treatment they
// require. As all other Raw data types, they are not intended to be used in run
// time. They are used to define the offline track object that can be converted
// to the runtime one using the a ozz::animation::offline::TrackBuilder. This
// animation structure exposes a single sequence of keyframes. Keyframes are
// defined with a ratio, a value and an interpolation mode:
// - Ratio: A track has no duration, so it uses ratios between 0 (beginning of
// the track) and 1 (the end), instead of times. This allows to avoid any
// discrepancy between the durations of tracks and the animation they match
// with.
// - Value: The animated value (float, ... float4, quaternion).
// - Interpolation mode (`ozz::animation::offline::RawTrackInterpolation`):
// Defines how value is interpolated with the next key. Track structure is then
// a sorted vector of keyframes. RawTrack structure exposes a Validate()
// function to check that all the following rules are respected:
// 1. Keyframes' ratios are sorted in a strict ascending order.
// 2. Keyframes' ratios are all within [0,1] range.
// RawTrack that would fail this validation will fail to be converted by
// the RawTrackBuilder.
internal struct RawTrack<ValueType> {
    // Validates that all the following rules are respected:
    //  1. Keyframes' ratios are sorted in a strict ascending order.
    //  2. Keyframes' ratios are all within [0,1] range.
    func Validate() -> Bool {
        fatalError()
    }

    // Sequence of keyframes, expected to be sorted.
    var keyframes: [RawTrackKeyframe<ValueType>]

    // Name of the track.
    var name: String
}

// Offline user-channel animation track type instantiation.
typealias RawFloatTrack = RawTrack<Float>
typealias RawFloat2Track = RawTrack<VecFloat2>
typealias RawFloat3Track = RawTrack<VecFloat3>
typealias RawFloat4Track = RawTrack<VecFloat4>
typealias RawQuaternionTrack = RawTrack<VecQuaternion>
