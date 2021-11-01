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
    // Validates job parameters. Returns true for a valid job, or false otherwise:
    // -if any input pointer is nullptr
    // -if output range is invalid.
    func Validate() -> Bool {
        // Don't need any early out, as jobs are valid in most of the performance
        // critical cases.
        // Tests are written in multiple lines in order to avoid branches.
        var valid = true

        // Test for nullptr pointers.
        if (animation == nil || cache == nil) {
            return false
        }
        valid = valid && !output.isEmpty

        let num_soa_tracks = animation!.num_soa_tracks()
        valid = valid && output.count >= num_soa_tracks

        // Tests cache size.
        valid = valid && cache!.max_soa_tracks() >= num_soa_tracks

        return valid
    }

    // Runs job's sampling task.
    // The job is validated before any operation is performed, see Validate() for
    // more details.
    // Returns false if *this job is not valid.
    mutating func Run() -> Bool {
        if (!Validate()) {
            return false
        }

        guard let animation = animation,
              let cache = cache else {
            fatalError()
        }

        let num_soa_tracks = animation.num_soa_tracks()
        if (num_soa_tracks == 0) {  // Early out if animation contains no joint.
            return true
        }

        // Clamps ratio in range [0,duration].
        let anim_ratio = simd_clamp(0.0, ratio, 1.0)

        // Step the cache to this potentially new animation and ratio.
        assert(cache.max_soa_tracks() >= num_soa_tracks)
        cache.Step(animation, anim_ratio)

        // Fetch key frames from the animation to the cache a r = anim_ratio.
        // Then updates outdated soa hot values.
        UpdateCacheCursor(anim_ratio, num_soa_tracks, animation.translations(),
                &cache.translation_cursor_, &cache.translation_keys_,
                &cache.outdated_translations_)
        UpdateInterpKeyframes(num_soa_tracks, animation.translations(),
                cache.translation_keys_, &cache.outdated_translations_,
                &cache.soa_translations_, DecompressFloat3)

        UpdateCacheCursor(anim_ratio, num_soa_tracks, animation.rotations(),
                &cache.rotation_cursor_, &cache.rotation_keys_,
                &cache.outdated_rotations_)
        UpdateInterpKeyframes(num_soa_tracks, animation.rotations(),
                cache.rotation_keys_, &cache.outdated_rotations_,
                &cache.soa_rotations_, DecompressQuaternion)

        UpdateCacheCursor(anim_ratio, num_soa_tracks, animation.scales(),
                &cache.scale_cursor_, &cache.scale_keys_,
                &cache.outdated_scales_)
        UpdateInterpKeyframes(num_soa_tracks, animation.scales(), cache.scale_keys_,
                &cache.outdated_scales_, &cache.soa_scales_,
                DecompressFloat3)

        // Interpolates soa hot data.
        Interpolates(anim_ratio, num_soa_tracks, cache.soa_translations_,
                cache.soa_rotations_, cache.soa_scales_, &output)

        return true
    }

    // Time ratio in the unit interval [0,1] used to sample animation (where 0 is
    // the beginning of the animation, 1 is the end). It should be computed as the
    // current time in the animation , divided by animation duration.
    // This ratio is clamped before job execution in order to resolves any
    // approximation issue on range bounds.
    var ratio: Float = 0.0

    // The animation to sample.
    var animation: Animation?

    // A cache object that must be big enough to sample *this animation.
    var cache: SamplingCache?

    // Job output.
    // The output range to be filled with sampled joints during job execution.
    // If there are less joints in the animation compared to the output range,
    // then remaining SoaTransform are left unchanged.
    // If there are more joints in the animation, then the last joints are not
    // sampled.
    var output: ArraySlice<SoaTransform>
}

protocol InterpSoaType {
    associatedtype T
    var ratio: (SimdFloat4, SimdFloat4) { get set }
    var value: (T, T) { get set }
}

internal struct InterpSoaFloat3: InterpSoaType {
    var ratio: (SimdFloat4, SimdFloat4) = (OZZFloat4.zero(), OZZFloat4.zero())
    var value: (SoaFloat3, SoaFloat3) = (SoaFloat3.zero(), SoaFloat3.zero())
}

internal struct InterpSoaQuaternion: InterpSoaType {
    var ratio: (SimdFloat4, SimdFloat4) = (OZZFloat4.zero(), OZZFloat4.zero())
    var value: (SoaQuaternion, SoaQuaternion) = (SoaQuaternion.identity(), SoaQuaternion.identity())
}

// Declares the cache object used by the workload to take advantage of the
// frame coherency of animation sampling.
internal class SamplingCache {
    // Constructs an empty cache. The cache needs to be resized with the
    // appropriate number of tracks before it can be used with a SamplingJob.
    init() {
        Invalidate()
    }

    // Constructs a cache that can be used to sample any animation with at most
    // _max_tracks tracks. _num_tracks is internally aligned to a multiple of
    // soa size, which means max_tracks() can return a different (but bigger)
    // value than _max_tracks.
    init(_ _max_tracks: Int) {
        Resize(_max_tracks)
    }

    // Resize the number of joints that the cache can support.
    // This also implicitly invalidate the cache.
    func Resize(_ _max_tracks: Int) {
        // Reset existing data.
        Invalidate()

        // Updates maximum supported soa tracks.
        max_soa_tracks_ = (_max_tracks + 3) / 4

        // Allocate all cache data at once in a single allocation.
        // Alignment is guaranteed because memory is dispatch from the highest
        // alignment requirement (Soa data: SimdFloat4) to the lowest (outdated
        // flag: unsigned char).

        // Computes allocation size.
        let max_tracks = max_soa_tracks_ * 4
        let num_outdated = (max_soa_tracks_ + 7) / 8

        soa_translations_ = [InterpSoaFloat3](repeating: InterpSoaFloat3(), count: max_soa_tracks_)[...]
        soa_rotations_ = [InterpSoaQuaternion](repeating: InterpSoaQuaternion(), count: max_soa_tracks_)[...]
        soa_scales_ = [InterpSoaFloat3](repeating: InterpSoaFloat3(), count: max_soa_tracks_)[...]

        translation_keys_ = [Int](repeating: 0, count: max_tracks * 2)[...]
        rotation_keys_ = [Int](repeating: 0, count: max_tracks * 2)[...]
        scale_keys_ = [Int](repeating: 0, count: max_tracks * 2)[...]

        outdated_translations_ = [UInt8](repeating: 0, count: num_outdated)[...]
        outdated_rotations_ = [UInt8](repeating: 0, count: num_outdated)[...]
        outdated_scales_ = [UInt8](repeating: 0, count: num_outdated)[...]
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
        animation_ = nil
        ratio_ = 0.0
        translation_cursor_ = 0
        rotation_cursor_ = 0
        scale_cursor_ = 0
    }

    // The maximum number of tracks that the cache can handle.
    func max_tracks() -> Int {
        max_soa_tracks_ * 4
    }

    func max_soa_tracks() -> Int {
        max_soa_tracks_
    }

    // Steps the cache in order to use it for a potentially new animation and
    // ratio. If the _animation is different from the animation currently cached,
    // or if the _ratio shows that the animation is played backward, then the
    // cache is invalidated and reseted for the new _animation and _ratio.
    internal func Step(_ _animation: Animation, _ _ratio: Float) {
        // The cache is invalidated if animation has changed or if it is being rewind.
        if (animation_ !== _animation || _ratio < ratio_) {
            animation_ = _animation
            translation_cursor_ = 0
            rotation_cursor_ = 0
            scale_cursor_ = 0
        }
        ratio_ = _ratio
    }

    // The animation this cache refers to. nullptr means that the cache is invalid.
    internal var animation_: Animation?

    // The current time ratio in the animation.
    internal var ratio_: Float = 0.0

    // The number of soa tracks that can store this cache.
    internal var max_soa_tracks_: Int = 0

    // Soa hot data to interpolate.
    internal var soa_translations_: ArraySlice<InterpSoaFloat3> = ArraySlice()
    internal var soa_rotations_: ArraySlice<InterpSoaQuaternion> = ArraySlice()
    internal var soa_scales_: ArraySlice<InterpSoaFloat3> = ArraySlice()

    // Points to the keys in the animation that are valid for the current time
    // ratio.
    var translation_keys_: ArraySlice<Int> = ArraySlice()
    var rotation_keys_: ArraySlice<Int> = ArraySlice()
    var scale_keys_: ArraySlice<Int> = ArraySlice()

    // Current cursors in the animation. 0 means that the cache is invalid.
    var translation_cursor_: Int = 0
    var rotation_cursor_: Int = 0
    var scale_cursor_: Int = 0

    // Outdated soa entries. One bit per soa entry (32 joints per byte).
    var outdated_translations_: ArraySlice<UInt8> = ArraySlice()
    var outdated_rotations_: ArraySlice<UInt8> = ArraySlice()
    var outdated_scales_: ArraySlice<UInt8> = ArraySlice()
}

// Loops through the sorted key frames and update cache structure.
func UpdateCacheCursor<_Key: KeyframeType>(_ _ratio: Float, _ _num_soa_tracks: Int,
                                           _ _keys: ArraySlice<_Key>, _ _cursor: inout Int,
                                           _ _cache: inout ArraySlice<Int>, _ _outdated: inout ArraySlice<uint8>) {
    assert(_num_soa_tracks >= 1)
    let num_tracks = _num_soa_tracks * 4
    assert(num_tracks * 2 <= _keys.count)

    var cursor = 0
    if (_cursor == 0) {
        // Initializes interpolated entries with the first 2 sets of key frames.
        // The sorting algorithm ensures that the first 2 key frames of a track
        // are consecutive.
        for i in 0..<_num_soa_tracks {
            let in_index0 = i * 4                   // * soa size
            let in_index1 = in_index0 + num_tracks  // 2nd row.
            let out_index = i * 4 * 2
            _cache[out_index + 0] = in_index0 + 0
            _cache[out_index + 1] = in_index1 + 0
            _cache[out_index + 2] = in_index0 + 1
            _cache[out_index + 3] = in_index1 + 1
            _cache[out_index + 4] = in_index0 + 2
            _cache[out_index + 5] = in_index1 + 2
            _cache[out_index + 6] = in_index0 + 3
            _cache[out_index + 7] = in_index1 + 3
        }
        cursor = num_tracks * 2  // New cursor position.

        // All entries are outdated. It cares to only flag valid soa entries as
        // this is the exit condition of other algorithms.
        let num_outdated_flags = (_num_soa_tracks + 7) / 8
        for i in 0..<num_outdated_flags - 1 {
            _outdated[i] = 0xff
        }
        _outdated[num_outdated_flags - 1] =
                0xff >> (num_outdated_flags * 8 - _num_soa_tracks)
    } else {
        cursor = _cursor  // Might be == end()
        assert(cursor >= num_tracks * 2 && cursor <= _keys.count)
    }

    // Search for the keys that matches _ratio.
    // Iterates while the cache is not updated with left and right keys required
    // for interpolation at time ratio _ratio, for all tracks. Thanks to the
    // keyframe sorting, the loop can end as soon as it finds a key greater that
    // _ratio. It will mean that all the keys lower than _ratio have been
    // processed, meaning all cache entries are up to date.
    while (cursor < _keys.count &&
            _keys[_cache[Int(_keys[cursor].track) * 2 + 1]].ratio <= _ratio) {
        // Flag this soa entry as outdated.
        _outdated[Int(_keys[cursor].track) / 32] |= (1 << ((_keys[cursor].track & 0x1f) / 4))
        // Updates cache.
        let base = Int(_keys[cursor].track * 2)
        _cache[base] = _cache[base + 1]
        _cache[base + 1] = cursor
        // Process next key.
        cursor += 1
    }
    assert(cursor <= _keys.count)

    // Updates cursor output.
    _cursor = cursor
}

func DecompressFloat3(_ _k0: Float3Key, _ _k1: Float3Key,
                      _ _k2: Float3Key, _ _k3: Float3Key,
                      _ _soa_float3: inout SoaFloat3) {
    _soa_float3.x = OZZMath.halfToFloat(withSIMD: OZZInt4.load(with: Int32(_k0.value.0), Int32(_k1.value.0),
            Int32(_k2.value.0), Int32(_k3.value.0)))
    _soa_float3.y = OZZMath.halfToFloat(withSIMD: OZZInt4.load(with: Int32(_k0.value.1), Int32(_k1.value.1),
            Int32(_k2.value.1), Int32(_k3.value.1)))
    _soa_float3.z = OZZMath.halfToFloat(withSIMD: OZZInt4.load(with: Int32(_k0.value.2), Int32(_k1.value.2),
            Int32(_k2.value.2), Int32(_k3.value.2)))
}

// Defines a mapping table that defines components assignation in the output
// quaternion.
let kCpntMapping: [[Int]] = [[0, 0, 1, 2], [0, 0, 1, 2], [0, 1, 0, 2], [0, 1, 2, 0]]

func DecompressQuaternion(_ _k0: QuaternionKey, _ _k1: QuaternionKey,
                          _ _k2: QuaternionKey, _ _k3: QuaternionKey,
                          _ _quaternion: inout SoaQuaternion) {
    // Selects proper mapping for each key.
    let m0 = kCpntMapping[Int(_k0.largest)]
    let m1 = kCpntMapping[Int(_k1.largest)]
    let m2 = kCpntMapping[Int(_k2.largest)]
    let m3 = kCpntMapping[Int(_k3.largest)]

    // Prepares an array of input values, according to the mapping required to
    // restore quaternion largest component.
    func getTuple(_ key: QuaternionKey, _ index: Int) -> Int32 {
        switch index {
        case 0:
            return Int32(key.value.0)
        case 1:
            return Int32(key.value.1)
        case 2:
            return Int32(key.value.2)
        default:
            fatalError()
        }
    }

    var cmp_keys: [[Int32]] = [
        [getTuple(_k0, m0[0]), getTuple(_k1, m1[0]), getTuple(_k2, m2[0]), getTuple(_k3, m3[0])],
        [getTuple(_k0, m0[1]), getTuple(_k1, m1[1]), getTuple(_k2, m2[1]), getTuple(_k3, m3[1])],
        [getTuple(_k0, m0[2]), getTuple(_k1, m1[2]), getTuple(_k2, m2[2]), getTuple(_k3, m3[2])],
        [getTuple(_k0, m0[3]), getTuple(_k1, m1[3]), getTuple(_k2, m2[3]), getTuple(_k3, m3[3])],
    ]

    // Resets largest component to 0. Overwritting here avoids 16 branchings
    // above.
    cmp_keys[Int(_k0.largest)][0] = 0
    cmp_keys[Int(_k1.largest)][1] = 0
    cmp_keys[Int(_k2.largest)][2] = 0
    cmp_keys[Int(_k3.largest)][3] = 0

    // Rebuilds quaternion from quantized values.
    let kInt2Float = OZZFloat4.load1(with: 1.0 / (32767.0 * kSqrt2))
    var cpnt: [SimdFloat4] = [
        kInt2Float * OZZFloat4.fromInt(with: OZZInt4.loadPtr(with: cmp_keys[0])),
        kInt2Float * OZZFloat4.fromInt(with: OZZInt4.loadPtr(with: cmp_keys[1])),
        kInt2Float * OZZFloat4.fromInt(with: OZZInt4.loadPtr(with: cmp_keys[2])),
        kInt2Float * OZZFloat4.fromInt(with: OZZInt4.loadPtr(with: cmp_keys[3])),
    ]

    // Get back length of 4th component. Favors performance over accuracy by using
    // x * RSqrtEst(x) instead of Sqrt(x).
    // ww0 cannot be 0 because we 're recomputing the largest component.
    let dot = cpnt[0] * cpnt[0] + cpnt[1] * cpnt[1] + cpnt[2] * cpnt[2] + cpnt[3] * cpnt[3]
    let ww0 = OZZFloat4.max(with: OZZFloat4.load1(with: 1e-16), OZZFloat4.one() - dot)
    let w0 = ww0 * OZZFloat4.rSqrtEst(with: ww0)
    // Re-applies 4th component' s sign.
    let sign = OZZInt4.shiftL(with: OZZInt4.load(with: Int32(_k0.sign), Int32(_k1.sign), Int32(_k2.sign), Int32(_k3.sign)), 31)
    let restored = OZZFloat4.or(with: w0, int4: sign)

    // Re-injects the largest component inside the SoA structure.
    cpnt[Int(_k0.largest)] = OZZFloat4.or(with: cpnt[Int(_k0.largest)], float4: OZZFloat4.and(with: restored, int4: OZZInt4.mask_f000()))
    cpnt[Int(_k1.largest)] = OZZFloat4.or(with: cpnt[Int(_k1.largest)], float4: OZZFloat4.and(with: restored, int4: OZZInt4.mask_0f00()))
    cpnt[Int(_k2.largest)] = OZZFloat4.or(with: cpnt[Int(_k2.largest)], float4: OZZFloat4.and(with: restored, int4: OZZInt4.mask_00f0()))
    cpnt[Int(_k3.largest)] = OZZFloat4.or(with: cpnt[Int(_k3.largest)], float4: OZZFloat4.and(with: restored, int4: OZZInt4.mask_000f()))

    // Stores result.
    _quaternion.x = cpnt[0]
    _quaternion.y = cpnt[1]
    _quaternion.z = cpnt[2]
    _quaternion.w = cpnt[3]
}

func Interpolates(_ _anim_ratio: Float, _ _num_soa_tracks: Int,
                  _ _translations: ArraySlice<InterpSoaFloat3>,
                  _ _rotations: ArraySlice<InterpSoaQuaternion>,
                  _ _scales: ArraySlice<InterpSoaFloat3>,
                  _ _output: inout ArraySlice<SoaTransform>) {
    let anim_ratio = OZZFloat4.load1(with: _anim_ratio)
    for i in 0..<_num_soa_tracks {
        // Prepares interpolation coefficients.
        let interp_t_ratio = (anim_ratio - _translations[i].ratio.0) *
                OZZFloat4.rcpEst(with: _translations[i].ratio.1 - _translations[i].ratio.0)
        let interp_r_ratio = (anim_ratio - _rotations[i].ratio.0) *
                OZZFloat4.rcpEst(with: _rotations[i].ratio.1 - _rotations[i].ratio.0)
        let interp_s_ratio = (anim_ratio - _scales[i].ratio.0) *
                OZZFloat4.rcpEst(with: _scales[i].ratio.1 - _scales[i].ratio.0)

        // Processes interpolations.
        // The lerp of the rotation uses the shortest path, because opposed
        // quaternions were negated during animation build stage (AnimationBuilder).
        _output[i].translation = Lerp(_translations[i].value.0, _translations[i].value.1, interp_t_ratio)
        _output[i].rotation = NLerpEst(_rotations[i].value.0, _rotations[i].value.1, interp_r_ratio)
        _output[i].scale = Lerp(_scales[i].value.0, _scales[i].value.1, interp_s_ratio)
    }
}

func UpdateInterpKeyframes<_Key: KeyframeType, _InterpKey: InterpSoaType>(_ _num_soa_tracks: Int,
                                                                          _ _keys: ArraySlice<_Key>,
                                                                          _ _interp: ArraySlice<Int>,
                                                                          _ _outdated: inout ArraySlice<UInt8>,
                                                                          _ _interp_keys: inout ArraySlice<_InterpKey>,
                                                                          _ _decompress: (_Key, _Key, _Key, _Key,
                                                                                          inout _InterpKey.T) -> Void) {
    let num_outdated_flags = (_num_soa_tracks + 7) / 8
    for j in 0..<num_outdated_flags {
        var outdated = _outdated[j]
        _outdated[j] = 0  // Reset outdated entries as all will be processed.
        var i = j * 8
        while outdated != 0 {
            if ((outdated & 1) == 0) {
                continue
            }
            let base = i * 4 * 2  // * soa size * 2 keys

            // Decompress left side keyframes and store them in soa structures.
            let k00 = _keys[_interp[base + 0]]
            let k10 = _keys[_interp[base + 2]]
            let k20 = _keys[_interp[base + 4]]
            let k30 = _keys[_interp[base + 6]]
            _interp_keys[i].ratio.0 = OZZFloat4.load(with: k00.ratio, k10.ratio, k20.ratio, k30.ratio)
            _decompress(k00, k10, k20, k30, &_interp_keys[i].value.0)

            // Decompress right side keyframes and store them in soa structures.
            let k01 = _keys[_interp[base + 1]]
            let k11 = _keys[_interp[base + 3]]
            let k21 = _keys[_interp[base + 5]]
            let k31 = _keys[_interp[base + 7]]
            _interp_keys[i].ratio.1 = OZZFloat4.load(with: k01.ratio, k11.ratio, k21.ratio, k31.ratio)
            _decompress(k01, k11, k21, k31, &_interp_keys[i].value.1)

            i += 1
            outdated >>= 1
        }
    }
}
