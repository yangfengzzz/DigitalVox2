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
    func eval(_ _input: RawAnimation) -> SoaAnimation? {
        // Tests _raw_animation validity.
        if (!_input.validate()) {
            return nil
        }

        // Everything is fine, allocates and fills the animation.
        // Nothing can fail now.
        let animation = SoaAnimation()

        // Sets duration.
        let duration = _input.duration
        let inv_duration = 1.0 / _input.duration
        animation.duration_ = duration
        // A _duration == 0 would create some division by 0 during sampling.
        // Also we need at least to keys with different times, which cannot be done
        // if duration is 0.
        assert(duration > 0.0)  // This case is handled by Validate().

        // Sets tracks count. Can be safely casted to uint16_t as number of tracks as
        // already been validated.
        let num_tracks = _input.num_tracks()
        animation.num_tracks_ = num_tracks
        let num_soa_tracks = align(num_tracks, 4)

        // Declares and preallocates tracks to sort.
        var translations = 0
        var rotations = 0
        var scales = 0
        for i in 0..<num_tracks {
            let raw_track = _input.tracks[i]
            translations += raw_track.translations.count + 2  // +2 because worst case
            rotations += raw_track.rotations.count + 2        // needs to add the
            scales += raw_track.scales.count + 2              // first and last keys.
        }
        var sorting_translations: [SortingTranslationKey] = []
        sorting_translations.reserveCapacity(translations)
        var sorting_rotations: [SortingRotationKey] = []
        sorting_rotations.reserveCapacity(rotations)
        var sorting_scales: [SortingScaleKey] = []
        sorting_scales.reserveCapacity(scales)

        // Filters RawAnimation keys and copies them to the output sorting structure.
        var i: UInt16 = 0
        while i < num_tracks {
            let raw_track = _input.tracks[Int(i)]
            copyRaw(raw_track.translations, i, duration, &sorting_translations)
            copyRaw(raw_track.rotations, i, duration, &sorting_rotations)
            copyRaw(raw_track.scales, i, duration, &sorting_scales)
            i += 1
        }

        while i < num_soa_tracks {
            pushBackIdentityKey(i, 0.0, &sorting_translations)
            pushBackIdentityKey(i, duration, &sorting_translations)

            pushBackIdentityKey(i, 0.0, &sorting_rotations)
            pushBackIdentityKey(i, duration, &sorting_rotations)

            pushBackIdentityKey(i, 0.0, &sorting_scales)
            pushBackIdentityKey(i, duration, &sorting_scales)
            i += 1
        }

        // Allocate animation members.
        animation.allocate(sorting_translations.count, sorting_rotations.count, sorting_scales.count)

        // Copy sorted keys to final animation.
        copyToAnimation(&sorting_translations, &animation.translations_, inv_duration)
        copyToAnimation(&sorting_rotations, &animation.rotations_, inv_duration)
        copyToAnimation(&sorting_scales, &animation.scales_, inv_duration)

        // Copy animation's name.
        animation.name_ = _input.name

        return animation  // Success.
    }
}

fileprivate func align(_ _value: Int, _ _alignment: Int) -> Int {
    (_value + (_alignment - 1)) & (0 - _alignment)
}

fileprivate protocol SortingType {
    associatedtype Key: KeyType
    var track: UInt16 { get set }
    var prev_key_time: Float { get set }
    var key: Key { get set }

    init(_ track: UInt16, _ prev_key_time: Float, _ key: Key)
}

fileprivate struct SortingTranslationKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.TranslationKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.TranslationKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

fileprivate struct SortingRotationKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.RotationKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.RotationKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

fileprivate struct SortingScaleKey: SortingType {
    var track: UInt16
    var prev_key_time: Float
    var key: RawAnimation.ScaleKey

    init(_ track: UInt16, _ prev_key_time: Float, _ key: RawAnimation.ScaleKey) {
        self.track = track
        self.prev_key_time = prev_key_time
        self.key = key
    }
}

// Keyframe sorting. Stores first by time and then track number.
fileprivate func sortingKeyLess<_Key: SortingType>(_ _left: _Key, _ _right: _Key) -> Bool {
    let time_diff = _left.prev_key_time - _right.prev_key_time
    return time_diff < 0.0 || (time_diff == 0.0 && _left.track < _right.track)
}

fileprivate func pushBackIdentityKey<_DestTrack: SortingType>(_ _track: UInt16, _ _time: Float, _ _dest: inout [_DestTrack]) {
    var prev_time: Float = -1.0
    if (!_dest.isEmpty && _dest.last!.track == _track) {
        prev_time = _dest.last!.key.time
    }
    let key = _DestTrack(_track, prev_time, _DestTrack.Key(_time, _DestTrack.Key.identity()))
    _dest.append(key)
}

// Copies a track from a RawAnimation to an Animation.
// Also fixes up the front (t = 0) and back keys (t = duration).
fileprivate func copyRaw<_DestTrack: SortingType>(_ _src: [_DestTrack.Key], _ _track: UInt16,
                                                  _ _duration: Float, _ _dest: inout [_DestTrack]) {
    if (_src.count == 0) {  // Adds 2 new keys.
        pushBackIdentityKey(_track, 0.0, &_dest)
        pushBackIdentityKey(_track, _duration, &_dest)
    } else if (_src.count == 1) {  // Adds 1 new key.
        let raw_key = _src.first!
        assert(raw_key.time >= 0 && raw_key.time <= _duration)
        let first = _DestTrack(_track, -1.0, _DestTrack.Key(0.0, raw_key.value))
        _dest.append(first)
        let last = _DestTrack(_track, 0.0, _DestTrack.Key(_duration, raw_key.value))
        _dest.append(last)
    } else {  // Copies all keys, and fixes up first and last keys.
        var prev_time: Float = -1.0
        if (_src.first!.time != 0.0) {  // Needs a key at t = 0.f.
            let first = _DestTrack(_track, prev_time, _DestTrack.Key(0.0, _src.first!.value))
            _dest.append(first)
            prev_time = 0.0
        }
        for k in 0..<_src.count { // Copies all keys.
            let raw_key = _src[k]
            assert(raw_key.time >= 0 && raw_key.time <= _duration)
            let key = _DestTrack(_track, prev_time, _DestTrack.Key(raw_key.time, raw_key.value))
            _dest.append(key)
            prev_time = raw_key.time
        }
        if (_src.last!.time - _duration != 0.0) {  // Needs a key at t = _duration.
            let last = _DestTrack(_track, prev_time, _DestTrack.Key(_duration, _src.last!.value))
            _dest.append(last)
        }
    }
    assert(_dest.first!.key.time == 0.0 && _dest.last!.key.time - _duration == 0.0)
}

fileprivate func copyToAnimation<_SortingKey: SortingType>(_ _src: inout [_SortingKey], _ _dest: inout ArraySlice<Float3Key>,
                                                           _ _inv_duration: Float) where _SortingKey.Key.T == VecFloat3 {
    let src_count = _src.count
    if (src_count == 0) {
        return
    }

    // Sort animation keys to favor cache coherency.
    _src.sort(by: sortingKeyLess)

    // Fills output.
    for i in 0..<src_count {
        _dest[i].ratio = _src[i].key.time * _inv_duration
        _dest[i].track = _src[i].track
        _dest[i].value.0 = math.floatToHalf(_src[i].key.value.x)
        _dest[i].value.1 = math.floatToHalf(_src[i].key.value.y)
        _dest[i].value.2 = math.floatToHalf(_src[i].key.value.z)
    }
}

// Compresses quaternion to ozz::animation::RotationKey format.
// The 3 smallest components of the quaternion are quantized to 16 bits
// integers, while the largest is recomputed thanks to quaternion normalization
// property (x^2+y^2+z^2+w^2 = 1). Because the 3 components are the 3 smallest,
// their value cannot be greater than sqrt(2)/2. Thus quantization quality is
// improved by pre-multiplying each componenent by sqrt(2).
fileprivate func compressQuat(_ _src: VecQuaternion, _ _dest: inout QuaternionKey) {
    // Finds the largest quaternion component.
    let quat = [_src.x, _src.y, _src.z, _src.w]
    let largestEle = quat.max { _left, _right in
        abs(_left) < abs(_right)
    }!
    let largest = quat.firstIndex { f in
        f == largestEle
    }!
    assert(largest <= 3)
    _dest.largest = UInt16(largest & 0x3)

    // Stores the sign of the largest component.
    if quat[largest] < 0.0 {
        _dest.sign = 1
    } else {
        _dest.sign = 0
    }

    // Quantize the 3 smallest components on 16 bits signed integers.
    let kFloat2Int = 32767.0 * kSqrt2
    let kMapping: [[Int]] = [[1, 2, 3], [0, 2, 3], [0, 1, 3], [0, 1, 2]]
    let map = kMapping[largest]
    let a = floor(quat[map[0]] * kFloat2Int + 0.5)
    let b = floor(quat[map[1]] * kFloat2Int + 0.5)
    let c = floor(quat[map[2]] * kFloat2Int + 0.5)
    _dest.value.0 = Int16(simd_clamp(-32767, a, 32767))
    _dest.value.1 = Int16(simd_clamp(-32767, b, 32767))
    _dest.value.2 = Int16(simd_clamp(-32767, c, 32767))
}

// Specialize for rotations in order to normalize quaternions.
// Consecutive opposite quaternions are also fixed up in order to avoid checking
// for the smallest path during the NLerp runtime algorithm.
fileprivate func copyToAnimation(_ _src: inout [SortingRotationKey],
                                 _ _dest: inout ArraySlice<QuaternionKey>, _ _inv_duration: Float) {
    let src_count = _src.count
    if (src_count == 0) {
        return
    }

    // Normalize quaternions.
    // Also fixes-up successive opposite quaternions that would fail to take the
    // shortest path during the normalized-lerp.
    // Note that keys are still sorted per-track at that point, which allows this
    // algorithm to process all consecutive keys.
    var track = UInt16.max
    let identity = VecQuaternion.identity()
    for i in 0..<src_count {
        var normalized = normalizeSafe(_src[i].key.value, identity)
        if (track != _src[i].track) {   // First key of the track.
            if (normalized.w < 0.0) {    // .w eq to a dot with identity quaternion.
                normalized = -normalized  // Q an -Q are the same rotation.
            }
        } else {  // Still on the same track: so fixes-up quaternion.
            let prev = VecFloat4(_src[i - 1].key.value.x, _src[i - 1].key.value.y,
                    _src[i - 1].key.value.z, _src[i - 1].key.value.w)
            let curr = VecFloat4(normalized.x, normalized.y, normalized.z, normalized.w)
            if (dot(prev, curr) < 0.0) {
                normalized = -normalized  // Q an -Q are the same rotation.
            }
        }
        // Stores fixed-up quaternion.
        _src[i].key.value = normalized
        track = _src[i].track
    }

    // Sort.
    _src.sort(by: sortingKeyLess)

    // Fills rotation keys output.
    for i in 0..<src_count {
        _dest[i].ratio = _src[i].key.time * _inv_duration
        _dest[i].track = _src[i].track

        // Compress quaternion to destination container.
        compressQuat(_src[i].key.value, &_dest[i])
    }
}
