//
//  soa_animation.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

protocol KeyframeType {
    var ratio:Float {get set}
    var track:UInt16 {get set}
}

extension Float3Key:KeyframeType {
}

extension QuaternionKey:KeyframeType {
}

// Defines a runtime skeletal animation clip.
// The runtime animation data structure stores animation keyframes, for all the
// joints of a skeleton. This structure is usually filled by the
// AnimationBuilder and deserialized/loaded at runtime.
// For each transformation type (translation, rotation and scale), Animation
// structure stores a single array of keyframes that contains all the tracks
// required to animate all the joints of a skeleton, matching breadth-first
// joints order of the runtime skeleton structure. In order to optimize cache
// coherency when sampling the animation, Keyframes in this array are sorted by
// time, then by track number.
class SoaAnimation {
    // Duration of the animation clip.
    internal var duration_: Float = 0

    // The number of joint tracks. Can differ from the data stored in translation/
    // rotation/scale buffers because of SoA requirements.
    internal var num_tracks_: Int = 0

    // Animation name.
    internal var name_: String = ""

    // Stores all translation/rotation/scale keys begin and end of buffers.
    internal var translations_: ArraySlice<Float3Key> = ArraySlice()
    internal var rotations_: ArraySlice<QuaternionKey> = ArraySlice()
    internal var scales_: ArraySlice<Float3Key> = ArraySlice()

    // Gets the animation clip duration.
    func duration() -> Float {
        duration_
    }

    // Gets the number of animated tracks.
    func num_tracks() -> Int {
        num_tracks_
    }

    // Returns the number of SoA elements matching the number of tracks of *this
    // animation. This value is useful to allocate SoA runtime data structures.
    func num_soa_tracks() -> Int {
        (num_tracks_ + 3) / 4
    }

    // Gets animation name.
    func name() -> String {
        name_
    }

    // Gets the buffer of translations keys.
    func translations() -> ArraySlice<Float3Key> {
        translations_
    }

    // Gets the buffer of rotation keys.
    func rotations() -> ArraySlice<QuaternionKey> {
        rotations_
    }

    // Gets the buffer of scale keys.
    func scales() -> ArraySlice<Float3Key> {
        scales_
    }

    // Internal destruction function.
    internal func allocate(_ _translation_count: Int, _ _rotation_count: Int, _ _scale_count: Int) {
        assert(name_ == "" && translations_.count == 0 && rotations_.count == 0 && scales_.count == 0)

        // Fix up pointers. Serves larger alignment values first.
        translations_ = [Float3Key](repeating: Float3Key(), count: _translation_count)[...]
        rotations_ = [QuaternionKey](repeating: QuaternionKey(), count: _rotation_count)[...]
        scales_ = [Float3Key](repeating: Float3Key(), count: _scale_count)[...]
    }
}
