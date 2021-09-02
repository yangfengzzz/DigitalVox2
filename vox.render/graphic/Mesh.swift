//
//  Mesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Metal

class Mesh: RefObject {
    /// Name.
    var name: String?
    /// The bounding volume of the mesh.
    var bounds: BoundingBox = BoundingBox()

    var _vertexElementMap: [String: VertexElement] = [:]

    internal var _instanceCount: Int = 0
    internal var _vertexElements: [VertexElement] = []

    private var _subMeshes: [SubMesh] = []
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()

    /// Create mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Mesh name
    init(engine: Engine, name: String? = nil) {
        super.init(engine: engine)
        self.name = name
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameter subMesh: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    /// - Returns: Sub-mesh
    func addSubMesh(subMesh: SubMesh) -> SubMesh {
        _subMeshes.append(subMesh)
        return subMesh
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameters:
    ///   - start: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    ///   - count: Drawing count, if the index buffer is set, it means the count in the index buffer, if not set, it means the count in the vertex buffer
    ///   - topology: Drawing topology, default is MeshTopology.Triangles
    /// - Returns: Sub-mesh
    func addSubMesh(start: Int, count: Int, topology: MTLPrimitiveType? = nil) -> SubMesh {
        let startOrSubMesh = SubMesh(start: start, count: count, topology: topology)
        _subMeshes.append(startOrSubMesh)
        return startOrSubMesh
    }

    func _setVertexElements(elements: [VertexElement]) {
        _clearVertexElements()
        for i in 0..<elements.count {
            _addVertexElement(element: elements[i])
        }
    }

    private func _clearVertexElements() {
        _vertexElements = []
        _vertexElementMap = [:]
    }

    private func _addVertexElement(element: VertexElement) {
        let semantic = element.semantic
        _vertexElementMap[semantic] = element
        _vertexElements.append(element)
        _updateFlagManager.distribute()
    }
}
