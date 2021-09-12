//
//  IndexBufferBinding.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal

/// Index buffer binding.
class IndexBufferBinding {
    internal var _buffer: MTLBuffer?
    internal var _format: MTLIndexType

    /// Index buffer.
    var buffer: MTLBuffer? {
        get {
            _buffer
        }
    }

    /// Index buffer format.
    var format: MTLIndexType {
        get {
            _format
        }
    }

    /// Create index buffer binding.
    /// - Parameters:
    ///   - buffer: Index buffer
    ///   - format: Index buffer format
    init(_ buffer: MTLBuffer, _ format: MTLIndexType) {
        _buffer = buffer
        _format = format
    }
}
