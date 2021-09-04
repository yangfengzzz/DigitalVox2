//
//  edge_map.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// Dictionary to store edge information. `index` is the index to the edge
// array, `edges` the array of edges and `nfaces` the number of adjacent faces.
// We store only bidirectional edges to keep the dictionary small. Use the
// functions below to access this data.
struct edge_map {
    struct edge_data {
        var index: Int
        var nfaces: Int
    }

    var edges: [vec2i: edge_data] = [:]
}

// Initialize an edge map with elements.
func make_edge_map(_ triangles: [vec3i]) -> edge_map {
    var emap = edge_map()
    for t in triangles {
        _ = insert_edge(&emap, [t.x, t.y])
        _ = insert_edge(&emap, [t.y, t.z])
        _ = insert_edge(&emap, [t.z, t.x])
    }
    return emap
}

func make_edge_map(_ quads: [vec4i]) -> edge_map {
    var emap = edge_map()
    for q in quads {
        _ = insert_edge(&emap, [q.x, q.y])
        _ = insert_edge(&emap, [q.y, q.z])
        if (q.z != q.w) {
            _ = insert_edge(&emap, [q.z, q.w])
        }
        _ = insert_edge(&emap, [q.w, q.x])
    }
    return emap
}

func insert_edges(_ emap: inout edge_map, _ triangles: [vec3i]) {
    for t in triangles {
        _ = insert_edge(&emap, [t.x, t.y])
        _ = insert_edge(&emap, [t.y, t.z])
        _ = insert_edge(&emap, [t.z, t.x])
    }
}

func insert_edges(_ emap: inout edge_map, _  quads: [vec4i]) {
    for q in quads {
        _ = insert_edge(&emap, [q.x, q.y])
        _ = insert_edge(&emap, [q.y, q.z])
        if (q.z != q.w) {
            _ = insert_edge(&emap, [q.z, q.w])
        }
        _ = insert_edge(&emap, [q.w, q.x])
    }
}

// Insert an edge and return its index
func insert_edge(_ emap: inout edge_map, _  edge: vec2i) -> Int {
    let es = edge.x < edge.y ? edge : vec2i(edge.y, edge.x)
    let it = emap.edges.first(where: { (key: vec2i, value: edge_map.edge_data) in
        key == es
    })
    if (it == nil) {
        let data = edge_map.edge_data(index: emap.edges.count, nfaces: 1)
        emap.edges[es] = data
        return data.index
    } else {
        var value = it!.value
        value.nfaces += 1
        emap.edges[it!.key] = value
        return value.index
    }
}

// Get the edge index
func edge_index(_ emap: edge_map, _ edge: vec2i) -> Int {
    let es = edge.x < edge.y ? edge : vec2i(edge.y, edge.x)
    let iterator = emap.edges.first(where: { (key: vec2i, value: edge_map.edge_data) in
        key == es
    })
    if (iterator == nil) {
        return -1
    }
    return iterator!.value.index
}

// Get edges and boundaries
func num_edges(_ emap: edge_map) -> Int {
    emap.edges.count
}

func get_edges(_ emap: edge_map) -> [vec2i] {
    var edges = [vec2i](repeating: vec2i(), count: emap.edges.count)
    for (edge, data) in emap.edges {
        edges[data.index] = edge
    }
    return edges
}

func get_boundary(_ emap: edge_map) -> [vec2i] {
    var boundary: [vec2i] = []
    for (edge, data) in emap.edges {
        if (data.nfaces < 2) {
            boundary.append(edge)
        }
    }
    return boundary
}

func get_edges(_ triangles: [vec3i]) -> [vec2i] {
    get_edges(make_edge_map(triangles))
}

func get_edges(_ quads: [vec4i]) -> [vec2i] {
    get_edges(make_edge_map(quads))
}

func get_edges(_ triangles: [vec3i], _ quads: [vec4i]) -> [vec2i] {
    var edges = get_edges(triangles)
    let more_edges = get_edges(quads)
    edges.append(contentsOf: more_edges)
    return edges
}

// Build adjacencies between faces (sorted counter-clockwise)
func face_adjacencies(_ triangles: [vec3i]) -> [vec3i] {
    let get_edge = { (triangle: vec3i, i: Int) -> vec2i in
        let x = triangle[i], y = triangle[i < 2 ? i + 1 : 0]
        return x < y ? vec2i(x, y) : vec2i(y, x)
    }
    var adjacencies = [vec3i](repeating: [-1, -1, -1], count: triangles.count)
    var edge_map: [vec2i: Int] = [:]
    edge_map.reserveCapacity(Int(Float(triangles.count) * 1.5))
    for i in 0..<triangles.count {
        for k in 0..<3 {
            let edge = get_edge(triangles[i], k)
            let it = edge_map.first(where: { (key: vec2i, value: Int) in
                key == edge
            })
            if (it == nil) {
                edge_map[edge] = i
            } else {
                let neighbor = it!.value
                adjacencies[i][k] = neighbor
                for kk in 0..<3 {
                    let edge2 = get_edge(triangles[neighbor], kk)
                    if (edge2 == edge) {
                        adjacencies[neighbor][kk] = i
                        break
                    }
                }
            }
        }
    }
    return adjacencies
}

// Build adjacencies between vertices (sorted counter-clockwise)
func vertex_adjacencies(_ triangles: [vec3i], _  adjacencies: [vec3i]) -> [[Int]] {
    let find_index = { (v: vec3i, x: Int) -> Int in
        if (v.x == x) {
            return 0
        }
        if (v.y == x) {
            return 1
        }
        if (v.z == x) {
            return 2
        }
        return -1
    }

    // For each vertex, find any adjacent face.
    var num_vertices = 0
    var face_from_vertex = [Int](repeating: -1, count: triangles.count * 3)

    for i in 0..<triangles.count {
        for k in 0..<3 {
            face_from_vertex[triangles[i][k]] = i
            num_vertices = max(num_vertices, triangles[i][k])
        }
    }

    // Init result.
    var result = [[Int]](repeating: [], count: num_vertices)

    // For each vertex, loop around it and build its adjacency.
    for i in 0..<num_vertices {
        result[i].reserveCapacity(6)
        let first_face = face_from_vertex[i]
        if (first_face == -1) {
            continue
        }

        var face = first_face
        while (true) {
            var k = find_index(triangles[face], i)
            k = k != 0 ? k - 1 : 2
            result[i].append(triangles[face][k])
            face = adjacencies[face][k]
            if (face == -1) {
                break
            }
            if (face == first_face) {
                break
            }
        }
    }

    return result
}

// Compute boundaries as a list of loops (sorted counter-clockwise)
func ordered_boundaries(_ triangles: [vec3i], _ adjacency: [vec3i], _ num_vertices: Int) -> [[Int]] {
    // map every boundary vertex to its next one
    var next_vert = [Int](repeating: -1, count: num_vertices)
    for i in 0..<triangles.count {
        for k in 0..<3 {
            if (adjacency[i][k] == -1) {
                next_vert[triangles[i][k]] = triangles[i][(k + 1) % 3]
            }
        }
    }

    // result
    var boundaries: [[Int]] = [[]]

    // arrange boundary vertices in loops
    for i in 0..<next_vert.count {
        if (next_vert[i] == -1) {
            continue
        }

        // add new empty boundary
        boundaries.append([])
        var current = i

        while (true) {
            let next = next_vert[current]
            if (next == -1) {
                return [[]]
            }
            next_vert[current] = -1
            boundaries[boundaries.endIndex-1].append(current)

            // close loop if necessary
            if (next == i) {
                break
            } else {
                current = next
            }
        }
    }

    return boundaries
}

// Build adjacencies between each vertex and its adjacent faces.
// Adjacencies are sorted counter-clockwise and have same starting points as
// vertex_adjacencies()
func vertex_to_faces_adjacencies(_ triangles: [vec3i], _ adjacencies: [vec3i]) -> [[Int]] {
    let find_index = { (v: vec3i, x: Int) -> Int in
        if (v.x == x) {
            return 0
        }
        if (v.y == x) {
            return 1
        }
        if (v.z == x) {
            return 2
        }
        return -1
    }

    // For each vertex, find any adjacent face.
    var num_vertices = 0
    var face_from_vertex = [Int](repeating: -1, count: triangles.count * 3)

    for i in 0..<triangles.count {
        for k in 0..<3 {
            face_from_vertex[triangles[i][k]] = i
            num_vertices = max(num_vertices, triangles[i][k])
        }
    }

    // Init result.
    var result = [[Int]](repeating: [], count: num_vertices)

    // For each vertex, loop around it and build its adjacency.
    for i in 0..<num_vertices {
        result[i].reserveCapacity(6)
        let first_face = face_from_vertex[i]
        if (first_face == -1) {
            continue
        }

        var face = first_face
        while (true) {
            var k = find_index(triangles[face], i)
            k = k != 0 ? k - 1 : 2
            face = adjacencies[face][k]
            result[i].append(face)
            if (face == -1) {
                break
            }
            if (face == first_face) {
                break
            }
        }
    }

    return result
}
