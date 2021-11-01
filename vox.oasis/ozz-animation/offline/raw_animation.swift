//
//  raw_animation.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

protocol KeyType {
    associatedtype T
    var time: Float { get set }
    var value: T { get set }

    init(_ time: Float, _ value: T)

    static func identity() -> T
}

// Offline animation type.
// This animation type is not intended to be used in run time. It is used to
// define the offline animation object that can be converted to the runtime
// animation using the AnimationBuilder.
// This animation structure exposes tracks of keyframes. Keyframes are defined
// with a time and a value which can either be a translation (3 float x, y, z),
// a rotation (a quaternion) or scale coefficient (3 floats x, y, z). Tracks are
// defined as a set of three different std::vectors (translation, rotation and
// scales). Animation structure is then a vector of tracks, along with a
// duration value.
// Finally the RawAnimation structure exposes Validate() function to check that
// it is valid, meaning that all the following rules are respected:
//  1. Animation duration is greater than 0.
//  2. Keyframes' time are sorted in a strict ascending order.
//  3. Keyframes' time are all within [0,animation duration] range.
// Animations that would fail this validation will fail to be converted by the
// AnimationBuilder.
struct RawAnimation {
    // Defines a raw translation key frame.
    struct TranslationKey: KeyType {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecFloat3

        init(_ time: Float, _ value: VecFloat3) {
            self.time = time
            self.value = value
        }

        // Provides identity transformation for a translation key.
        static func identity() -> VecFloat3 {
            VecFloat3.zero()
        }
    }

    // Defines a raw rotation key frame.
    struct RotationKey: KeyType {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecQuaternion

        init(_ time: Float, _ value: VecQuaternion) {
            self.time = time
            self.value = value
        }

        // Provides identity transformation for a rotation key.
        static func identity() -> VecQuaternion {
            VecQuaternion.identity()
        }
    }

    // Defines a raw scaling key frame.
    struct ScaleKey: KeyType {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecFloat3

        init(_ time: Float, _ value: VecFloat3) {
            self.time = time
            self.value = value
        }

        // Provides identity transformation for a scale key.
        static func identity() -> VecFloat3 {
            VecFloat3.one()
        }
    }

    // Defines a track of key frames for a bone, including translation, rotation
    // and scale.
    struct JointTrack {
        var translations: [TranslationKey]
        var rotations: [RotationKey]
        var scales: [ScaleKey]

        // Validates track. See RawAnimation::Validate for more details.
        // Use an infinite value for _duration if unknown. This will validate
        // keyframe orders, but not maximum duration.
        func Validate(_ _duration: Float) -> Bool {
            ValidateTrack(translations, _duration) &&
                    ValidateTrack(rotations, _duration) &&
                    ValidateTrack(scales, _duration)
        }
    }

    // Stores per joint JointTrack, ie: per joint animation key-frames.
    // tracks_.size() gives the number of animated joints.
    var tracks: [JointTrack]

    // The duration of the animation. All the keys of a valid RawAnimation are in
    // the range [0,duration].
    var duration: Float = 1.0

    // Name of the animation.
    var name: String

    // Returns the number of tracks of this animation.
    func num_tracks() -> Int {
        tracks.count
    }

    // Tests for *this validity.
    // Returns true if animation data (duration, tracks) is valid:
    //  1. Animation duration is greater than 0.
    //  2. Keyframes' time are sorted in a strict ascending order.
    //  3. Keyframes' time are all within [0,animation duration] range.
    func Validate() -> Bool {
        if (duration <= 0.0) {  // Tests duration is valid.
            return false
        }
        if (tracks.count > Skeleton.Constants.kMaxJoints.rawValue) {  // Tests number of tracks.
            return false
        }
        // Ensures that all key frames' time are valid, ie: in a strict ascending
        // order and within range [0:duration].
        var valid = true
        var i = 0
        while valid && i < tracks.count {
            valid = tracks[i].Validate(duration)
            i += 1
        }
        return valid  // *this is valid.
    }
}


// Implements key frames' time range and ordering checks.
// See AnimationBuilder::Create for more details.
func ValidateTrack<_Key: KeyType>(_ _track: [_Key], _ _duration: Float) -> Bool {
    var previous_time: Float = -1.0
    for k in 0..<_track.count {
        let frame_time = _track[k].time
        // Tests frame's time is in range [0:duration].
        if (frame_time < 0.0 || frame_time > _duration) {
            return false
        }
        // Tests that frames are sorted.
        if (frame_time <= previous_time) {
            return false
        }
        previous_time = frame_time
    }
    return true  // Validated.
}
