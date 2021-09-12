//
//  VertexBufferBinding.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Metal

/// Vertex buffer binding.
class VertexBufferBinding {
    internal var _buffer: MTLBuffer
    internal var _stride: Int

    /// Vertex buffer.
    var buffer: MTLBuffer {
        get {
            _buffer
        }
    }

    /// Vertex buffer stride.
    var stride: Int {
        get {
            _stride
        }
    }

    /// Create vertex buffer.
    /// - Parameters:
    ///   - buffer: Vertex buffer
    ///   - stride: Vertex buffer stride
    init(buffer: MTLBuffer, stride: Int) {
        _buffer = buffer
        _stride = stride
    }
}
