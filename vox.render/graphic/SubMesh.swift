//
//  SubMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Metal

/// Sub-mesh, mainly contains drawing information.
class SubMesh {
    /// Start drawing offset.
    var start: Int
    /// Drawing count.
    var count: Int
    /// Drawing topology.
    var topology: MTLPrimitiveType

    /// Create a sub-mesh.
    /// - Parameters:
    ///   - start: Start drawing offset
    ///   - count: Drawing count
    ///   - topology: Drawing topology
    init(start: Int = 0, count: Int = 0, topology: MTLPrimitiveType? = nil) {
        self.start = start
        self.count = count
        self.topology = topology ?? .triangle
    }
}
