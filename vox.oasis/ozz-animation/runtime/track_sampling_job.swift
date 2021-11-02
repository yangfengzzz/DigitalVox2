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
    // Validates all parameters.
    func Validate() -> Bool {
        var success = true
        success = success && track != nil
        return success
    }

    // Validates and executes sampling.
    mutating func Run() -> Bool {
        if (!Validate()) {
            return false
        }

        // Clamps ratio in range [0,1].
        let clamped_ratio = simd_clamp(0.0, ratio, 1.0)

        // Search keyframes to interpolate.
        let ratios = track!.ratios()
        let values = track!.values()
        assert(ratios.count == values.count &&
                track!.steps().count * 8 >= values.count)

        // Default track returns identity.
        if (ratios.count == 0) {
            result = ValueType.identity()
            return true
        }

        // Search for the first key frame with a ratio value greater than input ratio.
        // Our ratio is between this one and the previous one.
        let id1 = ratios.firstIndex { f in
            f > clamped_ratio
        }

        // Deduce keys indices.
        let id0 = ratios.count - 1

        let id0step = (track!.steps()[id0 / 8] & (1 << (id0 & 7))) != 0
        if (id0step || id1 == nil) {
            result = values.last! as! ValueType._ValueType
        } else {
            // Lerp relevant keys.
            let tk0 = ratios[id0]
            let tk1 = ratios[id1!]
            assert(clamped_ratio >= tk0 && clamped_ratio < tk1 && tk0 != tk1)
            let alpha = (clamped_ratio - tk0) / (tk1 - tk0)
            let vk0 = values[id0]
            let vk1 = values[id1!]
            result = ValueType.Lerp(vk0 as! ValueType._ValueType, vk1 as! ValueType._ValueType, alpha)
        }
        return true
    }

    // Ratio used to sample track, clamped in range [0,1] before job execution. 0
    // is the beginning of the track, 1 is the end. This is a ratio rather than a
    // ratio because tracks have no duration.
    var ratio: Float = 0.0

    // Track to sample.
    var track: Track<ValueType>?

    //MARK: -  Job output.
    var result = ValueType.identity()
}

// Track sampling job implementation. Track sampling allows to query a track
// value for a specified ratio. This is a ratio rather than a time because
// tracks have no duration.
typealias FloatTrackSamplingJob = TrackSamplingJob<Float>
typealias Float2TrackSamplingJob = TrackSamplingJob<VecFloat2>
typealias Float3TrackSamplingJob = TrackSamplingJob<VecFloat3>
typealias Float4TrackSamplingJob = TrackSamplingJob<VecFloat4>
typealias QuaternionTrackSamplingJob = TrackSamplingJob<VecQuaternion>
