//
//  PrimitiveMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Used to generate common primitive meshes.
class PrimitiveMesh {
    /// Create a sphere mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - radius: Sphere radius
    ///   - segments: Number of segments
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Sphere model mesh
    static func createSphere(_ engine: Engine,
                             _ radius: Float = 0.5,
                             _ segments: Int = 18,
                             _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)
        let segments = max(2, segments)

        let count = segments + 1
        let vertexCount = count * count
        let rectangleCount = segments * segments
        var indices = PrimitiveMesh._generateIndices(engine, vertexCount, rectangleCount * 6)
        let thetaRange = Float.pi
        let alphaRange = thetaRange * 2
        let countReciprocal = 1.0 / Float(count)
        let segmentsReciprocal = 1.0 / Float(segments)

        var positions: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var normals: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var uvs: [Vector2] = .init(repeating: Vector2(), count: vertexCount)

        for i in 0..<vertexCount {
            let x = i % count
            let y = Int(Float(i) * countReciprocal) | 0
            let u = Float(x) * segmentsReciprocal
            let v = Float(y) * segmentsReciprocal
            let alphaDelta = u * alphaRange
            let thetaDelta = v * thetaRange
            let sinTheta = sin(thetaDelta)

            let posX = -radius * cos(alphaDelta) * sinTheta
            let posY = radius * cos(thetaDelta)
            let posZ = radius * sin(alphaDelta) * sinTheta

            // Position
            positions[i] = Vector3(posX, posY, posZ)
            // Normal
            normals[i] = Vector3(posX, posY, posZ)
            // Texcoord
            uvs[i] = Vector2(u, v)
        }

        var offset = 0
        for i in 0..<rectangleCount {
            let x = i % segments
            let y = Int(Float(i) * countReciprocal) | 0

            let a = y * count + x
            let b = a + 1
            let c = a + count
            let d = c + 1

            indices[offset] = UInt32(b)
            offset += 1
            indices[offset] = UInt32(a)
            offset += 1
            indices[offset] = UInt32(d)
            offset += 1
            indices[offset] = UInt32(a)
            offset += 1
            indices[offset] = UInt32(c)
            offset += 1
            indices[offset] = UInt32(d)
            offset += 1
        }

        let bounds = mesh.bounds
        _ = bounds.min.setValue(x: -radius, y: -radius, z: -radius)
        _ = bounds.max.setValue(x: radius, y: radius, z: radius)

        PrimitiveMesh._initialize(mesh, positions, normals, uvs, indices, noLongerAccessible)
        return mesh
    }

    /// Create a cuboid mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - width: Cuboid width
    ///   - height: Cuboid height
    ///   - depth: Cuboid depth
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Cuboid model mesh
    static func createCuboid(_ engine: Engine,
                             _ width: Float = 1,
                             _ height: Float = 1,
                             _ depth: Float = 1,
                             _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)

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

        PrimitiveMesh._initialize(mesh, positions, normals, uvs,
                indices, noLongerAccessible)
        return mesh
    }

    /// Create a plane mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - width: Plane width
    ///   - height: Plane height
    ///   - horizontalSegments: Plane horizontal segments
    ///   - verticalSegments: Plane vertical segments
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Plane model mesh
    static func createPlane(_ engine: Engine,
                            _ width: Float = 1,
                            _ height: Float = 1,
                            _ horizontalSegments: Int = 1,
                            _ verticalSegments: Int = 1,
                            _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)
        let horizontalSegments = max(1, horizontalSegments)
        let verticalSegments = max(1, verticalSegments)

        let horizontalCount = horizontalSegments + 1
        let verticalCount = verticalSegments + 1
        let halfWidth = width / 2
        let halfHeight = height / 2
        let gridWidth = width / Float(horizontalSegments)
        let gridHeight = height / Float(verticalSegments)
        let vertexCount = horizontalCount * verticalCount
        let rectangleCount = verticalSegments * horizontalSegments
        var indices = PrimitiveMesh._generateIndices(engine, vertexCount, rectangleCount * 6)
        let horizontalCountReciprocal = 1.0 / Float(horizontalCount)
        let horizontalSegmentsReciprocal = 1.0 / Float(horizontalSegments)
        let verticalSegmentsReciprocal = 1.0 / Float(verticalSegments)

        var positions: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var normals: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var uvs: [Vector2] = .init(repeating: Vector2(), count: vertexCount)

        for i in 0..<vertexCount {
            let x = i % horizontalCount
            let y = Int(Float(i) * horizontalCountReciprocal) | 0

            // Position
            positions[i] = Vector3(Float(x) * gridWidth - halfWidth, Float(y) * gridHeight - halfHeight, 0)
            // Normal
            normals[i] = Vector3(0, 0, 1)
            // Texcoord
            uvs[i] = Vector2(Float(x) * horizontalSegmentsReciprocal, 1 - Float(y) * verticalSegmentsReciprocal)
        }

        var offset = 0
        for i in 0..<rectangleCount {
            let x = i % horizontalSegments
            let y = Int(Float(i) * horizontalCountReciprocal) | 0

            let a = y * horizontalCount + x
            let b = a + 1
            let c = a + horizontalCount
            let d = c + 1

            indices[offset] = UInt32(b)
            offset += 1
            indices[offset] = UInt32(c)
            offset += 1
            indices[offset] = UInt32(a)
            offset += 1
            indices[offset] = UInt32(b)
            offset += 1
            indices[offset] = UInt32(d)
            offset += 1
            indices[offset] = UInt32(c)
            offset += 1
        }

        let bounds = mesh.bounds
        _ = bounds.min.setValue(x: -halfWidth, y: -halfHeight, z: 0)
        _ = bounds.max.setValue(x: halfWidth, y: halfHeight, z: 0)

        PrimitiveMesh._initialize(mesh, positions, normals, uvs, indices, noLongerAccessible)
        return mesh
    }

    /// Create a cylinder mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - radiusTop: The radius of top cap
    ///   - radiusBottom: The radius of bottom cap
    ///   - height: The height of torso
    ///   - radialSegments: Cylinder radial segments
    ///   - heightSegments: Cylinder height segments
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Cylinder model mesh
    static func createCylinder(_ engine: Engine,
                               _ radiusTop: Float = 0.5,
                               _ radiusBottom: Float = 0.5,
                               _ height: Float = 2,
                               _ radialSegments: Int = 20,
                               _ heightSegments: Int = 1,
                               _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)

        let radialCount = radialSegments + 1
        let verticalCount = heightSegments + 1
        let halfHeight = height * 0.5
        let unitHeight = height / Float(heightSegments)
        let torsoVertexCount = radialCount * verticalCount
        let torsoRectangleCount = radialSegments * heightSegments
        let capTriangleCount = radialSegments * 2
        let totalVertexCount = torsoVertexCount + 2 + capTriangleCount
        var indices = PrimitiveMesh._generateIndices(
                engine,
                totalVertexCount,
                torsoRectangleCount * 6 + capTriangleCount * 3
        )
        let radialCountReciprocal = 1.0 / Float(radialCount)
        let radialSegmentsReciprocal = 1.0 / Float(radialSegments)
        let heightSegmentsReciprocal = 1.0 / Float(heightSegments)

        var positions: [Vector3] = .init(repeating: Vector3(), count: totalVertexCount)
        var normals: [Vector3] = .init(repeating: Vector3(), count: totalVertexCount)
        var uvs: [Vector2] = .init(repeating: Vector2(), count: totalVertexCount)

        var indicesOffset = 0

        // Create torso
        let thetaStart = Float.pi
        let thetaRange = Float.pi * 2
        let slope = (radiusBottom - radiusTop) / height

        for i in 0..<torsoVertexCount {
            let x = i % radialCount
            let y = Int(Float(i) * radialCountReciprocal) | 0
            let u = Float(x) * radialSegmentsReciprocal
            let v = Float(y) * heightSegmentsReciprocal
            let theta = thetaStart + u * thetaRange
            let sinTheta = sin(theta)
            let cosTheta = cos(theta)
            let radius = radiusBottom - Float(y) * (radiusBottom - radiusTop)

            let posX = radius * sinTheta
            let posY = Float(y) * unitHeight - halfHeight
            let posZ = radius * cosTheta

            // Position
            positions[i] = Vector3(posX, posY, posZ)
            // Normal
            normals[i] = Vector3(sinTheta, slope, cosTheta)
            // Texcoord
            uvs[i] = Vector2(u, 1 - v)
        }

        for i in 0..<torsoRectangleCount {
            let x = i % radialSegments
            let y = Int(Float(i) * radialSegmentsReciprocal) | 0

            let a = y * radialCount + x
            let b = a + 1
            let c = a + radialCount
            let d = c + 1

            indices[indicesOffset] = UInt32(b)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(c)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(a)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(b)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(d)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(c)
            indicesOffset += 1
        }

        // Bottom position
        positions[torsoVertexCount] = Vector3(0, -halfHeight, 0)
        // Bottom normal
        normals[torsoVertexCount] = Vector3(0, -1, 0)
        // Bottom texcoord
        uvs[torsoVertexCount] = Vector2(0.5, 0.5)

        // Top position
        positions[torsoVertexCount + 1] = Vector3(0, halfHeight, 0)
        // Top normal
        normals[torsoVertexCount + 1] = Vector3(0, 1, 0)
        // Top texcoord
        uvs[torsoVertexCount + 1] = Vector2(0.5, 0.5)

        // Add cap vertices
        var offset = torsoVertexCount + 2

        let diameterTopReciprocal = 1.0 / (radiusTop * 2)
        let diameterBottomReciprocal = 1.0 / (radiusBottom * 2)
        let positionStride = radialCount * heightSegments
        for i in 0..<radialSegments {
            let curPosBottom = positions[i]
            var curPosX = curPosBottom.x
            var curPosZ = curPosBottom.z

            // Bottom position
            positions[offset] = Vector3(curPosX, -halfHeight, curPosZ)
            // Bottom normal
            normals[offset] = Vector3(0, -1, 0)
            // Bottom texcoord
            uvs[offset] = Vector2(curPosX * diameterBottomReciprocal + 0.5, 0.5 - curPosZ * diameterBottomReciprocal)
            offset += 1
            let curPosTop = positions[i + positionStride]
            curPosX = curPosTop.x
            curPosZ = curPosTop.z

            // Top position
            positions[offset] = Vector3(curPosX, halfHeight, curPosZ)
            // Top normal
            normals[offset] = Vector3(0, 1, 0)
            // Top texcoord
            uvs[offset] = Vector2(curPosX * diameterTopReciprocal + 0.5, curPosZ * diameterTopReciprocal + 0.5)
            offset += 1
        }

        // Add cap indices
        let topCapIndex = torsoVertexCount + 1
        let bottomIndiceIndex = torsoVertexCount + 2
        let topIndiceIndex = bottomIndiceIndex + 1
        for i in 0..<radialSegments {
            let firstStride = i * 2
            let secondStride = i == radialSegments - 1 ? 0 : firstStride + 2

            // Bottom
            indices[indicesOffset] = UInt32(torsoVertexCount)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(bottomIndiceIndex + secondStride)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(bottomIndiceIndex + firstStride)
            indicesOffset += 1

            // Top
            indices[indicesOffset] = UInt32(topCapIndex)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(topIndiceIndex + firstStride)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(topIndiceIndex + secondStride)
            indicesOffset += 1
        }

        let bounds = mesh.bounds
        let radiusMax = max(radiusTop, radiusBottom)
        _ = bounds.min.setValue(x: -radiusMax, y: -halfHeight, z: -radiusMax)
        _ = bounds.max.setValue(x: radiusMax, y: halfHeight, z: radiusMax)

        PrimitiveMesh._initialize(mesh, positions, normals, uvs, indices, noLongerAccessible)
        return mesh
    }

    /// Create a torus mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - radius: Torus radius
    ///   - tubeRadius: Torus tube
    ///   - radialSegments: Torus radial segments
    ///   - tubularSegments: Torus tubular segments
    ///   - arc: Central angle
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Torus model mesh
    static func createTorus(_ engine: Engine,
                            _ radius: Float = 0.5,
                            _ tubeRadius: Float = 0.1,
                            _ radialSegments: Int = 30,
                            _ tubularSegments: Int = 30,
                            _ arc: Float = 360,
                            _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)

        let vertexCount = (radialSegments + 1) * (tubularSegments + 1)
        let rectangleCount = radialSegments * tubularSegments
        var indices = PrimitiveMesh._generateIndices(engine, vertexCount, rectangleCount * 6)

        var positions: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var normals: [Vector3] = .init(repeating: Vector3(), count: vertexCount)
        var uvs: [Vector2] = .init(repeating: Vector2(), count: vertexCount)

        let arc = (arc / 180) * Float.pi

        var offset = 0

        for i in 0...radialSegments {
            for j in 0...tubularSegments {
                let u = Float(j / tubularSegments) * arc
                let v = Float(i / radialSegments) * Float.pi * 2
                let cosV = cos(v)
                let sinV = sin(v)
                let cosU = cos(u)
                let sinU = sin(u)

                let position = Vector3(
                        (radius + tubeRadius * cosV) * cosU,
                        (radius + tubeRadius * cosV) * sinU,
                        tubeRadius * sinV
                )
                positions[offset] = position

                let centerX = radius * cosU
                let centerY = radius * sinU
                normals[offset] = Vector3(position.x - centerX, position.y - centerY, position.z).normalize()

                uvs[offset] = Vector2(Float(j / tubularSegments), Float(i / radialSegments))
                offset += 1
            }
        }

        offset = 0
        for i in 1...radialSegments {
            for j in 1...tubularSegments {
                let a = (tubularSegments + 1) * i + j - 1
                let b = (tubularSegments + 1) * (i - 1) + j - 1
                let c = (tubularSegments + 1) * (i - 1) + j
                let d = (tubularSegments + 1) * i + j

                indices[offset] = UInt32(a)
                offset += 1
                indices[offset] = UInt32(b)
                offset += 1
                indices[offset] = UInt32(d)
                offset += 1

                indices[offset] = UInt32(b)
                offset += 1
                indices[offset] = UInt32(c)
                offset += 1
                indices[offset] = UInt32(d)
                offset += 1
            }
        }

        let bounds = mesh.bounds
        let outerRadius = radius + tubeRadius
        _ = bounds.min.setValue(x: -outerRadius, y: -outerRadius, z: -tubeRadius)
        _ = bounds.max.setValue(x: outerRadius, y: outerRadius, z: tubeRadius)

        PrimitiveMesh._initialize(mesh, positions, normals, uvs, indices, noLongerAccessible)
        return mesh
    }

    /// Create a cone mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - radius: The radius of cap
    ///   - height: The height of torso
    ///   - radialSegments: Cylinder radial segments
    ///   - heightSegments: Cylinder height segments
    ///   - noLongerAccessible: No longer access the vertices of the mesh after creation
    /// - Returns: Cone model mesh
    static func createCone(_ engine: Engine,
                           _ radius: Float = 0.5,
                           _ height: Float = 2,
                           _ radialSegments: Int = 20,
                           _ heightSegments: Int = 1,
                           _ noLongerAccessible: Bool = true) -> ModelMesh {
        let mesh = ModelMesh(engine)

        let radialCount = radialSegments + 1
        let verticalCount = heightSegments + 1
        let halfHeight = height * 0.5
        let unitHeight = height / Float(heightSegments)
        let torsoVertexCount = radialCount * verticalCount
        let torsoRectangleCount = radialSegments * heightSegments
        let totalVertexCount = torsoVertexCount + 1 + radialSegments
        var indices = PrimitiveMesh._generateIndices(
                engine,
                totalVertexCount,
                torsoRectangleCount * 6 + radialSegments * 3
        )
        let radialCountReciprocal = 1.0 / Float(radialCount)
        let radialSegmentsReciprocal = 1.0 / Float(radialSegments)
        let heightSegmentsReciprocal = 1.0 / Float(heightSegments)

        var positions: [Vector3] = .init(repeating: Vector3(), count: totalVertexCount)
        var normals: [Vector3] = .init(repeating: Vector3(), count: totalVertexCount)
        var uvs: [Vector2] = .init(repeating: Vector2(), count: totalVertexCount)

        var indicesOffset = 0

        // Create torso
        let thetaStart = Float.pi
        let thetaRange = Float.pi * 2
        let slope = radius / height

        for i in 0..<torsoVertexCount {
            let x = i % radialCount
            let y = Int(Float(i) * radialCountReciprocal) | 0
            let u = Float(x) * radialSegmentsReciprocal
            let v = Float(y) * heightSegmentsReciprocal
            let theta = thetaStart + u * thetaRange
            let sinTheta = sin(theta)
            let cosTheta = cos(theta)
            let curRadius = radius - Float(y) * radius

            let posX = curRadius * sinTheta
            let posY = Float(y) * unitHeight - halfHeight
            let posZ = curRadius * cosTheta

            // Position
            positions[i] = Vector3(posX, posY, posZ)
            // Normal
            normals[i] = Vector3(sinTheta, slope, cosTheta)
            // Texcoord
            uvs[i] = Vector2(u, 1 - v)
        }

        for i in 0..<torsoRectangleCount {
            let x = i % radialSegments
            let y = Int(Float(i) * radialSegmentsReciprocal) | 0

            let a = y * radialCount + x
            let b = a + 1
            let c = a + radialCount
            let d = c + 1

            indices[indicesOffset] = UInt32(b)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(c)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(a)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(b)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(d)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(c)
            indicesOffset += 1
        }

        // Bottom position
        positions[torsoVertexCount] = Vector3(0, -halfHeight, 0)
        // Bottom normal
        normals[torsoVertexCount] = Vector3(0, -1, 0)
        // Bottom texcoord
        uvs[torsoVertexCount] = Vector2(0.5, 0.5)

        // Add bottom cap vertices
        var offset = torsoVertexCount + 1
        let diameterBottomReciprocal = 1.0 / (radius * 2)
        for i in 0..<radialSegments {
            let curPos = positions[i]
            let curPosX = curPos.x
            let curPosZ = curPos.z

            // Bottom position
            positions[offset] = Vector3(curPosX, -halfHeight, curPosZ)
            // Bottom normal
            normals[offset] = Vector3(0, -1, 0)
            // Bottom texcoord
            uvs[offset] = Vector2(curPosX * diameterBottomReciprocal + 0.5, 0.5 - curPosZ * diameterBottomReciprocal)
            offset += 1
        }

        let bottomIndiceIndex = torsoVertexCount + 1
        for i in 0..<radialSegments {
            let firstStride = i
            let secondStride = i == radialSegments - 1 ? 0 : firstStride + 1

            // Bottom
            indices[indicesOffset] = UInt32(torsoVertexCount)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(bottomIndiceIndex + secondStride)
            indicesOffset += 1
            indices[indicesOffset] = UInt32(bottomIndiceIndex + firstStride)
            indicesOffset += 1
        }

        let bounds = mesh.bounds
        _ = bounds.min.setValue(x: -radius, y: -halfHeight, z: -radius)
        _ = bounds.max.setValue(x: radius, y: halfHeight, z: radius)

        PrimitiveMesh._initialize(mesh, positions, normals, uvs, indices, noLongerAccessible)
        return mesh
    }
}

//MARK:- Private Function
extension PrimitiveMesh {
    private static func _initialize(_ mesh: ModelMesh,
                                    _ positions: [Vector3],
                                    _ normals: [Vector3],
                                    _ uvs: [Vector2],
                                    _ indices: [UInt32],
                                    _ noLongerAccessible: Bool) {
        mesh.setPositions(positions: positions)
        mesh.setNormals(normals: normals)
        mesh.setUVs(uv: uvs)
        mesh.setIndices(indices: .u32(indices))

        mesh.uploadData(noLongerAccessible: noLongerAccessible)
        _ = mesh.addSubMesh(0, indices.count)
    }

    private static func _generateIndices(_ engine: Engine, _ vertexCount: Int, _ indexCount: Int) -> [UInt32] {
        [UInt32](repeating: 0, count: indexCount)
    }

}
