//
//  PrimitiveMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Used to generate common primitive meshes.
class PrimitiveMesh {
    /// Create a cuboid mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - width: Cuboid width
    ///   - height: Cuboid height
    ///   - depth: Cuboid depth
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Cuboid model mesh
    static func createCuboid(
        engine: Engine,
        width: Float = 1,
        height: Float = 1,
        depth: Float = 1,
        noLongerAccessible: Bool = true
    )-> ModelMesh {
        fatalError("TODO")
    }

}
