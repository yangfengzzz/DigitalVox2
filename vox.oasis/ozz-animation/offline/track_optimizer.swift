//
//  track_optimizer.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// TrackOptimizer is responsible for optimizing an offline raw track instance.
// Optimization is a keyframe reduction process. Redundant and interpolable
// keyframes (within a tolerance value) are removed from the track. Default
// optimization tolerances are set in order to favor quality over runtime
// performances and memory footprint.
class TrackOptimizer {
    // Optimizes _input using *this parameters.
    // Returns true on success and fills _output track with the optimized
    // version of _input track.
    // *_output must be a valid Raw*Track instance.
    // Returns false on failure and resets _output to an empty track.
    // See Raw*Track::Validate() for more details about failure reasons.
    func eval(_input: RawFloatTrack, _output: inout RawFloatTrack) -> Bool {
        fatalError()
    }

    func eval(_input: RawFloat2Track, _output: inout RawFloat2Track) -> Bool {
        fatalError()
    }

    func eval(_input: RawFloat3Track, _output: inout RawFloat3Track) -> Bool {
        fatalError()
    }

    func eval(_input: RawFloat4Track, _output: inout RawFloat4Track) -> Bool {
        fatalError()
    }

    func eval(_input: RawQuaternionTrack, _output: inout RawQuaternionTrack) -> Bool {
        fatalError()
    }

    // Optimization tolerance.
    var tolerance: Float = 1.0e-3
}
