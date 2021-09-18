//
//  BufferMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Metal

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

    /// Vertex buffer binding collection.
    var vertexBufferBindings: [VertexBufferBinding?] {
        get {
            _vertexBufferBindings
        }
    }

    /// Index buffer binding.
    var indexBufferBinding: IndexBufferBinding {
        get {
            _indexBufferBinding
        }
    }

    /// Vertex element collection.
    var vertexElements: [VertexElement] {
        get {
            _vertexElements
        }
    }

    /// Set vertex elements.
    /// - Parameter elements: Vertex element collection
    func setVertexElements(_ elements: [VertexElement]) {
        _setVertexElements(elements)
    }

    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBufferBindings: Vertex buffer binding
    ///   - index: Vertex buffer index, the default value is 0
    func setVertexBufferBinding(_ vertexBufferBinding: VertexBufferBinding, _ index: Int = 0) {
        if _vertexBufferBindings.count <= index {
            _vertexBufferBindings.reserveCapacity(index + 1)
            for _ in _vertexBufferBindings.count...index {
                _vertexBufferBindings.append(nil)
            }
        }
        _setVertexBufferBinding(index, vertexBufferBinding)
    }

    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBuffer: Vertex buffer
    ///   - stride: Vertex buffer data stride
    ///   - index: Vertex buffer index, the default value is 0
    func setVertexBufferBinding(vertexBuffer: MTLBuffer, stride: Int, index: Int = 0) {
        let binding = VertexBufferBinding(vertexBuffer, stride)
        if _vertexBufferBindings.count <= index {
            _vertexBufferBindings.reserveCapacity(index + 1)
            for _ in _vertexBufferBindings.count...index {
                _vertexBufferBindings.append(nil)
            }
        }
        _setVertexBufferBinding(index, binding)
    }

    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBufferBindings: Vertex buffer binding
    ///   - firstIndex: First vertex buffer index, the default value is 0
    func setVertexBufferBindings(vertexBufferBindings: [VertexBufferBinding], firstIndex: Int = 0) {
        let count = vertexBufferBindings.count
        let needLength = firstIndex + count
        if _vertexBufferBindings.count < needLength {
            _vertexBufferBindings.reserveCapacity(needLength)
            for _ in _vertexBufferBindings.count..<needLength {
                _vertexBufferBindings.append(nil)
            }
        }
        for i in 0..<count {
            _setVertexBufferBinding(firstIndex + i, vertexBufferBindings[i])
        }
    }
    
    /// Set index buffer binding.
    /// - Parameters:
    ///   - buffer: Index buffer
    ///   - format: Index buffer format
    func setIndexBufferBinding(buffer: MTLBuffer, format: MTLIndexType) {
        let binding = IndexBufferBinding(buffer, format)
        _setIndexBufferBinding(binding)
    }

    /// Set index buffer binding.
    /// - Parameter bufferBinding: Index buffer binding
    /// - Remark: When bufferBinding is null, it will clear IndexBufferBinding
    func setIndexBufferBinding(bufferBinding: IndexBufferBinding?) {
        _setIndexBufferBinding(bufferBinding)
    }
}
