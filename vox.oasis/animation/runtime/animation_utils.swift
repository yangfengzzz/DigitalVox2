//
//  animation_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Count translation, rotation or scale keyframes for a given track number. Use
// a negative _track value to count all tracks.
func CountTranslationKeyframes(_animation: Animation, _track: Int = -1) -> Int {
    CountKeyframesImpl(_animation.translations(), _track)
}

func CountRotationKeyframes(_animation: Animation, _track: Int = -1) -> Int {
    CountKeyframesImpl(_animation.rotations(), _track)
}

func CountScaleKeyframes(_animation: Animation, _track: Int = -1) -> Int {
    CountKeyframesImpl(_animation.scales(), _track)
}

fileprivate func CountKeyframesImpl<_Key: KeyframeType>(_ _keys: ArraySlice<_Key>, _ _track: Int) -> Int {
    if (_track < 0) {
        return _keys.count
    }

    var count = 0
    for key in _keys {
        if (key.track == _track) {
            count += 1
        }
    }
    return count
}
