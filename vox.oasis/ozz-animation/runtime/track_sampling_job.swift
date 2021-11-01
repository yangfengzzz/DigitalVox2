//
//  track_sampling_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// TrackSamplingJob internal implementation. See *TrackSamplingJob for more
// details.
struct TrackSamplingJob<ValueType: TrackPolicy> {
    init() {
        fatalError()
    }

    // Validates all parameters.
    func Validate() -> Bool {
        fatalError()
    }

    // Validates and executes sampling.
    func Run() -> Bool {
        fatalError()
    }

    // Ratio used to sample track, clamped in range [0,1] before job execution. 0
    // is the beginning of the track, 1 is the end. This is a ratio rather than a
    // ratio because tracks have no duration.
    var ratio: Float

    // Track to sample.
    var track: Track<ValueType>

    //MARK: -  Job output.
    var result: ValueType
}

// Track sampling job implementation. Track sampling allows to query a track
// value for a specified ratio. This is a ratio rather than a time because
// tracks have no duration.
typealias FloatTrackSamplingJob = TrackSamplingJob<Float>
typealias Float2TrackSamplingJob = TrackSamplingJob<VecFloat2>
typealias Float3TrackSamplingJob = TrackSamplingJob<VecFloat3>
typealias Float4TrackSamplingJob = TrackSamplingJob<VecFloat4>
typealias QuaternionTrackSamplingJob = TrackSamplingJob<VecQuaternion>
