//
//  SubMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Metal

/// Sub-mesh, mainly contains drawing information.
class SubMesh {
    /// Drawing topology.
    var topology: MTLPrimitiveType
    /// Type of index buffer
    var indexType: MTLIndexType
    /// IndexBuffer
    var indexBuffer: MeshBuffer?
    /// Drawing count.
    var indexCount: Int


    /// Create a sub-mesh.
    /// - Parameters:
    ///   - indexBuffer: Index Buffer
    ///   - indexType: Index Type
    ///   - indexCount: Drawing count
    ///   - topology: Drawing topology
    init(_ indexBuffer: MeshBuffer, _ indexType: MTLIndexType,
         _ indexCount: Int = 0, _ topology: MTLPrimitiveType = .triangle) {
        self.indexBuffer = indexBuffer
        self.indexType = indexType

        self.indexCount = indexCount
        self.topology = topology
    }
}
