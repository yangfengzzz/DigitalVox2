//
//  sampling_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Samples an animation at a given time ratio in the unit interval [0,1] (where
// 0 is the beginning of the animation, 1 is the end), to output the
// corresponding posture in local-space.
// SamplingJob uses a cache (aka SamplingCache) to store intermediate values
// (decompressed animation keyframes...) while sampling. This cache also stores
// pre-computed values that allows drastic optimization while playing/sampling
// the animation forward. Backward sampling works, but isn't optimized through
// the cache. The job does not owned the buffers (in/output) and will thus not
// delete them during job's destruction.
struct SamplingJob {
    // Default constructor, initializes default values.
    init() {
        fatalError()
    }

    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if any input pointer is nullptr
    // -if output range is invalid.
    func Validate() -> Bool {
        fatalError()
    }

    // Runs job's sampling task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    func Run() -> Bool {
        fatalError()
    }

    // Time ratio in the unit interval [0,1] used to sample animation (where 0 is
    // the beginning of the animation, 1 is the end). It should be computed as the
    // current time in the animation , divided by animation duration.
    // This ratio is clamped before job execution in order to resolves any
    // approximation issue on range bounds.
    var ratio: Float

    // The animation to sample.
    var animation: Animation

    // A cache object that must be big enough to sample *this animation.
    var cache: SamplingCache

    // Job output.
    // The output range to be filled with sampled joints during job execution.
    // If there are less joints in the animation compared to the output range,
    // then remaining SoaTransform are left unchanged.
    // If there are more joints in the animation, then the last joints are not
    // sampled.
    var output: ArraySlice<SoaTransform>
}

internal struct InterpSoaFloat3 {
    var ratio: (SimdFloat4, SimdFloat4)
    var value: (SoaFloat3, SoaFloat3)
}

internal struct InterpSoaQuaternion {
    var ratio: (SimdFloat4, SimdFloat4)
    var value: (SoaQuaternion, SoaQuaternion)
}

// Declares the cache object used by the workload to take advantage of the
// frame coherency of animation sampling.
internal class SamplingCache {
    // Constructs an empty cache. The cache needs to be resized with the
    // appropriate number of tracks before it can be used with a SamplingJob.
    init() {
        fatalError()
    }

    // Constructs a cache that can be used to sample any animation with at most
    // _max_tracks tracks. _num_tracks is internally aligned to a multiple of
    // soa size, which means max_tracks() can return a different (but bigger)
    // value than _max_tracks.
    init(_max_tracks: Int) {
        fatalError()
    }

    // Resize the number of joints that the cache can support.
    // This also implicitly invalidate the cache.
    func Resize(_max_tracks: Int) {
        fatalError()
    }

    // Invalidate the cache.
    // The SamplingJob automatically invalidates a cache when required
    // during sampling. This automatic mechanism is based on the animation
    // address and sampling time ratio. The weak point is that it can result in a
    // crash if ever the address of an animation is used again with another
    // animation (could be the result of successive call to delete / new).
    // Therefore it is recommended to manually invalidate a cache when it is
    // known that this cache will not be used for with an animation again.
    func Invalidate() {
        fatalError()
    }

    // The maximum number of tracks that the cache can handle.
    func max_tracks() -> Int {
        return max_soa_tracks_ * 4
    }

    func max_soa_tracks() -> Int {
        return max_soa_tracks_
    }

    // Steps the cache in order to use it for a potentially new animation and
    // ratio. If the _animation is different from the animation currently cached,
    // or if the _ratio shows that the animation is played backward, then the
    // cache is invalidated and reseted for the new _animation and _ratio.
    internal func Step(_animation: Animation, _ratio: Float) {
        fatalError()
    }

    // The animation this cache refers to. nullptr means that the cache is invalid.
    internal var animation_: Animation

    // The current time ratio in the animation.
    internal var ratio_: Float

    // The number of soa tracks that can store this cache.
    internal var max_soa_tracks_: Int

    // Soa hot data to interpolate.
    internal var soa_translations_: ArraySlice<InterpSoaFloat3>
    internal var soa_rotations_: ArraySlice<InterpSoaQuaternion>
    internal var soa_scales_: ArraySlice<InterpSoaFloat3>

    // Points to the keys in the animation that are valid for the current time
    // ratio.
    var translation_keys_: ArraySlice<Int>
    var rotation_keys_: ArraySlice<Int>
    var scale_keys_: ArraySlice<Int>

    // Current cursors in the animation. 0 means that the cache is invalid.
    var translation_cursor_: Int
    var rotation_cursor_: Int
    var scale_cursor_: Int

    // Outdated soa entries. One bit per soa entry (32 joints per byte).
    var outdated_translations_: ArraySlice<UInt8>
    var outdated_rotations_: ArraySlice<UInt8>
    var outdated_scales_: ArraySlice<UInt8>
}
