//
//  animation_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible of building runtime animation instances from
// offline raw animations.
// No optimization at all is performed on the raw animation.
class AnimationBuilder {
    // Creates an Animation based on _raw_animation and *this builder parameters.
    // Returns a valid Animation on success.
    // See RawAnimation::Validate() for more details about failure reasons.
    // The animation is returned as an unique_ptr as ownership is given back to
    // the caller.
    func eval(_raw_animation: RawAnimation) -> Animation {
        fatalError()
    }
}

protocol SortingType {
    associatedtype Key: KeyType
    var track: UInt16 { get set }
    var prev_key_time: Float { get set }
    var key: Key { get set }

    init(_ track: UInt16, _ prev_key_time: Float, _ key: Key)
}

struct SortingTranslationKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.TranslationKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.TranslationKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

struct SortingRotationKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.RotationKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.RotationKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

struct SortingScaleKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.ScaleKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.ScaleKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

func PushBackIdentityKey<_DestTrack: SortingType>(_track: UInt16, _time: Float, _dest: inout [_DestTrack]) {
    var prev_time: Float = -1.0
    if (!_dest.isEmpty && _dest.last!.track == _track) {
        prev_time = _dest.last!.key.time
    }
    let key = _DestTrack(_track, prev_time, _DestTrack.Key(_time, _DestTrack.Key.identity()))
    _dest.append(key)
}
