//
//  VertexElement.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import ModelIO

class VertexElement {
    /// Vertex semantic.
    var semantic: String
    /// Vertex data byte offset.
    var offset: Int
    /// Vertex data format.
    var format: MDLVertexFormat
    /// Vertex buffer binding index.
    var bindingIndex: Int
    /// Instance cadence, the number of instances drawn for each vertex in the buffer, non-instance elements must be 0.
    var instanceStepRate: Float
    
    /// Create vertex element.
    /// - Parameters:
    ///   - semantic: Input vertex semantic
    ///   - offset: Vertex data byte offset
    ///   - format: Vertex data format
    ///   - bindingIndex: Vertex buffer binding index
    ///   - instanceStepRate: Instance cadence, the number of instances drawn for each vertex in the buffer, non-instance elements must be 0.
    init(semantic: String,
         offset: Int,
         format: MDLVertexFormat,
         bindingIndex: Int,
         instanceStepRate: Float = 0) {
        self.semantic = semantic
        self.offset = offset
        self.format = format
        self.bindingIndex = bindingIndex
        self.instanceStepRate = floor(instanceStepRate)
    }
}
