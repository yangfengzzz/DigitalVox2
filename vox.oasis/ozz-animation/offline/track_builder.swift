//
//  track_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible of building runtime track instances from
// offline tracks.The input raw track is first validated. Runtime conversion of
// a validated raw track cannot fail. Note that no optimization is performed on
// the data at all.
class TrackBuilder {
    // Creates a Track based on _raw_track and *this builder parameters.
    // Returns a track instance on success, an empty unique_ptr on failure. See
    // Raw*Track::Validate() for more details about failure reasons.
    // The track is returned as an unique_ptr as ownership is given back to the
    // caller.
    func eval(_ _input: RawFloatTrack) -> FloatTrack {
        fatalError()
    }

    func eval(_input: RawFloat2Track) -> Float2Track {
        fatalError()
    }

    func eval(_input: RawFloat3Track) -> Float3Track {
        fatalError()
    }

    func eval(_input: RawFloat4Track) -> Float4Track {
        fatalError()
    }

    func eval(_input: RawQuaternionTrack) -> QuaternionTrack {
        fatalError()
    }

    func Build<_RawTrack, _Track>(_input: _RawTrack) -> _Track {
        fatalError()
    }
}
