//
//  hash_grid.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// A sparse grid of cells, containing list of points. Cells are stored in
// a dictionary to get sparsity. Helpful for nearest neighboor lookups.
struct hash_grid {
    var cell_size: Float = 0
    var cell_inv_size: Float = 0
    var positions: [vec3f] = []
    var cells: [vec3i: [Int]] = [:]
}

// Create a hash_grid
func make_hash_grid(cell_size: Float) -> hash_grid {
    fatalError()
}

func make_hash_grid(positions: [vec3f], cell_size: Float) -> hash_grid {
    fatalError()
}

// Inserts a point into the grid
func insert_vertex(grid: inout hash_grid, position: vec3f) -> Int {
    fatalError()
}

// Finds the nearest neighbors within a given radius
func find_neighbors(grid: hash_grid, neighbors: inout [Int],
                    position: vec3f, max_radius: Float) {
    fatalError()
}

func find_neighbors(grid: hash_grid, neighbors: inout [Int], vertex: Int,
                    max_radius: Float) {
    fatalError()
}
