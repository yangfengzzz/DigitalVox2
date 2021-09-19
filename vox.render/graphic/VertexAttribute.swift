//
//  VertexAttribute.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import ModelIO

class VertexAttribute {
    /// Vertex semantic.
    var semantic: String
    /// Vertex data format.
    var format: MDLVertexFormat
    /// Vertex data byte offset.
    var offset: Int
    /// Vertex buffer binding index.
    var bufferIndex: Int
    /// Instance cadence, the number of instances drawn for each vertex in the buffer, non-instance elements must be 0.
    var time: Float
    
    /// Create vertex attribute.
    /// - Parameters:
    ///   - semantic: Input vertex semantic
    ///   - offset: Vertex data byte offset
    ///   - format: Vertex data format
    ///   - bufferIndex: Vertex buffer binding index
    ///   - time: Instance cadence, the number of instances drawn for each vertex in the buffer, non-instance elements must be 0.
    init(semantic: String,
         format: MDLVertexFormat,
         offset: Int,
         bufferIndex: Int,
         time: Float = 0) {
        self.semantic = semantic
        self.offset = offset
        self.format = format
        self.bufferIndex = bufferIndex
        self.time = time
    }
}
