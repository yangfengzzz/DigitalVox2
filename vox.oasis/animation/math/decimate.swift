//
//  decimate.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

protocol DecimateType {
    associatedtype Key

    func Decimable(_ _: Key) -> Bool
    func Lerp(_ _left: Key, _ _right: Key, _ _ref: Key) -> Key
    func Distance(_ _a: Key, _ _b: Key) -> Float
}

func decimate<Key, _Adapter: DecimateType>(_ _src: [Key], _ _adapter: _Adapter, _ _tolerance: Float,
                                           _ _dest: inout [Key]) where _Adapter.Key == Key {
    // Early out if not enough data.
    if (_src.count < 2) {
        _dest = _src
        return
    }

    // Stack of segments to process.
    var segments: [(Int, Int)] = []

    // Bit vector of all points to included.
    var included = [Bool](repeating: false, count: _src.count)

    // Pushes segment made from first and last points.
    segments.append((0, _src.count - 1))
    included[0] = true
    included[_src.count - 1] = true

    // Empties segments stack.
    while (!segments.isEmpty) {
        // Pops next segment to process.
        let segment = segments.popLast()!

        // Looks for the furthest point from the segment.
        var max: Float = -1.0
        var candidate = segment.0
        let left = _src[segment.0]
        let right = _src[segment.1]
        for i in segment.0 + 1..<segment.1 {
            guard !included[i] else {
                fatalError("Included points should be processed once only.")
            }
            let test = _src[i]
            if (!_adapter.Decimable(test)) {
                candidate = i
                break
            } else {
                let distance = _adapter.Distance(_adapter.Lerp(left, right, test), test)
                if (distance > _tolerance && distance > max) {
                    max = distance
                    candidate = i
                }
            }
        }

        // If found, include the point and pushes the 2 new segments (before and
        // after the new point).
        if (candidate != segment.0) {
            included[candidate] = true
            if (candidate - segment.0 > 1) {
                segments.append((segment.0, candidate))
            }
            if (segment.1 - candidate > 1) {
                segments.append((candidate, segment.1))
            }
        }
    }

    // Copy all included points.
    _dest = []
    for i in 0..<_src.count {
        if (included[i]) {
            _dest.append(_src[i])
        }
    }

    // Removes last key if constant.
    if (_dest.count > 1) {
        let last = _dest.last!
        let penultimate = _dest[_dest.count - 2]
        let distance = _adapter.Distance(penultimate, last)
        if (_adapter.Decimable(last) && distance <= _tolerance) {
            _ = _dest.popLast()
        }
    }
}
