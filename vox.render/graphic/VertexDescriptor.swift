//
//  VertexDescriptor.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import MetalKit

class VertexDescriptor {
    var _descriptor: MDLVertexDescriptor

    var descriptor: MDLVertexDescriptor {
        get {
            _descriptor
        }
    }

    init(_ descriptor: MDLVertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor) {
        _descriptor = descriptor
    }
}

extension MDLVertexDescriptor {
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0

        // position attribute
        vertexDescriptor.attributes[Int(Position.rawValue)]
                = MDLVertexAttribute(name: MDLVertexAttributePosition,
                format: .float3,
                offset: 0,
                bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 3

        // normal attribute
        vertexDescriptor.attributes[Int(Normal.rawValue)] =
                MDLVertexAttribute(name: MDLVertexAttributeNormal,
                        format: .float3,
                        offset: offset,
                        bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 3

        // uv attribute
        vertexDescriptor.attributes[Int(UV_0.rawValue)] =
                MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                        format: .float2,
                        offset: offset,
                        bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<Float>.stride * 2

        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }()
}
