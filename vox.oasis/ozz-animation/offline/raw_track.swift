//
//  raw_track.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Definition of operations policies per track value type.
protocol TrackPolicy {
    associatedtype _ValueType
    static func Lerp(_ _a: _ValueType, _ _b: _ValueType, _ _alpha: Float) -> _ValueType
    static func Distance(_ _a: _ValueType, _ _b: _ValueType) -> Float
    static func identity() -> _ValueType
}

// Interpolation mode.
struct RawTrackInterpolation {
    enum Value {
        case kStep    // All values following this key, up to the next key, are equal.
        case kLinear  // All value between this key and the next are linearly
        // interpolated.
    }
}

struct RawTrackKeyframe<ValueType: TrackPolicy> {
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
internal struct RawTrack<ValueType: TrackPolicy> {
    typealias Keyframe = RawTrackKeyframe<ValueType>
    typealias Keyframes = [Keyframe]

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

extension Float: TrackPolicy {
    typealias _ValueType = Float

    static func Lerp(_ _a: Float, _ _b: Float, _ _alpha: Float) -> Float {
        (_b - _a) * _alpha + _a
    }

    static func Distance(_ _a: Float, _ _b: Float) -> Float {
        abs(_a - _b)
    }

    static func identity() -> Float {
        0.0
    }
}

extension VecFloat2: TrackPolicy {
    typealias _ValueType = VecFloat2

    static func Lerp(_ _a: VecFloat2, _ _b: VecFloat2, _ _alpha: Float) -> VecFloat2 {
        VecFloat2((_b.x - _a.x) * _alpha + _a.x, (_b.y - _a.y) * _alpha + _a.y)
    }

    static func Distance(_ _a: VecFloat2, _ _b: VecFloat2) -> Float {
        Length(_a - _b)
    }

    static func identity() -> VecFloat2 {
        VecFloat2(0)
    }
}

extension VecFloat3: TrackPolicy {
    typealias _ValueType = VecFloat3

    static func Lerp(_ _a: VecFloat3, _ _b: VecFloat3, _ _alpha: Float) -> VecFloat3 {
        VecFloat3((_b.x - _a.x) * _alpha + _a.x, (_b.y - _a.y) * _alpha + _a.y,
                (_b.z - _a.z) * _alpha + _a.z)
    }

    static func Distance(_ _a: VecFloat3, _ _b: VecFloat3) -> Float {
        Length(_a - _b)
    }

    static func identity() -> VecFloat3 {
        VecFloat3(0)
    }
}

extension VecFloat4: TrackPolicy {
    typealias _ValueType = VecFloat4

    static func Lerp(_ _a: VecFloat4, _ _b: VecFloat4, _ _alpha: Float) -> VecFloat4 {
        VecFloat4((_b.x - _a.x) * _alpha + _a.x, (_b.y - _a.y) * _alpha + _a.y,
                (_b.z - _a.z) * _alpha + _a.z, (_b.w - _a.w) * _alpha + _a.w)
    }

    static func Distance(_ _a: VecFloat4, _ _b: VecFloat4) -> Float {
        Length(_a - _b)
    }

    static func identity() -> VecFloat4 {
        VecFloat4(0)
    }
}

extension VecQuaternion: TrackPolicy {
    static func Lerp(_ _a: VecQuaternion, _ _b: VecQuaternion, _ _alpha: Float) -> VecQuaternion {
        // Uses NLerp to favor speed. This same function is used when optimizing the
        // curve (key frame reduction), so "constant speed" interpolation can still be
        // approximated with a lower tolerance value if it matters.
        NLerp(_a, _b, _alpha)
    }

    static func Distance(_ _a: VecQuaternion, _ _b: VecQuaternion) -> Float {
        let cos_half_angle = _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w
        // Return value is 1 - half cosine, so the closer the quaternions, the closer
        // to 0.
        return 1.0 - min(1.0, abs(cos_half_angle))
    }
}
