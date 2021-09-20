//
//  ShaderMacroCollection.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Shader macro collection.
internal class ShaderMacroCollection {
    internal var _mask: [Int] = []
    internal var _length: Int = 0

    /// Enable one macro in this macro collection.
    /// - Parameter macro: ShaderMacro
    func enable(_ macro: ShaderMacro) {
        let index = macro._index
        let size = index + 1
        // must from _length because _length maybe less than mask.length and have dirty data should clear.
        let maskStart = _length
        if (maskStart < size) {
            if _mask.count < size {
                _mask.reserveCapacity(size)
                for _ in maskStart..<index {
                    _mask.append(0)
                }
            }
            _mask[index] = macro._value
            _length = size
        } else {
            _mask[index] |= macro._value
        }
    }

    /// Disable one macro in this macro collection.
    /// - Parameter macro: ShaderMacro
    func disable(_ macro: ShaderMacro) {
        let index = macro._index
        let endIndex = _length - 1
        if (index > endIndex) {
            return
        }
        let newValue = _mask[index] & ~macro._value
        if (index == endIndex && newValue == 0) {
            _length -= 1
        } else {
            _mask[index] = newValue
        }
    }

    /// Union of this and other macro collection.
    /// - Parameter macroCollection: macro collection
    func unionCollection(_ macroCollection: ShaderMacroCollection) {
        let addMask = macroCollection._mask
        let addSize = macroCollection._length
        let maskSize = _length
        if (maskSize < addSize) {
            if _mask.count < addSize {
                _mask.reserveCapacity(addSize)
                for _ in _mask.count..<addSize {
                    _mask.append(0)
                }
            }
            for i in 0..<maskSize {
                _mask[i] |= addMask[i]
            }
            for i in maskSize..<addSize {
                _mask[i] = addMask[i]
            }
            _length = addSize
        } else {
            for i in 0..<addSize {
                _mask[i] |= addMask[i]
            }
        }
    }

    /// Complementarity of this and other macro collection.
    /// - Parameter macroCollection: macro collection
    func complementaryCollection(_ macroCollection: ShaderMacroCollection) {
        let removeMask = macroCollection._mask
        var endIndex = _length - 1
        for i in stride(from: min(macroCollection._length - 1, endIndex), to: 0, by: -1) {
            let newValue = _mask[i] & ~removeMask[i]
            if (i == endIndex && newValue == 0) {
                endIndex -= 1
                _length -= 1
            } else {
                _mask[i] = newValue
            }
        }
    }

    /// Intersection of this and other macro collection.
    /// - Parameter macroCollection: macro collection
    func intersectionCollection(_ macroCollection: ShaderMacroCollection) {
        let unionMask = macroCollection._mask
        for i in 0..<_length {
            let value = _mask[i] & unionMask[i]
            if (value == 0 && i == _length - 1) {
                _length -= 1
            } else {
                _mask[i] = value
            }
        }
    }

    /// Whether macro is enabled in this macro collection.
    /// - Parameter macro:  ShaderMacro
    func isEnable(_ macro: ShaderMacro) -> Bool {
        let index = macro._index
        if (index >= _length) {
            return false
        }
        return (_mask[index] & macro._value) != 0
    }

    /// Clear this macro collection.
    func clear() {
        _length = 0
    }
}

extension ShaderMacroCollection {
    /// Union of two macro collection.
    /// - Parameters:
    ///   - left: input macro collection
    ///   - right: input macro collection
    ///   - out: union output macro collection
    static func unionCollection(_ left: ShaderMacroCollection,
                                _ right: ShaderMacroCollection,
                                _ out: ShaderMacroCollection) {
        let minSize: Int, maxSize: Int
        let minMask: [Int], maxMask: [Int]
        if (left._length < right._length) {
            minSize = left._length
            maxSize = right._length
            minMask = left._mask
            maxMask = right._mask
        } else {
            minSize = right._length
            maxSize = left._length
            minMask = right._mask
            maxMask = left._mask
        }

        if out._mask.count < maxSize {
            out._mask.reserveCapacity(maxSize)
            for _ in out._mask.count..<maxSize {
                out._mask.append(0)
            }
        }
        for i in 0..<minSize {
            out._mask[i] = minMask[i] | maxMask[i]
        }
        for i in minSize..<maxSize {
            out._mask[i] = maxMask[i]
        }
        out._length = maxSize
    }
}
