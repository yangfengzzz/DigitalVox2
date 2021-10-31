//
//  raw_animation.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

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
    struct TranslationKey {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecFloat3

        // Provides identity transformation for a translation key.
        static func identity() -> VecFloat3 {
            return VecFloat3.zero()
        }
    }

    // Defines a raw rotation key frame.
    struct RotationKey {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecQuaternion

        // Provides identity transformation for a rotation key.
        static func identity() -> VecQuaternion {
            return VecQuaternion.identity()
        }
    }

    // Defines a raw scaling key frame.
    struct ScaleKey {
        // Key frame time.
        var time: Float

        // Key frame value.
        var value: VecFloat3

        // Provides identity transformation for a scale key.
        static func identity() -> VecFloat3 {
            return VecFloat3.one()
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
        func Validate(_duration: Float) -> Bool {
            fatalError()
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
        return tracks.count
    }

    // Tests for *this validity.
    // Returns true if animation data (duration, tracks) is valid:
    //  1. Animation duration is greater than 0.
    //  2. Keyframes' time are sorted in a strict ascending order.
    //  3. Keyframes' time are all within [0,animation duration] range.
    func Validate() -> Bool {
        fatalError()
    }

    // Get the estimated animation's size in bytes.
    func size() -> Int {
        fatalError()
    }
}
