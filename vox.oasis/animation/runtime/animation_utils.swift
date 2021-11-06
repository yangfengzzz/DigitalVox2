//
//  animation_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Count translation, rotation or scale keyframes for a given track number. Use
// a negative _track value to count all tracks.
func countTranslationKeyframes(_ _animation: SoaAnimation, _ _track: Int = -1) -> Int {
    countKeyframesImpl(_animation.translations(), _track)
}

func countRotationKeyframes(_ _animation: SoaAnimation, _ _track: Int = -1) -> Int {
    countKeyframesImpl(_animation.rotations(), _track)
}

func countScaleKeyframes(_ _animation: SoaAnimation, _ _track: Int = -1) -> Int {
    countKeyframesImpl(_animation.scales(), _track)
}

fileprivate func countKeyframesImpl<_Key: KeyframeType>(_ _keys: ArraySlice<_Key>, _ _track: Int) -> Int {
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
