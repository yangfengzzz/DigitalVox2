//
//  Mesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import MetalKit

class Mesh: RefObject {
    /// Name.
    var name: String?
    /// The bounding volume of the mesh.
    var bounds: BoundingBox = BoundingBox()

    var _vertexBuffer: [MeshBuffer?] = []
    var _vertexCount: Int = 0
    var _vertexDescriptor: VertexDescriptor = VertexDescriptor()
    var _subMeshes: [SubMesh] = []

    internal var _instanceCount: Int = 0
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()

    /// First sub-mesh. Rendered using the first material.
    var subMesh: SubMesh? {
        get {
            _subMeshes.first
        }
    }

    /// A collection of sub-mesh, each sub-mesh can be rendered with an independent material.
    var subMeshes: [SubMesh] {
        get {
            _subMeshes
        }
    }

    /// Create mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Mesh name
    init(_ engine: Engine, _ name: String? = nil) {
        super.init(engine)
        self.name = name
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameter subMesh: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    /// - Returns: Sub-mesh
    func addSubMesh(_ subMesh: SubMesh) -> SubMesh {
        _subMeshes.append(subMesh)
        return subMesh
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameters:
    ///   - start: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    ///   - count: Drawing count, if the index buffer is set, it means the count in the index buffer, if not set, it means the count in the vertex buffer
    ///   - topology: Drawing topology, default is MeshTopology.Triangles
    /// - Returns: Sub-mesh
    func addSubMesh(_ indexBuffer: MeshBuffer, _ indexType: MTLIndexType,
                    _ indexCount: Int = 0, _ topology: MTLPrimitiveType = .triangle) -> SubMesh {
        let startOrSubMesh = SubMesh(indexBuffer, indexType, indexCount, topology)
        _subMeshes.append(startOrSubMesh)
        return startOrSubMesh
    }

    /// Clear all sub-mesh.
    func clearSubMesh() {
        _subMeshes = []
    }

    /// Register update flag, update flag will be true if the vertex element changes.
    /// - Returns: Update flag
    func registerUpdateFlag() -> UpdateFlag {
        _updateFlagManager.register()
    }

    func _setVertexBuffer(_ index: Int, _ buffer: MeshBuffer) {
        _vertexBuffer.insert(buffer, at: index)
    }
}
