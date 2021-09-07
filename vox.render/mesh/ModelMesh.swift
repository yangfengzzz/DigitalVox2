//
//  ModelMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Metal

enum IndexArrayType {
    case u16([UInt16])
    case u32([UInt32])
}

class ModelMesh: Mesh {
    private var _vertexCount: Int = 0
    private var _accessible: Bool = true
    private var _verticesFloat32: [Float]? = nil
    private var _verticesUint8: [UInt8]? = nil
    private var _indices: IndexArrayType? = nil
    private var _indicesFormat: MTLIndexType? = nil
    private var _vertexSlotChanged: Bool = true
    private var _vertexChangeFlag: Int = 0
    private var _indicesChangeFlag: Bool = false
    private var _elementCount: Int = 0
    private var _vertexElementsCache: [VertexElement] = []

    private var _positions: [Vector3] = []
    private var _normals: [Vector3]? = nil
    private var _colors: [Color]? = nil
    private var _tangents: [Vector4]? = nil
    private var _uv: [Vector2]? = nil
    private var _uv1: [Vector2]? = nil
    private var _uv2: [Vector2]? = nil
    private var _uv3: [Vector2]? = nil
    private var _uv4: [Vector2]? = nil
    private var _uv5: [Vector2]? = nil
    private var _uv6: [Vector2]? = nil
    private var _uv7: [Vector2]? = nil
    private var _boneWeights: [Vector4]? = nil
    private var _boneIndices: [Vector4]? = nil

    /// Whether to access data of the mesh.
    var accessible: Bool {
        get {
            _accessible
        }
    }

    /// Vertex count of current mesh.
    var vertexCount: Int {
        get {
            _vertexCount
        }
    }

    /// Create a model mesh.
    /// - Parameters:
    ///   - engine: Engine to which the mesh belongs
    ///   - name: Mesh name
    override init(_ engine: Engine, _ name: String? = nil) {
        super.init(engine)
        self.name = name
    }
}

extension ModelMesh {
    /// Set positions for the mesh.
    /// - Parameter positions: The positions for the mesh.
    func setPositions(positions: [Vector3]) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        let count = positions.count
        _positions = positions
        _vertexChangeFlag |= ValueChanged.Position.rawValue

        if (_vertexCount != count) {
            _vertexCount = count
        }
    }


    /// Get positions for the mesh.
    /// - Remark: Please call the setPositions() method after modification to ensure that the modification takes effect.
    func getPositions() -> [Vector3]? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        return _positions
    }

    /// Set per-vertex normals for the mesh.
    /// - Parameter normals: The normals for the mesh.
    func setNormals(normals: [Vector3]?) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if (normals?.count != _vertexCount) {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_normals != nil ? true : false) != (normals != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Normal.rawValue
        _normals = normals
    }

    /// Get normals for the mesh.
    /// - Remark: Please call the setNormals() method after modification to ensure that the modification takes effect.
    func getNormals() -> [Vector3]? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _normals
    }

    /// Set per-vertex colors for the mesh.
    /// - Parameter colors: The colors for the mesh.
    func setColors(colors: [Color]?) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if (colors?.count != _vertexCount) {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_colors != nil ? true : false) != (colors != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Color.rawValue
        _colors = colors
    }

    /// Get colors for the mesh.
    /// - Remark: Please call the setColors() method after modification to ensure that the modification takes effect.
    func getColors() -> [Color]? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _colors
    }

    /// Set per-vertex tangents for the mesh.
    /// - Parameter tangents: The tangents for the mesh.
    func setTangents(tangents: [Vector4]?) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if (tangents?.count != _vertexCount) {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_tangents != nil ? true : false) != (tangents != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Tangent.rawValue
        _tangents = tangents
    }

    /// Get tangents for the mesh.
    /// - Remark: Please call the setTangents() method after modification to ensure that the modification takes effect.
    func getTangents() -> [Vector4]? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _tangents
    }

    /// Set per-vertex uv for the mesh by channelIndex.
    /// - Parameters:
    ///   - uv: The uv for the mesh.
    ///   - channelIndex: The index of uv channels, in [0 ~ 7] range.
    func setUVs(uv: [Vector2]?, channelIndex: Int? = nil) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if (uv?.count != _vertexCount) {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        let channelIndex = channelIndex ?? 0
        switch (channelIndex) {
        case 0:
            _vertexSlotChanged = (_uv != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV.rawValue
            _uv = uv
            break
        case 1:
            _vertexSlotChanged = (_uv1 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV1.rawValue
            _uv1 = uv
            break
        case 2:
            _vertexSlotChanged = (_uv2 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV2.rawValue
            _uv2 = uv
            break
        case 3:
            _vertexSlotChanged = (_uv3 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV3.rawValue
            _uv3 = uv
            break
        case 4:
            _vertexSlotChanged = (_uv4 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV4.rawValue
            _uv4 = uv
            break
        case 5:
            _vertexSlotChanged = (_uv5 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV5.rawValue
            _uv5 = uv
            break
        case 6:
            _vertexSlotChanged = (_uv6 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV6.rawValue
            _uv6 = uv
            break
        case 7:
            _vertexSlotChanged = (_uv7 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV7.rawValue
            _uv7 = uv
            break
        default:
            fatalError("The index of channel needs to be in range [0 - 7].")
        }
    }

    /// Get uv for the mesh by channelIndex.
    /// - Parameter channelIndex: The index of uv channels, in [0 ~ 7] range.
    /// - Remark: Please call the setUV() method after modification to ensure that the modification takes effect.
    func getUVs(channelIndex: Int? = nil) -> [Vector2]? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }
        let channelIndex = channelIndex ?? 0
        switch (channelIndex) {
        case 0:
            return _uv
        case 1:
            return _uv1
        case 2:
            return _uv2
        case 3:
            return _uv3
        case 4:
            return _uv4
        case 5:
            return _uv5
        case 6:
            return _uv6
        case 7:
            return _uv7
        default:
            fatalError("The index of channel needs to be in range [0 - 7].")
        }
    }

    /// Set indices for the mesh.
    /// - Parameter indices: The indices for the mesh.
    func setIndices(indices: IndexArrayType) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        _indices = indices
        switch indices {
        case .u16(_):
            _indicesFormat = .uint16
        case .u32(_):
            _indicesFormat = .uint32
        }

        _indicesChangeFlag = true
    }

    /// Get indices for the mesh.
    func getIndices() -> IndexArrayType? {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        return _indices
    }


    /// Upload Mesh Data to the graphics API.
    /// - Parameter noLongerAccessible: Whether to access data later. If true, you'll never access data anymore (free memory cache)
    func uploadData(noLongerAccessible: Bool) {
        if (!_accessible) {
            fatalError("Not allowed to access data while accessible is false.")
        }

        // Vertex element change.
        if (_vertexSlotChanged) {
            let vertexElements = _updateVertexElements()
            _setVertexElements(elements: vertexElements)
            _vertexChangeFlag = ValueChanged.All.rawValue
            _vertexSlotChanged = false
        }

        // Vertex value change.
        let elementCount = _elementCount
        let vertexFloatCount = elementCount * _vertexCount
        var vertices = [Float](repeating: 0, count: vertexFloatCount)
        _verticesFloat32 = vertices

        _vertexChangeFlag = ValueChanged.All.rawValue
        _updateVertices(vertices: &vertices)
        
        let vertexBuffer = Engine.device.makeBuffer(bytes: &vertices, length: vertexFloatCount * MemoryLayout<Float>.stride)
        engine.renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(BufferIndexVertices.rawValue))
        switch _indices {
        case .u16(let value):
            let indexBuffer = Engine.device.makeBuffer(bytes: value, length: value.count * MemoryLayout<UInt16>.stride,
                                                       options: .storageModeShared)
            engine.renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: value.count, indexType: .uint16,
                    indexBuffer: indexBuffer!, indexBufferOffset: 0)
        case .u32(let value):
            let indexBuffer = Engine.device.makeBuffer(bytes: value, length: value.count * MemoryLayout<UInt32>.stride,
                                                       options: .storageModeShared)
            engine.renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: value.count, indexType: .uint32,
                    indexBuffer: indexBuffer!, indexBufferOffset: 0)

        default:
            fatalError()
        }
    }

    private func _updateVertexElements() -> [VertexElement] {
        var vertexElements = _vertexElementsCache
        vertexElements.append(POSITION_VERTEX_ELEMENT)

        var offset = 12
        var elementCount = 3
        if (_normals != nil) {
            vertexElements.append(VertexElement(semantic: "NORMAL", offset: offset, format: .float3, bindingIndex: 0))
            offset += 12
            elementCount += 3
        }
        if (_colors != nil) {
            vertexElements.append(VertexElement(semantic: "COLOR_0", offset: offset, format: .float4, bindingIndex: 0))
            offset += 16
            elementCount += 4
        }
        if (_boneWeights != nil) {
            vertexElements.append(VertexElement(semantic: "WEIGHTS_0", offset: offset, format: .float4, bindingIndex: 0))
            offset += 16
            elementCount += 4
        }
        if (_boneIndices != nil) {
            vertexElements.append(VertexElement(semantic: "JOINTS_0", offset: offset, format: .short4, bindingIndex: 0))
            offset += 4
            elementCount += 1
        }
        if (_tangents != nil) {
            vertexElements.append(VertexElement(semantic: "TANGENT", offset: offset, format: .float4, bindingIndex: 0))
            offset += 16
            elementCount += 4
        }
        if (_uv != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_0", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv1 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_1", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv2 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_2", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv3 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_3", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv4 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_4", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv5 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_5", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv6 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_6", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }
        if (_uv7 != nil) {
            vertexElements.append(VertexElement(semantic: "TEXCOORD_7", offset: offset, format: .float2, bindingIndex: 0))
            offset += 8
            elementCount += 2
        }


        _elementCount = elementCount
        return vertexElements
    }

    private func _updateVertices(vertices: inout [Float32]) {
        if (_vertexChangeFlag & ValueChanged.Position.rawValue != 0) {
            for i in 0..<_vertexCount {
                let start = _elementCount * i
                let position = _positions[i]
                vertices[start] = position.x
                vertices[start + 1] = position.y
                vertices[start + 2] = position.z
            }
        }

        var offset = 3

        if (_normals != nil) {
            if (_vertexChangeFlag & ValueChanged.Normal.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let normal = _normals![i]
                    vertices[start] = normal.x
                    vertices[start + 1] = normal.y
                    vertices[start + 2] = normal.z
                }
            }
            offset += 3
        }

        if (_colors != nil) {
            if (_vertexChangeFlag & ValueChanged.Color.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let color = _colors![i]
                    vertices[start] = color.r
                    vertices[start + 1] = color.g
                    vertices[start + 2] = color.b
                    vertices[start + 3] = color.a

                }
            }
            offset += 4
        }

        if (_tangents != nil) {
            if (_vertexChangeFlag & ValueChanged.Tangent.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let tangent = _tangents![i]
                    vertices[start] = tangent.x
                    vertices[start + 1] = tangent.y
                    vertices[start + 2] = tangent.z

                }
            }
            offset += 4
        }
        if (_uv != nil) {
            if (_vertexChangeFlag & ValueChanged.UV.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if (_uv1 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV1.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv1![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv2 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV2.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv2![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv3 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV3.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv3![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv4 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV4.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv4![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv5 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV5.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv5![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv6 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV6.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv6![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }
        if (_uv7 != nil) {
            if (_vertexChangeFlag & ValueChanged.UV7.rawValue != 0) {
                for i in 0..<_vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv7![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y

                }
            }
            offset += 2
        }

        _vertexChangeFlag = 0
    }

    private func _releaseCache() {
        _verticesUint8 = nil
        _indices = nil
        _verticesFloat32 = nil
        _positions = []
        _tangents = nil
        _normals = nil
        _colors = nil
        _uv = nil
        _uv1 = nil
        _uv2 = nil
        _uv3 = nil
        _uv4 = nil
        _uv5 = nil
        _uv6 = nil
        _uv7 = nil
    }
}

let POSITION_VERTEX_ELEMENT = VertexElement(semantic: "POSITION", offset: 0, format: .float3, bindingIndex: 0)

enum ValueChanged: Int {
    case Position = 0x1
    case Normal = 0x2
    case Color = 0x4
    case Tangent = 0x8
    case BoneWeight = 0x10
    case BoneIndex = 0x20
    case UV = 0x40
    case UV1 = 0x80
    case UV2 = 0x100
    case UV3 = 0x200
    case UV4 = 0x400
    case UV5 = 0x800
    case UV6 = 0x1000
    case UV7 = 0x2000
    case BlendShape = 0x4000
    case All = 0xffff
}
