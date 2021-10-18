//
//  BufferMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import MetalKit

/// BufferMesh.
class BufferMesh: Mesh {
    /// Instanced count, disable instanced drawing when set zero.
    var instanceCount: Int {
        get {
            _instanceCount
        }
        set {
            _instanceCount = newValue
        }
    }

    /// Vertex buffer collection.
    var vertexBuffer: [MeshBuffer?] {
        get {
            _vertexBuffer
        }
    }

    /// Vertex element collection.
    var vertexDescriptor: MDLVertexDescriptor {
        get {
            _vertexDescriptor
        }
    }
}

//MARK:- Vertex Attribute
extension BufferMesh {
    /// Set vertex descriptor.
    /// - Parameter descriptor: Vertex element collection
    func setVertexDescriptor(_ descriptor: MDLVertexDescriptor) {
        _vertexDescriptor = descriptor
    }
}

//MARK:- Vertex Buffer Bindings
extension BufferMesh {
    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBuffer: Vertex buffer binding
    ///   - index: Vertex buffer index, the default value is 0
    func setVertexBuffer(_ vertexBuffer: MeshBuffer, _ index: Int = 0) {
        if _vertexBuffer.count <= index {
            _vertexBuffer.reserveCapacity(index + 1)
            for _ in _vertexBuffer.count...index {
                _vertexBuffer.append(nil)
            }
        }
        _setVertexBuffer(index, vertexBuffer)
    }

    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBuffer: Vertex buffer
    ///   - offset: Vertex buffer data offset
    ///   - index: Vertex buffer index, the default value is 0
    func setVertexBufferBinding(_ vertexBuffer: MTLBuffer, _ offset: Int, _ index: Int = 0) {
        let binding = MeshBuffer(vertexBuffer, offset, .vertex)
        if _vertexBuffer.count <= index {
            _vertexBuffer.reserveCapacity(index + 1)
            for _ in _vertexBuffer.count...index {
                _vertexBuffer.append(nil)
            }
        }
        _setVertexBuffer(index, binding)
    }

    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBufferBindings: Vertex buffer binding
    ///   - firstIndex: First vertex buffer index, the default value is 0
    func setVertexBufferBindings(_ vertexBufferBindings: [MeshBuffer], _ firstIndex: Int = 0) {
        let count = vertexBufferBindings.count
        let needLength = firstIndex + count
        if _vertexBuffer.count < needLength {
            _vertexBuffer.reserveCapacity(needLength)
            for _ in _vertexBuffer.count..<needLength {
                _vertexBuffer.append(nil)
            }
        }
        for i in 0..<count {
            _setVertexBuffer(firstIndex + i, vertexBufferBindings[i])
        }
    }
}
