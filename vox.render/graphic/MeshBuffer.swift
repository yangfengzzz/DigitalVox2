//
//  MeshBuffer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import MetalKit

class MeshBuffer {
    private var _length: Int
    private var _buffer: MTLBuffer
    private var _offset: Int
    private var _type: MDLMeshBufferType

    var length: Int {
        get {
            _length
        }
    }

    var buffer: MTLBuffer {
        get {
            _buffer
        }
    }

    var offset: Int {
        get {
            _offset
        }
    }

    var type: MDLMeshBufferType {
        get {
            _type
        }
    }

    /// Create vertex buffer.
    /// - Parameters:
    ///   - buffer: Vertex buffer
    ///   - length: Vertex buffer length
    ///   - offset: Vertex buffer offset
    init(_ buffer: MTLBuffer, _ length: Int, _ type: MDLMeshBufferType, _ offset: Int = 0) {
        _buffer = buffer
        _length = length
        _type = type
        _offset = offset
    }
}
