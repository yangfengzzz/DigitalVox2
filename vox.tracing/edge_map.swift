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
func make_edge_map(triangles: [vec3i]) -> edge_map {
    fatalError()
}

func make_edge_map(quads: [vec4i]) -> edge_map {
    fatalError()
}

func insert_edges(emap: inout edge_map, triangles: [vec3i]) {
    fatalError()
}

func insert_edges(emap: inout edge_map, quads: [vec4i]) {
    fatalError()
}

// Insert an edge and return its index
func insert_edge(emap: inout edge_map, edge: vec2i) -> Int {
    fatalError()
}

// Get the edge index
func edge_index(emap: edge_map, edge: vec2i) -> Int {
    fatalError()
}

// Get edges and boundaries
func num_edges(emap: edge_map) -> Int {
    fatalError()
}

func get_edges(emap: edge_map) -> [vec2i] {
    fatalError()
}

func get_boundary(emap: edge_map) -> [vec2i] {
    fatalError()
}

func get_edges(triangles: [vec3i]) -> [vec2i] {
    fatalError()
}

func get_edges(quads: [vec4i]) -> [vec2i] {
    fatalError()
}

func get_edges(triangles: [vec3i], quads: [vec4i]) -> [vec2i] {
    fatalError()
}

// Build adjacencies between faces (sorted counter-clockwise)
func face_adjacencies(triangles: [vec3i]) -> [vec3i] {
    fatalError()
}

// Build adjacencies between vertices (sorted counter-clockwise)
func vertex_adjacencies(triangles: [vec3i], adjacencies: [vec3i]) -> [[Int]] {
    fatalError()
}

// Compute boundaries as a list of loops (sorted counter-clockwise)
func ordered_boundaries(triangles: [vec3i], adjacency: [vec3i], num_vertices: Int) -> [[Int]] {
    fatalError()
}

// Build adjacencies between each vertex and its adjacent faces.
// Adjacencies are sorted counter-clockwise and have same starting points as
// vertex_adjacencies()
func vertex_to_faces_adjacencies(triangles: [vec3i], adjacencies: [vec3i]) -> [[Int]] {
    fatalError()
}
