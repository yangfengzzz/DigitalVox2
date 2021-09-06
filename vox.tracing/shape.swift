//
//  shape.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// -----------------------------------------------------------------------------
//MARK:- EXAMPLE SHAPES
// -----------------------------------------------------------------------------
// Make a tessellated rectangle. Useful in other subdivisions.
func make_quads(_ steps: vec2i, _ scale: vec2f, _ uvscale: vec2f) -> shape_data {
    var shape = shape_data()

    shape.positions = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    shape.normals = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    shape.texcoords = .init(repeating: vec2f(), count: (steps.x + 1) * (steps.y + 1))
    for j in 0...steps.y {
        for i in 0...steps.x {
            let uv = vec2f(Float(i) / Float(steps.x), Float(j) / Float(steps.y))
            shape.positions[j * (steps.x + 1) + i] = [
                (2 * uv.x - 1) * scale.x, (2 * uv.y - 1) * scale.y, 0]
            shape.normals[j * (steps.x + 1) + i] = [0, 0, 1]
            shape.texcoords[j * (steps.x + 1) + i] = vec2f(uv.x, 1 - uv.y) * uvscale
        }
    }

    shape.quads = .init(repeating: vec4i(), count: steps.x * steps.y)
    for j in 0..<steps.y {
        for i in 0..<steps.x {
            shape.quads[j * steps.x + i] = [j * (steps.x + 1) + i,
                                            j * (steps.x + 1) + i + 1,
                                            (j + 1) * (steps.x + 1) + i + 1,
                                            (j + 1) * (steps.x + 1) + i]
        }
    }

    return shape
}

// Merge shape elements
func merge_shape_inplace(_ shape: inout shape_data, _ merge: shape_data) {
    let offset = shape.positions.count
    for p in merge.points {
        shape.points.append(p + offset)
    }
    for l in merge.lines {
        shape.lines.append([l.x + offset, l.y + offset])
    }
    for t in merge.triangles {
        shape.triangles.append([t.x + offset, t.y + offset, t.z + offset])
    }
    for q in merge.quads {
        shape.quads.append([q.x + offset, q.y + offset, q.z + offset, q.w + offset])
    }
    shape.positions.append(contentsOf: merge.positions)
    shape.tangents.append(contentsOf: merge.tangents)
    shape.texcoords.append(contentsOf: merge.texcoords)
    shape.colors.append(contentsOf: merge.colors)
    shape.radius.append(contentsOf: merge.radius)
}

// -----------------------------------------------------------------------------
//MARK:- COMPUTATION OF PER_VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Compute per-vertex normals/tangents for lines/triangles/quads.
func lines_tangents(_ lines: [vec2i], _ positions: [vec3f]) -> [vec3f] {
    var tangents = [vec3f](repeating: vec3f(), count: positions.count)
    for l in lines {
        let tangent = line_tangent(positions[l.x], positions[l.y])
        let length = line_length(positions[l.x], positions[l.y])
        tangents[l.x] += tangent * length
        tangents[l.y] += tangent * length
    }
    tangents = tangents.map({ tangent in
        normalize(tangent)
    })
    return tangents
}

func triangles_normals(_ triangles: [vec3i], _ positions: [vec3f]) -> [vec3f] {
    var normals = [vec3f](repeating: vec3f(), count: positions.count)
    for t in triangles {
        let normal = triangle_normal(positions[t.x], positions[t.y], positions[t.z])
        let area = triangle_area(positions[t.x], positions[t.y], positions[t.z])
        normals[t.x] += normal * area
        normals[t.y] += normal * area
        normals[t.z] += normal * area
    }
    normals = normals.map({ normal in
        normalize(normal)
    })
    return normals
}

func quads_normals(_ quads: [vec4i], _ positions: [vec3f]) -> [vec3f] {
    var normals = [vec3f](repeating: vec3f(), count: positions.count)
    for q in quads {
        let normal = quad_normal(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        let area = quad_area(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        normals[q.x] += normal * area
        normals[q.y] += normal * area
        normals[q.z] += normal * area
        if (q.z != q.w) {
            normals[q.w] += normal * area
        }
    }
    normals = normals.map({ normal in
        normalize(normal)
    })
    return normals
}

// Update normals and tangents
func lines_tangents(_ tangents: inout [vec3f], _ lines: [vec2i], _ positions: [vec3f]) {
    if (tangents.count != positions.count) {
        fatalError("array should be the same length")
    }
    tangents = tangents.map({ _ in
        [0, 0, 0]
    })
    for l in lines {
        let tangent = line_tangent(positions[l.x], positions[l.y])
        let length = line_length(positions[l.x], positions[l.y])
        tangents[l.x] += tangent * length
        tangents[l.y] += tangent * length
    }
    tangents = tangents.map({ tangent in
        normalize(tangent)
    })
}

func triangles_normals(_ normals: inout [vec3f], _ triangles: [vec3i], _ positions: [vec3f]) {
    if (normals.count != positions.count) {
        fatalError("array should be the same length")
    }
    normals = normals.map({ _ in
        [0, 0, 0]
    })
    for t in triangles {
        let normal = triangle_normal(positions[t.x], positions[t.y], positions[t.z])
        let area = triangle_area(positions[t.x], positions[t.y], positions[t.z])
        normals[t.x] += normal * area
        normals[t.y] += normal * area
        normals[t.z] += normal * area
    }
    normals = normals.map({ normal in
        normalize(normal)
    })
}

func quads_normals(_ normals: inout [vec3f], _ quads: [vec4i], _ positions: [vec3f]) {
    if (normals.count != positions.count) {
        fatalError("array should be the same length")
    }
    normals = normals.map({ _ in
        [0, 0, 0]
    })
    for q in quads {
        let normal = quad_normal(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        let area = quad_area(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        normals[q.x] += normal * area
        normals[q.y] += normal * area
        normals[q.z] += normal * area
        if (q.z != q.w) {
            normals[q.w] += normal * area
        }
    }
    normals = normals.map({ normal in
        normalize(normal)
    })
}

// Compute per-vertex tangent space for triangle meshes.
// Tangent space is defined by a four component vector.
// The first three components are the tangent with respect to the u texcoord.
// The fourth component is the sign of the tangent wrt the v texcoord.
// Tangent frame is useful in normal mapping.
func triangle_tangent_spaces(_ triangles: [vec3i], _ positions: [vec3f],
                             _ normals: [vec3f], _ texcoords: [vec2f]) -> [vec4f] {
    var tangu = [vec3f](repeating: vec3f(), count: positions.count)
    var tangv = [vec3f](repeating: vec3f(), count: positions.count)
    for t in triangles {
        let tutv = triangle_tangents_from_uv(positions[t.x], positions[t.y],
                positions[t.z], texcoords[t.x], texcoords[t.y], texcoords[t.z])
        for vid in [t.x, t.y, t.z] {
            tangu[vid] += normalize(tutv.0)
        }
        for vid in [t.x, t.y, t.z] {
            tangv[vid] += normalize(tutv.1)
        }
    }
    tangu = tangu.map({ t in
        normalize(t)
    })
    tangv = tangv.map({ t in
        normalize(t)
    })

    var tangent_spaces = [vec4f](repeating: vec4f(), count: positions.count)
    tangent_spaces = tangent_spaces.map({ _ in
        zero4f
    })
    for i in 0..<positions.count {
        tangu[i] = orthonormalize(tangu[i], normals[i])
        let s: Float = (dot(cross(normals[i], tangu[i]), tangv[i]) < 0) ? -1.0 : 1.0
        tangent_spaces[i] = [tangu[i].x, tangu[i].y, tangu[i].z, s]
    }
    return tangent_spaces
}

// Apply skinning to vertex position and normals.
func skin_vertices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) -> ([vec3f], [vec3f]) {
    var skinned_positions = [vec3f](repeating: vec3f(), count: positions.count)
    var skinned_normals = [vec3f](repeating: vec3f(), count: positions.count)
    for i in 0..<positions.count {
        skinned_positions[i] = transform_point(xforms[joints[i].x], positions[i]) * weights[i].x
        skinned_positions[i] += transform_point(xforms[joints[i].y], positions[i]) * weights[i].y
        skinned_positions[i] += transform_point(xforms[joints[i].z], positions[i]) * weights[i].z
        skinned_positions[i] += transform_point(xforms[joints[i].w], positions[i]) * weights[i].w
    }
    for i in 0..<normals.count {
        var dir = transform_direction(xforms[joints[i].x], normals[i]) * weights[i].x
        dir += transform_direction(xforms[joints[i].y], normals[i]) * weights[i].y
        dir += transform_direction(xforms[joints[i].z], normals[i]) * weights[i].z
        dir += transform_direction(xforms[joints[i].w], normals[i]) * weights[i].w
        skinned_normals[i] = normalize(dir)
    }
    return (skinned_positions, skinned_normals)
}

// Apply skinning as specified in Khronos glTF.
func skin_matrices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) -> ([vec3f], [vec3f]) {
    var skinned_positions = [vec3f](repeating: vec3f(), count: positions.count)
    var skinned_normals = [vec3f](repeating: vec3f(), count: positions.count)
    for i in 0..<positions.count {
        let xform = xforms[joints[i].x] * weights[i].x +
                xforms[joints[i].y] * weights[i].y +
                xforms[joints[i].z] * weights[i].z +
                xforms[joints[i].w] * weights[i].w
        skinned_positions[i] = transform_point(xform, positions[i])
        skinned_normals[i] = normalize(transform_direction(xform, normals[i]))
    }
    return (skinned_positions, skinned_normals)
}

// Update skinning
func skin_vertices(_ skinned_positions: inout [vec3f], _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) {
    if (skinned_positions.count != positions.count ||
            skinned_normals.count != normals.count) {
        fatalError("arrays should be the same size")
    }
    for i in 0..<positions.count {
        skinned_positions[i] = transform_point(xforms[joints[i].x], positions[i]) * weights[i].x
        skinned_positions[i] += transform_point(xforms[joints[i].y], positions[i]) * weights[i].y
        skinned_positions[i] += transform_point(xforms[joints[i].z], positions[i]) * weights[i].z
        skinned_positions[i] += transform_point(xforms[joints[i].w], positions[i]) * weights[i].w
    }
    for i in 0..<normals.count {
        var dir = transform_direction(xforms[joints[i].x], normals[i]) * weights[i].x
        dir += transform_direction(xforms[joints[i].y], normals[i]) * weights[i].y
        dir += transform_direction(xforms[joints[i].z], normals[i]) * weights[i].z
        dir += transform_direction(xforms[joints[i].w], normals[i]) * weights[i].w
        skinned_normals[i] = normalize(dir)
    }
}

func skin_matrices(_ skinned_positions: inout [vec3f],
                   _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) {
    if (skinned_positions.count != positions.count ||
            skinned_normals.count != normals.count) {
        fatalError("arrays should be the same size")
    }
    for i in 0..<positions.count {
        let xform = xforms[joints[i].x] * weights[i].x +
                xforms[joints[i].y] * weights[i].y +
                xforms[joints[i].z] * weights[i].z +
                xforms[joints[i].w] * weights[i].w
        skinned_positions[i] = transform_point(xform, positions[i])
        skinned_normals[i] = normalize(transform_direction(xform, normals[i]))
    }
}

// -----------------------------------------------------------------------------
//MARK:- COMPUTATION OF VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Flip vertex normals
func flip_normals(_ normals: [vec3f]) -> [vec3f] {
    normals.map { n in
        -n
    }
}

// Flip face orientation
func flip_triangles(_ triangles: [vec3i]) -> [vec3i] {
    triangles.map { t in
        [t.x, t.z, t.y]
    }
}

func flip_quads(_ quads: [vec4i]) -> [vec4i] {
    quads.map { q in
        if (q.z != q.w) {
            return [q.x, q.w, q.z, q.y]
        } else {
            return [q.x, q.z, q.y, q.y]
        }
    }
}

// Align vertex positions. Alignment is 0: none, 1: min, 2: max, 3: center.
func align_vertices(_ positions: [vec3f], _ alignment: vec3i) -> [vec3f] {
    var bounds = invalidb3f
    for p in positions {
        bounds = merge(bounds, p)
    }
    var offset = vec3f(0, 0, 0)
    switch (alignment.x) {
    case 1: offset.x = bounds.min.x
    case 2: offset.x = (bounds.min.x + bounds.max.x) / 2
    case 3: offset.x = bounds.max.x
    default: fatalError()
    }
    switch (alignment.y) {
    case 1: offset.y = bounds.min.y
    case 2: offset.y = (bounds.min.y + bounds.max.y) / 2
    case 3: offset.y = bounds.max.y
    default: fatalError()
    }
    switch (alignment.z) {
    case 1: offset.z = bounds.min.z
    case 2: offset.z = (bounds.min.z + bounds.max.z) / 2
    case 3: offset.z = bounds.max.z
    default: fatalError()
    }
    return positions.map { p in
        p - offset
    }
}

// -----------------------------------------------------------------------------
//MARK:- SHAPE ELEMENT CONVERSION AND GROUPING
// -----------------------------------------------------------------------------
// Convert quads to triangles
func quads_to_triangles(_ quads: [vec4i]) -> [vec3i] {
    var triangles: [vec3i] = []
    triangles.reserveCapacity(quads.count * 2)
    for q in quads {
        triangles.append([q.x, q.y, q.w])
        if (q.z != q.w) {
            triangles.append([q.z, q.w, q.y])
        }
    }
    return triangles
}

// Convert triangles to quads by creating degenerate quads
func triangles_to_quads(_ triangles: [vec3i]) -> [vec4i] {
    var quads: [vec4i] = []
    quads.reserveCapacity(triangles.count)
    for t in triangles {
        quads.append([t.x, t.y, t.z, t.z])
    }
    return quads
}

// Convert beziers to lines using 3 lines for each bezier.
func bezier_to_lines(_ beziers: [vec4i]) -> [vec2i] {
    var lines: [vec2i] = []
    lines.reserveCapacity(beziers.count * 3)
    for b in beziers {
        lines.append([b.x, b.y])
        lines.append([b.y, b.z])
        lines.append([b.z, b.w])
    }
    return lines
}

// Convert face-varying data to single primitives. Returns the quads indices
// and filled vectors for pos, norm and texcoord.
func split_facevarying(_ split_quads: inout [vec4i], _ split_positions: inout [vec3f], _ split_normals: inout [vec3f],
                       _ split_texcoords: inout [vec2f], _ quadspos: [vec4i],
                       _ quadsnorm: [vec4i], _ quadstexcoord: [vec4i],
                       _ positions: [vec3f], _ normals: [vec3f],
                       _ texcoords: [vec2f]) {
    // make faces unique
    var vert_map: [vec3i: Int] = [:]
    split_quads = .init(repeating: vec4i(), count: quadspos.count)
    for fid in 0..<quadspos.count {
        for c in 0..<4 {
            let v = vec3i(
                    quadspos[fid][c],
                    (!quadsnorm.isEmpty ? quadsnorm[fid][c] : -1),
                    (!quadstexcoord.isEmpty ? quadstexcoord[fid][c] : -1)
            )
            let it = vert_map.first(where: { (key: vec3i, value: Int) in
                key == v
            })
            if (it == nil) {
                let s = vert_map.count
                vert_map[v] = s
                split_quads[fid][c] = s
            } else {
                split_quads[fid][c] = it!.value
            }
        }
    }

    // fill vert data
    split_positions = []
    if (!positions.isEmpty) {
        split_positions = .init(repeating: vec3f(), count: vert_map.count)
        for (vert, index) in vert_map {
            split_positions[index] = positions[vert.x]
        }
    }
    split_normals = []
    if (!normals.isEmpty) {
        split_normals = .init(repeating: vec3f(), count: vert_map.count)
        for (vert, index) in vert_map {
            split_normals[index] = normals[vert.y]
        }
    }
    split_texcoords = []
    if (!texcoords.isEmpty) {
        split_texcoords = .init(repeating: vec2f(), count: vert_map.count)
        for (vert, index) in vert_map {
            split_texcoords[index] = texcoords[vert.z]
        }
    }
}

// Weld vertices within a threshold.
func weld_vertices(_ positions: [vec3f], _ threshold: Float) -> ([vec3f], [Int]) {
    var indices = [Int](repeating: 0, count: positions.count)
    var welded: [vec3f] = []
    var grid = make_hash_grid(threshold)
    var neighbors: [Int] = []
    for vertex in 0..<positions.count {
        let position = positions[vertex]
        find_neighbors(grid, &neighbors, position, threshold)
        if (neighbors.isEmpty) {
            welded.append(position)
            indices[vertex] = welded.count - 1
            _ = insert_vertex(&grid, position)
        } else {
            indices[vertex] = neighbors.first!
        }
    }
    return (welded, indices)
}

func weld_triangles(_ triangles: [vec3i], _ positions: [vec3f], _ threshold: Float) -> ([vec3i], [vec3f]) {
    let (wpositions, indices) = weld_vertices(positions, threshold)
    let wtriangles = triangles.map { t in
        vec3i(indices[t.x], indices[t.y], indices[t.z])
    }
    return (wtriangles, wpositions)
}

func weld_quads(_ quads: [vec4i], _ positions: [vec3f], _ threshold: Float) -> ([vec4i], [vec3f]) {
    let (wpositions, indices) = weld_vertices(positions, threshold)
    let wquads = quads.map { q in
        vec4i(indices[q.x], indices[q.y], indices[q.z], indices[q.w])
    }
    return (wquads, wpositions)
}

// Merge shape elements
func merge_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                 _ tangents: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ merge_lines: [vec2i], _ merge_positions: [vec3f],
                 _ merge_tangents: [vec3f],
                 _ merge_texturecoords: [vec2f],
                 _ merge_radius: [Float]) {
    let merge_verts = positions.count
    for l in merge_lines {
        lines.append([l.x + merge_verts, l.y + merge_verts])
    }
    positions.append(contentsOf: merge_positions)
    tangents.append(contentsOf: merge_tangents)
    texcoords.append(contentsOf: merge_texturecoords)
    radius.append(contentsOf: merge_radius)
}

func merge_triangles(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout[vec2f],
                     _ merge_triangles: [vec3i], _ merge_positions: [vec3f],
                     _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    let merge_verts = positions.count
    for t in merge_triangles {
        triangles.append([t.x + merge_verts, t.y + merge_verts, t.z + merge_verts])
    }
    positions.append(contentsOf: merge_positions)
    normals.append(contentsOf: merge_normals)
    texcoords.append(contentsOf: merge_texturecoords)
}

func merge_quads(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                 _ merge_quads: [vec4i], _ merge_positions: [vec3f],
                 _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    let merge_verts = positions.count
    for q in merge_quads {
        quads.append([q.x + merge_verts, q.y + merge_verts,
                      q.z + merge_verts, q.w + merge_verts])
    }
    positions.append(contentsOf: merge_positions)
    normals.append(contentsOf: merge_normals)
    texcoords.append(contentsOf: merge_texturecoords)
}

// -----------------------------------------------------------------------------
//MARK:- SHAPE SUBDIVISION
// -----------------------------------------------------------------------------
// Subdivide lines by splitting each line in half.
func subdivide_lines(_ lines: [vec2i], _ vertices: [Float]) -> ([vec2i], [Float]) {
    // early exit
    if (lines.isEmpty || vertices.isEmpty) {
        return (lines, vertices)
    }
    // create vertices
    var tvertices: [Float] = []
    tvertices.reserveCapacity(vertices.count + lines.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for line in lines {
        tvertices.append((vertices[line.x] + vertices[line.y]) / 2)
    }
    // create lines
    var tlines: [vec2i] = []
    tlines.reserveCapacity(lines.count * 2)
    let line_vertex = { (line_id: Int) -> Int in
        vertices.count + line_id
    }
    for (line_id, line) in lines.enumerated() {
        tlines.append([line.x, line_vertex(line_id)])
        tlines.append([line_vertex(line_id), line.y])
    }
    // done
    return (tlines, tvertices)
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec2f]) -> ([vec2i], [vec2f]) {
    // early exit
    if (lines.isEmpty || vertices.isEmpty) {
        return (lines, vertices)
    }
    // create vertices
    var tvertices: [vec2f] = []
    tvertices.reserveCapacity(vertices.count + lines.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for line in lines {
        tvertices.append((vertices[line.x] + vertices[line.y]) / 2)
    }
    // create lines
    var tlines: [vec2i] = []
    tlines.reserveCapacity(lines.count * 2)
    let line_vertex = { (line_id: Int) -> Int in
        vertices.count + line_id
    }
    for (line_id, line) in lines.enumerated() {
        tlines.append([line.x, line_vertex(line_id)])
        tlines.append([line_vertex(line_id), line.y])
    }
    // done
    return (tlines, tvertices)
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec3f]) -> ([vec2i], [vec3f]) {
    // early exit
    if (lines.isEmpty || vertices.isEmpty) {
        return (lines, vertices)
    }
    // create vertices
    var tvertices: [vec3f] = []
    tvertices.reserveCapacity(vertices.count + lines.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for line in lines {
        tvertices.append((vertices[line.x] + vertices[line.y]) / 2)
    }
    // create lines
    var tlines: [vec2i] = []
    tlines.reserveCapacity(lines.count * 2)
    let line_vertex = { (line_id: Int) -> Int in
        vertices.count + line_id
    }
    for (line_id, line) in lines.enumerated() {
        tlines.append([line.x, line_vertex(line_id)])
        tlines.append([line_vertex(line_id), line.y])
    }
    // done
    return (tlines, tvertices)
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec4f]) -> ([vec2i], [vec4f]) {
    // early exit
    if (lines.isEmpty || vertices.isEmpty) {
        return (lines, vertices)
    }
    // create vertices
    var tvertices: [vec4f] = []
    tvertices.reserveCapacity(vertices.count + lines.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for line in lines {
        tvertices.append((vertices[line.x] + vertices[line.y]) / 2)
    }
    // create lines
    var tlines: [vec2i] = []
    tlines.reserveCapacity(lines.count * 2)
    let line_vertex = { (line_id: Int) -> Int in
        vertices.count + line_id
    }
    for (line_id, line) in lines.enumerated() {
        tlines.append([line.x, line_vertex(line_id)])
        tlines.append([line_vertex(line_id), line.y])
    }
    // done
    return (tlines, tvertices)
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
func subdivide_triangles(_ triangles: [vec3i], _ vertices: [Float]) -> ([vec3i], [Float]) {
    // early exit
    if (triangles.isEmpty || vertices.isEmpty) {
        return (triangles, vertices)
    }
    // get edges
    let emap = make_edge_map(triangles)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [Float] = []
    tvertices.reserveCapacity(vertices.count + edges.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    // create triangles
    var ttriangles: [vec3i] = []
    ttriangles.reserveCapacity(triangles.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    for triangle in triangles {
        ttriangles.append([triangle.x, edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.z, triangle.x])])
        ttriangles.append([triangle.y, edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.x, triangle.y])])
        ttriangles.append([triangle.z, edge_vertex([triangle.z, triangle.x]),
                           edge_vertex([triangle.y, triangle.z])])
        ttriangles.append([edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.z, triangle.x])])
    }
    // done
    return (ttriangles, tvertices)
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec2f]) -> ([vec3i], [vec2f]) {
    // early exit
    if (triangles.isEmpty || vertices.isEmpty) {
        return (triangles, vertices)
    }
    // get edges
    let emap = make_edge_map(triangles)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec2f] = []
    tvertices.reserveCapacity(vertices.count + edges.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    // create triangles
    var ttriangles: [vec3i] = []
    ttriangles.reserveCapacity(triangles.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    for triangle in triangles {
        ttriangles.append([triangle.x, edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.z, triangle.x])])
        ttriangles.append([triangle.y, edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.x, triangle.y])])
        ttriangles.append([triangle.z, edge_vertex([triangle.z, triangle.x]),
                           edge_vertex([triangle.y, triangle.z])])
        ttriangles.append([edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.z, triangle.x])])
    }
    // done
    return (ttriangles, tvertices)
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec3f]) -> ([vec3i], [vec3f]) {
    // early exit
    if (triangles.isEmpty || vertices.isEmpty) {
        return (triangles, vertices)
    }
    // get edges
    let emap = make_edge_map(triangles)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec3f] = []
    tvertices.reserveCapacity(vertices.count + edges.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    // create triangles
    var ttriangles: [vec3i] = []
    ttriangles.reserveCapacity(triangles.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    for triangle in triangles {
        ttriangles.append([triangle.x, edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.z, triangle.x])])
        ttriangles.append([triangle.y, edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.x, triangle.y])])
        ttriangles.append([triangle.z, edge_vertex([triangle.z, triangle.x]),
                           edge_vertex([triangle.y, triangle.z])])
        ttriangles.append([edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.z, triangle.x])])
    }
    // done
    return (ttriangles, tvertices)
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec4f]) -> ([vec3i], [vec4f]) {
    // early exit
    if (triangles.isEmpty || vertices.isEmpty) {
        return (triangles, vertices)
    }
    // get edges
    let emap = make_edge_map(triangles)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec4f] = []
    tvertices.reserveCapacity(vertices.count + edges.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    // create triangles
    var ttriangles: [vec3i] = []
    ttriangles.reserveCapacity(triangles.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    for triangle in triangles {
        ttriangles.append([triangle.x, edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.z, triangle.x])])
        ttriangles.append([triangle.y, edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.x, triangle.y])])
        ttriangles.append([triangle.z, edge_vertex([triangle.z, triangle.x]),
                           edge_vertex([triangle.y, triangle.z])])
        ttriangles.append([edge_vertex([triangle.x, triangle.y]),
                           edge_vertex([triangle.y, triangle.z]),
                           edge_vertex([triangle.z, triangle.x])])
    }
    // done
    return (ttriangles, tvertices)
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
func subdivide_quads(_ quads: [vec4i], _ vertices: [Float]) -> ([vec4i], [Float]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [Float] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }
    // done
    return (tquads, tvertices)
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec2f]) -> ([vec4i], [vec2f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec2f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }
    // done
    return (tquads, tvertices)
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec3f]) -> ([vec4i], [vec3f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec3f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }
    // done
    return (tquads, tvertices)
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec4f]) -> ([vec4i], [vec4f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    // create vertices
    var tvertices: [vec4f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }
    // done
    return (tquads, tvertices)
}

// Subdivide beziers by splitting each segment in two.
func subdivide_beziers(_ beziers: [vec4i], _ vertices: [Float]) -> ([vec4i], [Float]) {
    // early exit
    if (beziers.isEmpty || vertices.isEmpty) {
        return (beziers, vertices)
    }
    // get edges
    var vmap: [Int: Int] = [:]
    var tvertices: [Float] = []
    var tbeziers: [vec4i] = []
    for bezier in beziers {
        if (vmap[bezier.x] == nil) {
            vmap[bezier.x] = tvertices.count
            tvertices.append(vertices[bezier.x])
        }
        if (vmap[bezier.w] == nil) {
            vmap[bezier.w] = tvertices.count
            tvertices.append(vertices[bezier.w])
        }
        let bo = tvertices.count
        tbeziers.append([vmap[bezier.x]!, bo + 0, bo + 1, bo + 2])
        tbeziers.append([bo + 2, bo + 3, bo + 4, vmap[bezier.w]!])
        tvertices.append(vertices[bezier.x] / 2 + vertices[bezier.y] / 2)
        tvertices.append(vertices[bezier.x] / 4 + vertices[bezier.y] / 2 + vertices[bezier.z] / 4)
        tvertices.append(vertices[bezier.x] / 8 + vertices[bezier.y] * (3.0 / 8.0) + vertices[bezier.z] * (3.0 / 8.0) + vertices[bezier.w] / 8)
        tvertices.append(vertices[bezier.y] / 4 + vertices[bezier.z] / 2 + vertices[bezier.w] / 4)
        tvertices.append(vertices[bezier.z] / 2 + vertices[bezier.w] / 2)
    }

    // done
    return (tbeziers, tvertices)
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec2f]) -> ([vec4i], [vec2f]) {
    // early exit
    if (beziers.isEmpty || vertices.isEmpty) {
        return (beziers, vertices)
    }
    // get edges
    var vmap: [Int: Int] = [:]
    var tvertices: [vec2f] = []
    var tbeziers: [vec4i] = []
    for bezier in beziers {
        if (vmap[bezier.x] == nil) {
            vmap[bezier.x] = tvertices.count
            tvertices.append(vertices[bezier.x])
        }
        if (vmap[bezier.w] == nil) {
            vmap[bezier.w] = tvertices.count
            tvertices.append(vertices[bezier.w])
        }
        let bo = tvertices.count
        tbeziers.append([vmap[bezier.x]!, bo + 0, bo + 1, bo + 2])
        tbeziers.append([bo + 2, bo + 3, bo + 4, vmap[bezier.w]!])
        tvertices.append(vertices[bezier.x] / 2 + vertices[bezier.y] / 2)
        var result = vertices[bezier.x] / 4 + vertices[bezier.y] / 2
        tvertices.append(result + vertices[bezier.z] / 4)
        result = vertices[bezier.x] / 8 + vertices[bezier.y] * (3.0 / 8.0)
        result += vertices[bezier.z] * (3.0 / 8.0)
        tvertices.append(result + vertices[bezier.w] / 8)
        result = vertices[bezier.y] / 4 + vertices[bezier.z] / 2
        tvertices.append(result + vertices[bezier.w] / 4)
        tvertices.append(vertices[bezier.z] / 2 + vertices[bezier.w] / 2)
    }

    // done
    return (tbeziers, tvertices)
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec3f]) -> ([vec4i], [vec3f]) {
    // early exit
    if (beziers.isEmpty || vertices.isEmpty) {
        return (beziers, vertices)
    }
    // get edges
    var vmap: [Int: Int] = [:]
    var tvertices: [vec3f] = []
    var tbeziers: [vec4i] = []
    for bezier in beziers {
        if (vmap[bezier.x] == nil) {
            vmap[bezier.x] = tvertices.count
            tvertices.append(vertices[bezier.x])
        }
        if (vmap[bezier.w] == nil) {
            vmap[bezier.w] = tvertices.count
            tvertices.append(vertices[bezier.w])
        }
        let bo = tvertices.count
        tbeziers.append([vmap[bezier.x]!, bo + 0, bo + 1, bo + 2])
        tbeziers.append([bo + 2, bo + 3, bo + 4, vmap[bezier.w]!])
        tvertices.append(vertices[bezier.x] / 2 + vertices[bezier.y] / 2)
        var result = vertices[bezier.x] / 4 + vertices[bezier.y] / 2
        tvertices.append(result + vertices[bezier.z] / 4)
        result = vertices[bezier.x] / 8 + vertices[bezier.y] * (3.0 / 8.0)
        result += vertices[bezier.z] * (3.0 / 8.0)
        tvertices.append(result + vertices[bezier.w] / 8)
        result = vertices[bezier.y] / 4 + vertices[bezier.z] / 2
        tvertices.append(result + vertices[bezier.w] / 4)
        tvertices.append(vertices[bezier.z] / 2 + vertices[bezier.w] / 2)
    }

    // done
    return (tbeziers, tvertices)
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec4f]) -> ([vec4i], [vec4f]) {
    // early exit
    if (beziers.isEmpty || vertices.isEmpty) {
        return (beziers, vertices)
    }
    // get edges
    var vmap: [Int: Int] = [:]
    var tvertices: [vec4f] = []
    var tbeziers: [vec4i] = []
    for bezier in beziers {
        if (vmap[bezier.x] == nil) {
            vmap[bezier.x] = tvertices.count
            tvertices.append(vertices[bezier.x])
        }
        if (vmap[bezier.w] == nil) {
            vmap[bezier.w] = tvertices.count
            tvertices.append(vertices[bezier.w])
        }
        let bo = tvertices.count
        tbeziers.append([vmap[bezier.x]!, bo + 0, bo + 1, bo + 2])
        tbeziers.append([bo + 2, bo + 3, bo + 4, vmap[bezier.w]!])
        tvertices.append(vertices[bezier.x] / 2 + vertices[bezier.y] / 2)
        var result = vertices[bezier.x] / 4 + vertices[bezier.y] / 2
        tvertices.append(result + vertices[bezier.z] / 4)
        result = vertices[bezier.x] / 8 + vertices[bezier.y] * (3.0 / 8.0)
        result += vertices[bezier.z] * (3.0 / 8.0)
        tvertices.append(result + vertices[bezier.w] / 8)
        result = vertices[bezier.y] / 4 + vertices[bezier.z] / 2
        tvertices.append(result + vertices[bezier.w] / 4)
        tvertices.append(vertices[bezier.z] / 2 + vertices[bezier.w] / 2)
    }

    // done
    return (tbeziers, tvertices)
}

// Subdivide quads using Catmull-Clark subdivision rules.
func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [Float],
                            _ lock_boundary: Bool = false) -> ([vec4i], [Float]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    let boundary = get_boundary(emap)

    // split elements ------------------------------------
    // create vertices
    var tvertices: [Float] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }

    // split boundary
    var tboundary: [vec2i] = []
    tboundary.reserveCapacity(boundary.count)
    for edge in boundary {
        tboundary.append([edge.x, edge_vertex(edge)])
        tboundary.append([edge_vertex(edge), edge.y])
    }

    // setup creases -----------------------------------
    var tcrease_edges: [vec2i] = []
    var tcrease_verts: [Int] = []
    if (lock_boundary) {
        for b in tboundary {
            tcrease_verts.append(b.x)
            tcrease_verts.append(b.y)
        }
    } else {
        for b in tboundary {
            tcrease_edges.append(b)
        }
    }

    // define vertices valence ---------------------------
    var tvert_val = [Int](repeating: 2, count: tvertices.count)
    for edge in tboundary {
        tvert_val[edge.x] = (lock_boundary) ? 0 : 1
        tvert_val[edge.y] = (lock_boundary) ? 0 : 1
    }

    // averaging pass ----------------------------------
    var avert = [Float](repeating: 0, count: tvertices.count)
    var acount = [Int](repeating: 0, count: tvertices.count)
    for point in tcrease_verts {
        if (tvert_val[point] != 0) {
            continue
        }
        avert[point] += tvertices[point]
        acount[point] += 1
    }
    for edge in tcrease_edges {
        let centroid = (tvertices[edge.x] + tvertices[edge.y]) / 2
        for vid in [edge.x, edge.y] {
            if (tvert_val[vid] != 1) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for quad in tquads {
        let centroid = (tvertices[quad.x] + tvertices[quad.y] + tvertices[quad.z] + tvertices[quad.w]) / 4
        for vid in [quad.x, quad.y, quad.z, quad.w] {
            if (tvert_val[vid] != 2) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for i in 0..<tvertices.count {
        avert[i] /= Float(acount[i])
    }

    // correction pass ----------------------------------
    // p = p + (avg_p - p) * (4/avg_count)
    for i in 0..<tvertices.count {
        if (tvert_val[i] != 2) {
            continue
        }
        avert[i] = tvertices[i] + (avert[i] - tvertices[i]) * (4 / Float(acount[i]))
    }
    tvertices = avert

    // done
    return (tquads, tvertices)
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec2f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec2f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    let boundary = get_boundary(emap)

    // split elements ------------------------------------
    // create vertices
    var tvertices: [vec2f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }

    // split boundary
    var tboundary: [vec2i] = []
    tboundary.reserveCapacity(boundary.count)
    for edge in boundary {
        tboundary.append([edge.x, edge_vertex(edge)])
        tboundary.append([edge_vertex(edge), edge.y])
    }

    // setup creases -----------------------------------
    var tcrease_edges: [vec2i] = []
    var tcrease_verts: [Int] = []
    if (lock_boundary) {
        for b in tboundary {
            tcrease_verts.append(b.x)
            tcrease_verts.append(b.y)
        }
    } else {
        for b in tboundary {
            tcrease_edges.append(b)
        }
    }

    // define vertices valence ---------------------------
    var tvert_val = [Int](repeating: 2, count: tvertices.count)
    for edge in tboundary {
        tvert_val[edge.x] = (lock_boundary) ? 0 : 1
        tvert_val[edge.y] = (lock_boundary) ? 0 : 1
    }

    // averaging pass ----------------------------------
    var avert = [vec2f](repeating: vec2f(), count: tvertices.count)
    var acount = [Int](repeating: 0, count: tvertices.count)
    for point in tcrease_verts {
        if (tvert_val[point] != 0) {
            continue
        }
        avert[point] += tvertices[point]
        acount[point] += 1
    }
    for edge in tcrease_edges {
        let centroid = (tvertices[edge.x] + tvertices[edge.y]) / 2
        for vid in [edge.x, edge.y] {
            if (tvert_val[vid] != 1) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for quad in tquads {
        let centroid = (tvertices[quad.x] + tvertices[quad.y] + tvertices[quad.z] + tvertices[quad.w]) / 4
        for vid in [quad.x, quad.y, quad.z, quad.w] {
            if (tvert_val[vid] != 2) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for i in 0..<tvertices.count {
        avert[i] /= Float(acount[i])
    }

    // correction pass ----------------------------------
    // p = p + (avg_p - p) * (4/avg_count)
    for i in 0..<tvertices.count {
        if (tvert_val[i] != 2) {
            continue
        }
        avert[i] = tvertices[i] + (avert[i] - tvertices[i]) * (4 / Float(acount[i]))
    }
    tvertices = avert

    // done
    return (tquads, tvertices)
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec3f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec3f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    let boundary = get_boundary(emap)

    // split elements ------------------------------------
    // create vertices
    var tvertices: [vec3f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }

    // split boundary
    var tboundary: [vec2i] = []
    tboundary.reserveCapacity(boundary.count)
    for edge in boundary {
        tboundary.append([edge.x, edge_vertex(edge)])
        tboundary.append([edge_vertex(edge), edge.y])
    }

    // setup creases -----------------------------------
    var tcrease_edges: [vec2i] = []
    var tcrease_verts: [Int] = []
    if (lock_boundary) {
        for b in tboundary {
            tcrease_verts.append(b.x)
            tcrease_verts.append(b.y)
        }
    } else {
        for b in tboundary {
            tcrease_edges.append(b)
        }
    }

    // define vertices valence ---------------------------
    var tvert_val = [Int](repeating: 2, count: tvertices.count)
    for edge in tboundary {
        tvert_val[edge.x] = (lock_boundary) ? 0 : 1
        tvert_val[edge.y] = (lock_boundary) ? 0 : 1
    }

    // averaging pass ----------------------------------
    var avert = [vec3f](repeating: vec3f(), count: tvertices.count)
    var acount = [Int](repeating: 0, count: tvertices.count)
    for point in tcrease_verts {
        if (tvert_val[point] != 0) {
            continue
        }
        avert[point] += tvertices[point]
        acount[point] += 1
    }
    for edge in tcrease_edges {
        let centroid = (tvertices[edge.x] + tvertices[edge.y]) / 2
        for vid in [edge.x, edge.y] {
            if (tvert_val[vid] != 1) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for quad in tquads {
        let centroid = (tvertices[quad.x] + tvertices[quad.y] + tvertices[quad.z] + tvertices[quad.w]) / 4
        for vid in [quad.x, quad.y, quad.z, quad.w] {
            if (tvert_val[vid] != 2) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for i in 0..<tvertices.count {
        avert[i] /= Float(acount[i])
    }

    // correction pass ----------------------------------
    // p = p + (avg_p - p) * (4/avg_count)
    for i in 0..<tvertices.count {
        if (tvert_val[i] != 2) {
            continue
        }
        avert[i] = tvertices[i] + (avert[i] - tvertices[i]) * (4 / Float(acount[i]))
    }
    tvertices = avert

    // done
    return (tquads, tvertices)
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec4f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec4f]) {
    // early exit
    if (quads.isEmpty || vertices.isEmpty) {
        return (quads, vertices)
    }
    // get edges
    let emap = make_edge_map(quads)
    let edges = get_edges(emap)
    let boundary = get_boundary(emap)

    // split elements ------------------------------------
    // create vertices
    var tvertices: [vec4f] = []
    tvertices.reserveCapacity(vertices.count + edges.count + quads.count)
    for vertex in vertices {
        tvertices.append(vertex)
    }
    for edge in edges {
        tvertices.append((vertices[edge.x] + vertices[edge.y]) / 2)
    }
    for quad in quads {
        if (quad.z != quad.w) {
            tvertices.append((vertices[quad.x] + vertices[quad.y] +
                    vertices[quad.z] + vertices[quad.w]) /
                    4)
        } else {
            tvertices.append(
                    (vertices[quad.x] + vertices[quad.y] + vertices[quad.z]) / 3)
        }
    }
    // create quads
    var tquads: [vec4i] = []
    tquads.reserveCapacity(quads.count * 4)
    let edge_vertex = { (edge: vec2i) -> Int in
        vertices.count + edge_index(emap, edge)
    }
    let quad_vertex = { (quad_id: Int) -> Int in
        vertices.count + edges.count + quad_id
    }
    for (quad_id, quad) in quads.enumerated() {
        if (quad.z != quad.w) {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.w, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.w]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
            tquads.append([quad.w, edge_vertex([quad.w, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.w])])
        } else {
            tquads.append([quad.x, edge_vertex([quad.x, quad.y]),
                           quad_vertex(quad_id), edge_vertex([quad.z, quad.x])])
            tquads.append([quad.y, edge_vertex([quad.y, quad.z]),
                           quad_vertex(quad_id), edge_vertex([quad.x, quad.y])])
            tquads.append([quad.z, edge_vertex([quad.z, quad.x]),
                           quad_vertex(quad_id), edge_vertex([quad.y, quad.z])])
        }
    }

    // split boundary
    var tboundary: [vec2i] = []
    tboundary.reserveCapacity(boundary.count)
    for edge in boundary {
        tboundary.append([edge.x, edge_vertex(edge)])
        tboundary.append([edge_vertex(edge), edge.y])
    }

    // setup creases -----------------------------------
    var tcrease_edges: [vec2i] = []
    var tcrease_verts: [Int] = []
    if (lock_boundary) {
        for b in tboundary {
            tcrease_verts.append(b.x)
            tcrease_verts.append(b.y)
        }
    } else {
        for b in tboundary {
            tcrease_edges.append(b)
        }
    }

    // define vertices valence ---------------------------
    var tvert_val = [Int](repeating: 2, count: tvertices.count)
    for edge in tboundary {
        tvert_val[edge.x] = (lock_boundary) ? 0 : 1
        tvert_val[edge.y] = (lock_boundary) ? 0 : 1
    }

    // averaging pass ----------------------------------
    var avert = [vec4f](repeating: vec4f(), count: tvertices.count)
    var acount = [Int](repeating: 0, count: tvertices.count)
    for point in tcrease_verts {
        if (tvert_val[point] != 0) {
            continue
        }
        avert[point] += tvertices[point]
        acount[point] += 1
    }
    for edge in tcrease_edges {
        let centroid = (tvertices[edge.x] + tvertices[edge.y]) / 2
        for vid in [edge.x, edge.y] {
            if (tvert_val[vid] != 1) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for quad in tquads {
        let centroid = (tvertices[quad.x] + tvertices[quad.y] + tvertices[quad.z] + tvertices[quad.w]) / 4
        for vid in [quad.x, quad.y, quad.z, quad.w] {
            if (tvert_val[vid] != 2) {
                continue
            }
            avert[vid] += centroid
            acount[vid] += 1
        }
    }
    for i in 0..<tvertices.count {
        avert[i] /= Float(acount[i])
    }

    // correction pass ----------------------------------
    // p = p + (avg_p - p) * (4/avg_count)
    for i in 0..<tvertices.count {
        if (tvert_val[i] != 2) {
            continue
        }
        avert[i] = tvertices[i] + (avert[i] - tvertices[i]) * (4 / Float(acount[i]))
    }
    tvertices = avert

    // done
    return (tquads, tvertices)
}

// Subdivide lines by splitting each line in half.
func subdivide_lines(_ lines: [vec2i], _ vertices: [Float], _ level: Int) -> ([vec2i], [Float]) {
    if (level < 1) {
        return (lines, vertices)
    }
    var tess = (lines, vertices)
    for _ in 0..<level {
        tess = subdivide_lines(tess.0, tess.1)
    }
    return tess
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec2f], _ level: Int) -> ([vec2i], [vec2f]) {
    if (level < 1) {
        return (lines, vertices)
    }
    var tess = (lines, vertices)
    for _ in 0..<level {
        tess = subdivide_lines(tess.0, tess.1)
    }
    return tess
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec3f], _ level: Int) -> ([vec2i], [vec3f]) {
    if (level < 1) {
        return (lines, vertices)
    }
    var tess = (lines, vertices)
    for _ in 0..<level {
        tess = subdivide_lines(tess.0, tess.1)
    }
    return tess
}

func subdivide_lines(_ lines: [vec2i], _ vertices: [vec4f], _ level: Int) -> ([vec2i], [vec4f]) {
    if (level < 1) {
        return (lines, vertices)
    }
    var tess = (lines, vertices)
    for _ in 0..<level {
        tess = subdivide_lines(tess.0, tess.1)
    }
    return tess
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
func subdivide_triangles(_ triangles: [vec3i], _ vertices: [Float], _ level: Int) -> ([vec3i], [Float]) {
    if (level < 1) {
        return (triangles, vertices)
    }
    var tess = (triangles, vertices)
    for _ in 0..<level {
        tess = subdivide_triangles(tess.0, tess.1)
    }
    return tess
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec2f], _ level: Int) -> ([vec3i], [vec2f]) {
    if (level < 1) {
        return (triangles, vertices)
    }
    var tess = (triangles, vertices)
    for _ in 0..<level {
        tess = subdivide_triangles(tess.0, tess.1)
    }
    return tess
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec3f], _ level: Int) -> ([vec3i], [vec3f]) {
    if (level < 1) {
        return (triangles, vertices)
    }
    var tess = (triangles, vertices)
    for _ in 0..<level {
        tess = subdivide_triangles(tess.0, tess.1)
    }
    return tess
}

func subdivide_triangles(_ triangles: [vec3i], _ vertices: [vec4f], _ level: Int) -> ([vec3i], [vec4f]) {
    if (level < 1) {
        return (triangles, vertices)
    }
    var tess = (triangles, vertices)
    for _ in 0..<level {
        tess = subdivide_triangles(tess.0, tess.1)
    }
    return tess
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
func subdivide_quads(_ quads: [vec4i], _ vertices: [Float], _ level: Int) -> ([vec4i], [Float]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_quads(tess.0, tess.1)
    }
    return tess
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec2f], _ level: Int) -> ([vec4i], [vec2f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_quads(tess.0, tess.1)
    }
    return tess
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec3f], _ level: Int) -> ([vec4i], [vec3f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_quads(tess.0, tess.1)
    }
    return tess
}

func subdivide_quads(_ quads: [vec4i], _ vertices: [vec4f], _ level: Int) -> ([vec4i], [vec4f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_quads(tess.0, tess.1)
    }
    return tess
}

// Subdivide beziers by splitting each segment in two.
func subdivide_beziers(_ beziers: [vec4i], _ vertices: [Float], _ level: Int) -> ([vec4i], [Float]) {
    if (level < 1) {
        return (beziers, vertices)
    }
    var tess = (beziers, vertices)
    for _ in 0..<level {
        tess = subdivide_beziers(tess.0, tess.1)
    }
    return tess
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec2f], _ level: Int) -> ([vec4i], [vec2f]) {
    if (level < 1) {
        return (beziers, vertices)
    }
    var tess = (beziers, vertices)
    for _ in 0..<level {
        tess = subdivide_beziers(tess.0, tess.1)
    }
    return tess
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec3f], _ level: Int) -> ([vec4i], [vec3f]) {
    if (level < 1) {
        return (beziers, vertices)
    }
    var tess = (beziers, vertices)
    for _ in 0..<level {
        tess = subdivide_beziers(tess.0, tess.1)
    }
    return tess
}

func subdivide_beziers(_ beziers: [vec4i], _ vertices: [vec4f], _ level: Int) -> ([vec4i], [vec4f]) {
    if (level < 1) {
        return (beziers, vertices)
    }
    var tess = (beziers, vertices)
    for _ in 0..<level {
        tess = subdivide_beziers(tess.0, tess.1)
    }
    return tess
}

// Subdivide quads using Carmull-Clark subdivision rules.
func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [Float], _ level: Int,
                            _ lock_boundary: Bool = false) -> ([vec4i], [Float]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_catmullclark(tess.0, tess.1, lock_boundary)
    }
    return tess
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec2f], _ level: Int,
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec2f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_catmullclark(tess.0, tess.1, lock_boundary)
    }
    return tess
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec3f], _ level: Int,
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec3f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_catmullclark(tess.0, tess.1, lock_boundary)
    }
    return tess
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertices: [vec4f], _ level: Int,
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec4f]) {
    if (level < 1) {
        return (quads, vertices)
    }
    var tess = (quads, vertices)
    for _ in 0..<level {
        tess = subdivide_catmullclark(tess.0, tess.1, lock_boundary)
    }
    return tess
}

// -----------------------------------------------------------------------------
//MARK:- SHAPE SAMPLING
// -----------------------------------------------------------------------------
// Pick a point in a point set uniformly.
func sample_points(_ npoints: Int, _ re: Float) -> Int {
    sample_uniform(npoints, re)
}

func sample_points(_ cdf: [Float], _ re: Float) -> Int {
    sample_discrete(cdf, re)
}

func sample_points_cdf(_ npoints: Int) -> [Float] {
    var cdf = [Float](repeating: 0.0, count: npoints)
    for i in 0..<cdf.count {
        cdf[i] = 1 + (i != 0 ? cdf[i - 1] : 0)
    }
    return cdf
}

func sample_points_cdf(_ cdf: inout [Float], _ npoints: Int) {
    for i in 0..<cdf.count {
        cdf[i] = 1 + (i != 0 ? cdf[i - 1] : 0)
    }
}

// Pick a point on lines uniformly.
func sample_lines(_ cdf: [Float], _ re: Float, _ ru: Float) -> (Int, Float) {
    (sample_discrete(cdf, re), ru)
}

func sample_lines_cdf(_ lines: [vec2i], _ positions: [vec3f]) -> [Float] {
    var cdf = [Float](repeating: 0.0, count: lines.count)
    for i in 0..<cdf.count {
        let l = lines[i]
        let w = line_length(positions[l.x], positions[l.y])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
    return cdf
}

func sample_lines_cdf(_ cdf: inout [Float], _ lines: [vec2i], _ positions: [vec3f]) {
    for i in 0..<cdf.count {
        let l = lines[i]
        let w = line_length(positions[l.x], positions[l.y])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
}

// Pick a point on a triangle mesh uniformly.
func sample_triangles(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    (sample_discrete(cdf, re), sample_triangle(ruv))
}

func sample_triangles_cdf(_ triangles: [vec3i], _  positions: [vec3f]) -> [Float] {
    var cdf = [Float](repeating: 0.0, count: triangles.count)
    for i in 0..<cdf.count {
        let t = triangles[i]
        let w = triangle_area(positions[t.x], positions[t.y], positions[t.z])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
    return cdf
}

func sample_triangles_cdf(_ cdf: inout [Float], _ triangles: [vec3i], _ positions: [vec3f]) {
    for i in 0..<cdf.count {
        let t = triangles[i]
        let w = triangle_area(positions[t.x], positions[t.y], positions[t.z])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
}

// Pick a point on a quad mesh uniformly.
func sample_quads(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    (sample_discrete(cdf, re), ruv)
}

func sample_quads_cdf(_ quads: [vec4i], _ positions: [vec3f]) -> [Float] {
    var cdf = [Float](repeating: 0.0, count: quads.count)
    for i in 0..<cdf.count {
        let q = quads[i]
        let w = quad_area(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
    return cdf
}

func sample_quads_cdf(_ cdf: inout [Float], _ quads: [vec4i], _ positions: [vec3f]) {
    for i in 0..<cdf.count {
        let q = quads[i]
        let w = quad_area(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        cdf[i] = w + (i != 0 ? cdf[i - 1] : 0)
    }
}

// Samples a set of points over a triangle/quad mesh uniformly. Returns pos,
// norm and texcoord of the sampled points.
func sample_triangles(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                      _ triangles: [vec3i], _ positions: [vec3f], _ normals: [vec3f],
                      _ texcoords: [vec2f], _ npoints: Int) {
    sampled_positions = .init(repeating: vec3f(), count: npoints)
    sampled_normals = .init(repeating: vec3f(), count: npoints)
    sampled_texcoords = .init(repeating: vec2f(), count: npoints)
    let cdf = sample_triangles_cdf(triangles, positions)
    for i in 0..<npoints {
        let sample = sample_triangles(cdf, rand1f(), rand2f())
        let t = triangles[sample.0]
        let uv = sample.1
        sampled_positions[i] = interpolate_triangle(
                positions[t.x], positions[t.y], positions[t.z], uv)
        if (!sampled_normals.isEmpty) {
            sampled_normals[i] = normalize(
                    interpolate_triangle(normals[t.x], normals[t.y], normals[t.z], uv))
        } else {
            sampled_normals[i] = triangle_normal(
                    positions[t.x], positions[t.y], positions[t.z])
        }
        if (!sampled_texcoords.isEmpty) {
            sampled_texcoords[i] = interpolate_triangle(
                    texcoords[t.x], texcoords[t.y], texcoords[t.z], uv)
        } else {
            sampled_texcoords[i] = zero2f
        }
    }
}

func sample_quads(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                  _ quads: [vec4i], _ positions: [vec3f], _ normals: [vec3f],
                  _ texcoords: [vec2f], _ npoints: Int) {
    sampled_positions = .init(repeating: vec3f(), count: npoints)
    sampled_normals = .init(repeating: vec3f(), count: npoints)
    sampled_texcoords = .init(repeating: vec2f(), count: npoints)
    let cdf = sample_quads_cdf(quads, positions)
    for i in 0..<npoints {
        let sample = sample_quads(cdf, rand1f(), rand2f())
        let q = quads[sample.0]
        let uv = sample.1
        sampled_positions[i] = interpolate_quad(
                positions[q.x], positions[q.y], positions[q.z], positions[q.w], uv)
        if (!sampled_normals.isEmpty) {
            sampled_normals[i] = normalize(interpolate_quad(
                    normals[q.x], normals[q.y], normals[q.z], normals[q.w], uv))
        } else {
            sampled_normals[i] = quad_normal(
                    positions[q.x], positions[q.y], positions[q.z], positions[q.w])
        }
        if (!sampled_texcoords.isEmpty) {
            sampled_texcoords[i] = interpolate_quad(
                    texcoords[q.x], texcoords[q.y], texcoords[q.z], texcoords[q.w], uv)
        } else {
            sampled_texcoords[i] = zero2f
        }
    }
}
