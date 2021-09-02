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
    ) -> ModelMesh {
        let mesh = ModelMesh(engine: engine)

        let halfWidth: Float = width / 2
        let halfHeight: Float = height / 2
        let halfDepth: Float = depth / 2

        var positions: [Vector3] = [Vector3](repeating: Vector3(), count: 24)
        var normals: [Vector3] = [Vector3](repeating: Vector3(), count: 24)
        var uvs: [Vector2] = [Vector2](repeating: Vector2(), count: 24)

        // Up
        positions[0] = Vector3(-halfWidth, halfHeight, -halfDepth)
        positions[1] = Vector3(halfWidth, halfHeight, -halfDepth)
        positions[2] = Vector3(halfWidth, halfHeight, halfDepth)
        positions[3] = Vector3(-halfWidth, halfHeight, halfDepth)
        normals[0] = Vector3(0, 1, 0)
        normals[1] = Vector3(0, 1, 0)
        normals[2] = Vector3(0, 1, 0)
        normals[3] = Vector3(0, 1, 0)
        uvs[0] = Vector2(0, 0)
        uvs[1] = Vector2(1, 0)
        uvs[2] = Vector2(1, 1)
        uvs[3] = Vector2(0, 1)
        // Down
        positions[4] = Vector3(-halfWidth, -halfHeight, -halfDepth)
        positions[5] = Vector3(halfWidth, -halfHeight, -halfDepth)
        positions[6] = Vector3(halfWidth, -halfHeight, halfDepth)
        positions[7] = Vector3(-halfWidth, -halfHeight, halfDepth)
        normals[4] = Vector3(0, -1, 0)
        normals[5] = Vector3(0, -1, 0)
        normals[6] = Vector3(0, -1, 0)
        normals[7] = Vector3(0, -1, 0)
        uvs[4] = Vector2(0, 1)
        uvs[5] = Vector2(1, 1)
        uvs[6] = Vector2(1, 0)
        uvs[7] = Vector2(0, 0)
        // Left
        positions[8] = Vector3(-halfWidth, halfHeight, -halfDepth)
        positions[9] = Vector3(-halfWidth, halfHeight, halfDepth)
        positions[10] = Vector3(-halfWidth, -halfHeight, halfDepth)
        positions[11] = Vector3(-halfWidth, -halfHeight, -halfDepth)
        normals[8] = Vector3(-1, 0, 0)
        normals[9] = Vector3(-1, 0, 0)
        normals[10] = Vector3(-1, 0, 0)
        normals[11] = Vector3(-1, 0, 0)
        uvs[8] = Vector2(0, 0)
        uvs[9] = Vector2(1, 0)
        uvs[10] = Vector2(1, 1)
        uvs[11] = Vector2(0, 1)
        // Right
        positions[12] = Vector3(halfWidth, halfHeight, -halfDepth)
        positions[13] = Vector3(halfWidth, halfHeight, halfDepth)
        positions[14] = Vector3(halfWidth, -halfHeight, halfDepth)
        positions[15] = Vector3(halfWidth, -halfHeight, -halfDepth)
        normals[12] = Vector3(1, 0, 0)
        normals[13] = Vector3(1, 0, 0)
        normals[14] = Vector3(1, 0, 0)
        normals[15] = Vector3(1, 0, 0)
        uvs[12] = Vector2(1, 0)
        uvs[13] = Vector2(0, 0)
        uvs[14] = Vector2(0, 1)
        uvs[15] = Vector2(1, 1)
        // Front
        positions[16] = Vector3(-halfWidth, halfHeight, halfDepth)
        positions[17] = Vector3(halfWidth, halfHeight, halfDepth)
        positions[18] = Vector3(halfWidth, -halfHeight, halfDepth)
        positions[19] = Vector3(-halfWidth, -halfHeight, halfDepth)
        normals[16] = Vector3(0, 0, 1)
        normals[17] = Vector3(0, 0, 1)
        normals[18] = Vector3(0, 0, 1)
        normals[19] = Vector3(0, 0, 1)
        uvs[16] = Vector2(0, 0)
        uvs[17] = Vector2(1, 0)
        uvs[18] = Vector2(1, 1)
        uvs[19] = Vector2(0, 1)
        // Back
        positions[20] = Vector3(-halfWidth, halfHeight, -halfDepth)
        positions[21] = Vector3(halfWidth, halfHeight, -halfDepth)
        positions[22] = Vector3(halfWidth, -halfHeight, -halfDepth)
        positions[23] = Vector3(-halfWidth, -halfHeight, -halfDepth)
        normals[20] = Vector3(0, 0, -1)
        normals[21] = Vector3(0, 0, -1)
        normals[22] = Vector3(0, 0, -1)
        normals[23] = Vector3(0, 0, -1)
        uvs[20] = Vector2(1, 0)
        uvs[21] = Vector2(0, 0)
        uvs[22] = Vector2(0, 1)
        uvs[23] = Vector2(1, 1)

        var indices = [UInt32](repeating: 0, count: 36)

        // prettier-ignore
        // Up
        indices[0] = 0
        indices[1] = 2
        indices[2] = 1
        indices[3] = 2
        indices[4] = 0
        indices[5] = 3
        // Down
        indices[6] = 4
        indices[7] = 6
        indices[8] = 7
        indices[9] = 6
        indices[10] = 4
        indices[11] = 5
        // Left
        indices[12] = 8
        indices[13] = 10
        indices[14] = 9
        indices[15] = 10
        indices[16] = 8
        indices[17] = 11
        // Right
        indices[18] = 12
        indices[19] = 14
        indices[20] = 15
        indices[21] = 14
        indices[22] = 12
        indices[23] = 13
        // Front
        indices[24] = 16
        indices[25] = 18
        indices[26] = 17
        indices[27] = 18
        indices[28] = 16
        indices[29] = 19
        // Back
        indices[30] = 20
        indices[31] = 22
        indices[32] = 23
        indices[33] = 22
        indices[34] = 20
        indices[35] = 21

        let bounds = mesh.bounds
        _ = bounds.min.setValue(x: -halfWidth, y: -halfHeight, z: -halfDepth)
        _ = bounds.max.setValue(x: halfWidth, y: halfHeight, z: halfDepth)

        PrimitiveMesh._initialize(mesh: mesh, positions: positions, normals: normals, uvs: uvs,
                indices: indices, noLongerAccessible: noLongerAccessible)
        return mesh
    }

    private static func _initialize(mesh: ModelMesh,
                                    positions: [Vector3],
                                    normals: [Vector3],
                                    uvs: [Vector2],
                                    indices: [UInt32],
                                    noLongerAccessible: Bool) {
        mesh.setPositions(positions: positions)
        mesh.setNormals(normals: normals)
        mesh.setUVs(uv: uvs)
        mesh.setIndices(indices: .u32(indices))

        mesh.uploadData(noLongerAccessible: noLongerAccessible)
        _ = mesh.addSubMesh(start: 0, count: indices.count)
    }
}
